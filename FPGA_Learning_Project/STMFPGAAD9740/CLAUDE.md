# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Electronic design contest (电赛) training project: STM32H723ZGT6 + Altera EP4CE10E22I7N FPGA + AD9740 (10-bit DAC) arbitrary waveform generator. Communication via FMC asynchronous bus. Development tools: Keil MDK-ARM 5.32 (ARM Compiler 6.24), Quartus II 14.1.

Features:
- UART command interface (USART1, 115200 baud): FREQ/AMP/WAVE/START/STOP/SWEEP/STATUS/HELP
- 32-bit DDS phase accumulator (0.029 Hz resolution @ 125 MHz FPGA clock)
- Dual-port waveform RAM (2048 × 16-bit, single M9K block)
- 6 waveform types exposed via UART: sine, triangle, square, sawtooth, noise, DC (10 implemented in `waveform_gen.c`: the above + reverse sawtooth, sinc, exp-decay, gaussian)
- Amplitude scaling (0-1023, 10-bit) — hardware scaling on FPGA, no waveform reload needed
- Frequency sweep mode

## Repository Structure

The repo root (`D:\File\CubeMX\STM-FPGA\`) contains multiple sibling projects sharing the same hardware platform:

- **`FPGA_Learning_Project/STMFPGAAD9740/`** — Active AWG project: Verilog top-level + address decoder + DDS DAC controller + UART command interface + waveform generation library
- **`DDS_AD9740/`** — FMC-only baseline (previous iteration of STMFPGAAD9740)
- **`DDS_AD9959/`** — Extended version with SPI4 (AD9959 config), USART1 (115200 debug console), USART2 (9600), GPIO (LCD)
- **`FPGA_AWG/`** — Nios II soft-core CPU approach (SOPC Builder, more complex)
- **`FPGA_Learning_Project/LED/`**, **`LED_PLL/`** — Basic FPGA training exercises

Each project mirrors the same structure: `STM32/` (CubeMX HAL project) + `FMC/` (Quartus II project).

## Hardware Architecture

### STM32H723ZGT6 ↔ FPGA Communication
- **Bus**: FMC asynchronous, Bank 1 at `0x60000000`, 16-bit data / 15-bit address, no NBL
- **Signals**: NE1 (chip select), NOE (read), NWE (write) — all active-low
- **FMC timing**: AddressSetup=4, AddressHold=15, DataSetup=3, BusTurnAround=2, AccessMode=A
- **MPU config for FMC region**: Device type (non-cacheable, non-bufferable, shareable, no exec), 64MB at `0x60000000` (MPU_REGION_SIZE_64MB)
- **STM32 access pattern**: `#define FPGA ((volatile uint16_t *)0x60000000)` — word-addressed, not byte-addressed
- **CRITICAL**: FMC_A[15] is **NOT connected** to the FPGA (only A[14:0] are wired). This means STM32 accesses to 0x8000+ are aliased to 0x0000+ on the FPGA. All control/status registers MUST use addresses in 0x4000–0x7FFF range (where FMC_A[14]=1) to be decoded as register space. See `fpga_reg_map.h` for current register addresses.

### Clocks
| Domain | Source | Frequency |
|--------|--------|-----------|
| STM32 SYSCLK | HSI (64MHz) → PLL (×275/32, /PLLP=1) | 550 MHz |
| STM32 HCLK | SYSCLK / 2 | 275 MHz |
| STM32 FMC_CLK | PLLQ=5 (from same PLL) | 110 MHz |
| FPGA system (C0) | 50 MHz OSC (PIN_23) → PLL C0 (×5/2) | 125 MHz |
| FPGA DAC clock (C1) | 50 MHz OSC (PIN_23) → PLL C1 (×5/2) | 125 MHz |
| DDS sample rate | 相位累加器每周期推进 (无分频) | 125 MSPS |
| DAC_CLK output | PLL C1 直连输出引脚 (不经过逻辑) | 125 MHz |

### Pin Mapping
All I/O: 3.3-V LVCMOS standard. Configuration device: EPCS16.
- FPGA pin assignments: `FMC/FMC_Demo.qsf` — FMC bus, clock, DAC pins (all assigned)
- STM32 pin mux: `STM32/FMC_DEMO.ioc` (CubeMX)
- RST_N: assigned to IOBANK_1 with internal weak pull-up (no external pin location needed)
- FMC pin alternate functions: mostly AF12, but PC7 (FMC_NE1) uses AF9, PC0 (FMC_D12) uses AF1

### AD9740 DAC
- 10-bit, 210 MSPS, internal reference (default mode — no complex init needed)
- Data latched on rising edge of DAC clock; FPGA updates data on negedge for better setup time
- DAC pins assigned in QSF (lines 174-195): DATA[0..9] on pins 49,50,44,46,38,43,1,3,10,33; CLK on pin 34

## FPGA Source Files (in `FMC/`)

### Module Hierarchy
```
FMC_Demo.v  (top-level, pure Verilog, replaces BDF)
├── pll1.v                    — ALTPLL: 50 MHz → 125 MHz (MegaWizard, via pll1.qip)
├── stm32_fmc_16bit.v         — FMC async slave: 2-stage synchronizer + tri-state bus
├── fmc_addr_decoder.v        — Address decoder: routes FMC access to RAM or control/status regs
├── ram_2port1.v              — Dual-port RAM: 2048 × 16-bit, M9K (MegaWizard, via ram_2port1.qip)
└── dac_controller.v          — DDS engine + AD9740 DAC driver (62.5 MHz via sample_tick)
```

### Key Timing Constraints (`FMC_Demo.sdc`)
- 50 MHz input clock: 20ns period
- `derive_pll_clocks` + `derive_clock_uncertainty` for the 125 MHz PLL output
- All FMC inputs (NE1, NOE, NWE, A[*], D[*]) set as **false path** — async bus, synchronized internally
- RST_N set as false path (async reset)
- DAC outputs are unconstrained (low-speed point-to-point, generous margin)

### `FMC_Demo.v` — Top-level
- Ports: `CLK_50M, FMC_NE1, FMC_NOE, FMC_NWE, FMC_A[14:0], FMC_D[15:0], RST_N, DAC_DATA[9:0], DAC_CLK`
- Instantiates all sub-modules and wires them together
- Reset: simple mode (`sys_rst_n = RST_N`); strict mode (`RST_N & pll_locked`) commented out — enable if PLL lock detection is available
- RAM depth: 2048 (11-bit address); `waveform_len` hardwired to `11'd2047`
- Orphan signals: `burst_en` and `wave_sel` are decoded from MODE register but **not connected to dac_controller** (the controller has no ports for them). They exist as wires but are unused. Future: wire them to waveform mux or burst logic.

### `stm32_fmc_16bit.v` — FMC async slave
- 2-stage synchronizer on all async FMC inputs (NE1, NOE, NWE, A[14:0]) → 125 MHz domain
- Exports user-level signals: `user_wr_en`, `user_rd_en`, `user_addr[14:0]`, `user_wdata[15:0]`, `user_rdata[15:0]`
- Tri-state data bus: `assign FMC_D = (user_rd_en) ? user_rdata : 16'hzzzz`
- **No internal logic** — purely a synchronization and bus-interface bridge
- Write data is combinatorial pass-through from FMC_D (not registered — FMC_D is driven by STM32 for the full write cycle)

### `fmc_addr_decoder.v` — Address decoder
- Address space (15-bit, only A[14:0] connected to FPGA; FMC_A[15] is NOT wired):
  | Range | Region | Description |
  |-------|--------|-------------|
  | `0x0000–0x07FF` (A14:11=0) | Waveform RAM | Dual-port RAM Port A (2048 × 16-bit) |
  | `0x0800–0x3FFF` (A14=0, A13:11≠0) | Unmapped | Reads return 0 |
  | `0x4000–0x400F` | Control registers | MODE, FREQ_H/L, AMP, PHASE_H/L, WAVEFORM_BASE |
  | `0x4010–0x401F` | Status registers | STATUS, CURRENT_SAMPLE (read-only) |
- Control register map:
  | Addr | Name | Bits | Description |
  |------|------|------|-------------|
  | `0x4000` | MODE | [0]=start, [1]=dds_en, [2]=burst_en, [7:4]=wave_sel | burst_en and wave_sel decoded but **unused** by current dac_controller |
  | `0x4001` | FREQ_H | [15:0] | Frequency word [31:16] |
  | `0x4002` | FREQ_L | [15:0] | Frequency word [15:0] |
  | `0x4003` | AMP | [9:0] | Amplitude scale (0=min, 1023=max) |
  | `0x4004` | PHASE_H | [15:0] | Phase offset [31:16] |
  | `0x4005` | PHASE_L | [15:0] | Phase offset [15:0] |
  | `0x4006` | WAVEFORM_BASE | [10:0] | Ping-pong buffer base address (11-bit for 2048 depth) |
  | `0x4010` | STATUS | [0]=ram_busy, [1]=dac_running | Read-only; ram_busy is tied to 0 (TODO) |
  | `0x4011` | CURRENT_SAMPLE | [9:0] | Actual DAC output value (after amplitude scaling) |
- All control registers are synchronous write (posedge clk_125m), combinational read
- Reset values: start=0, dds_en=0, burst_en=0, amplitude=0x3FF (full scale), freq_word=0, phase=0

### `dac_controller.v` — DDS engine + AD9740 driver
- **Dual clock domain**: `clk_125m` (PLL C0) for DDS engine; `dac_clk_in` (PLL C1) for DAC_DATA output register
- 32-bit phase accumulator advances **every clk_125m cycle** (125 MSPS, no sample_tick divider)
- Phase resolution: 125e6 / 2³² ≈ 0.0291 Hz
- Two addressing modes:
  - **DDS mode** (dds_en=1): Address = (phase_acc + phase_offset)[31:21] + waveform_base → upper 11 bits as table index
  - **Direct mode** (dds_en=0): Address = (phase_acc + phase_offset)[10:0] + waveform_base → sequential
- Amplitude scaling: `dac_value = (ram_rd_data[15:0] * amplitude[9:0]) >> 10` — all combinational (C0 domain)
- CDC boundary: `dac_value_c0` registers combinational result in C0 domain before crossing to C1
- DAC_CLK: **PLL C1 直连输出** (125 MHz, `assign DAC_CLK = dac_clk_125m` in FMC_Demo.v), 不经过任何逻辑
- DAC_DATA: updated on `dac_clk_in` **negedge** → ~4ns setup before DAC_CLK rising edge (AD9740 latches)
- Idle / stopped: DAC_CLK free-running, DAC_DATA=0x200 (mid-scale)
- **Note**: No `dac_clk` output port — DAC_CLK is routed directly from PLL C1 in the top-level

### IP Cores (MegaWizard-generated, do not hand-edit)
- **`pll1.v`** — ALTPLL: 50 MHz → 125 MHz (c0). Include via `pll1.qip`.
- **`ram_2port1.v`** — `altsyncram` dual-port RAM: 2048 × 16-bit, M9K. Port A: write, Port B: read. Include via `ram_2port1.qip`.

## STM32 Source Files (in `STM32/Core/`)

### CubeMX Code Generation Rules
All custom code MUST go between `USER CODE BEGIN` / `USER CODE END` markers. CubeMX will overwrite anything outside these markers when regenerating. When adding new peripherals, copy init code from regenerated sections into USER CODE blocks.

### `Inc/main.h`
- Defines `FPGA_BASE_ADDR 0x60000000`, `FPGA ((volatile uint16_t *)FPGA_BASE_ADDR)`, `M_PI 3.1415926f`
- Exports `extern UART_HandleTypeDef huart1` for use by other modules

### `Inc/fpga_reg_map.h` — FPGA register map + driver helpers
- Complete register address definitions matching `fmc_addr_decoder.v`
- Frequency calculation macros: `DDS_FREQ_TO_WORD(f_hz)` and `DDS_WORD_TO_FREQ(word)`
  - `FREQ_WORD = Fout × 2³² / 125000000`
- Waveform type constants: WAVE_SINE(0), WAVE_TRIANGLE(1), WAVE_SQUARE(2), WAVE_SAWTOOTH(3), WAVE_NOISE(4), WAVE_DC(5), WAVE_SINC(6), WAVE_ARBITRARY(7)
- Inline driver functions: `FPGA_WriteReg()`, `FPGA_ReadReg()`, `FPGA_DAC_Start()`, `FPGA_DAC_Stop()`, `FPGA_SetFrequency()`, `FPGA_SetAmplitude()`, `FPGA_LoadWaveform()`, `FPGA_IsRunning()`
- `FPGA_DAC_Start/Stop` use read-modify-write on the MODE register (safe: only bit 0 is changed)

### `Inc/waveform_gen.h` — Waveform generation library API
- 10 generator functions: Gen_SineWave, Gen_TriangleWave, Gen_SquareWave, Gen_SawtoothWave, Gen_RevSawtoothWave, Gen_DCLevel, Gen_SincWave, Gen_NoiseWave, Gen_ExpDecay, Gen_GaussianPulse
- All functions fill uint16_t buffers with 0-1023 range (10-bit DAC)
- Uses float math (Cortex-M7 hardware FPU)
- **Note**: Only 6 are currently exposed via UART commands (see `LoadCurrentWaveform()` in `main.c`)

### `Src/waveform_gen.c` — Waveform generation implementation
- Sine: `offset + amplitude * sin(2π · i / points)`
- Triangle: 4-quarter linear ramp (±amplitude around offset)
- Square: duty-cycle controlled (0-100%), ±amplitude around offset
- Sawtooth: linear -amplitude → +amplitude over period
- RevSawtooth: linear +amplitude → -amplitude over period
- Sinc: sin(x)/x, central lobe + configurable side lobes (1-10), centered at DAC_MID_VALUE
- Noise: LCG PRNG `X_{n+1} = 1664525X_n + 1013904223`, state & 0xFFFF scaled to ±amplitude
- ExpDecay: `DAC_MID_VALUE + amplitude · exp(-i/τ)`
- Gaussian: `DAC_MID_VALUE + amplitude · exp(-(i-center)²/2σ²)`, center at points/2
- All values clamped 0-1023 via `clamp_dac()` helper

### `Src/main.c` — Application entry point
- Initialization order: MPU_Config → SCB_EnableICache/DCache → HAL_Init → SystemClock_Config → MX_GPIO_Init → MX_FMC_Init → MX_USART1_UART_Init
- Loads default waveform (1 kHz sine, amplitude=100, DDS mode) on startup; START commented out by default
- `LoadCurrentWaveform()` generates waveform at full 511 amplitude (half-swing); FPGA AMP register handles actual output scaling
- Waveform buffer: 2048 uint16_t in `.dtcmram` section (DTCM, zero-wait-state access)
- UART command processing loop (interrupt-driven RX, polling in main loop):

| Command | Syntax | Description |
|---------|--------|-------------|
| FREQ | `FREQ <Hz>` | Set DDS frequency (1–62,500,000 Hz) |
| AMP | `AMP <0-1023>` | Set amplitude (hardware scaling, no reload) |
| WAVE | `WAVE <0-5>` | Select waveform (0=sine 1=tri 2=sqr 3=saw 4=noise 5=DC) |
| START | `START` | Start DAC output |
| STOP | `STOP` | Stop DAC (idle at mid-scale) |
| SWEEP | `SWEEP <f1> <f2> <step> <ms>` | Frequency sweep (supports early cancel via `g_sweep_active`) |
| STATUS | `STATUS` | Print current settings (reads back all FPGA registers) |
| HELP | `HELP` | Show command list |

- UART RX: single-character interrupt, builds line until `\r`/`\n`, sets `uart_cmd_ready` flag; main loop polls flag
- Echo enabled (each received char is transmitted back)
- `UART_Printf()` uses `vsnprintf` into stack buffer + `HAL_UART_Transmit` (blocking, 100ms timeout)

### `Src/stm32h7xx_hal_msp.c` — Pin mux & peripheral init
- FMC pins initialized with alternate functions: mostly AF12, exceptions: PC7 (AF9, FMC_NE1), PC0 (AF1, FMC_D12)
- FMC_CLK sourced from PLL (`RCC_FMCCLKSOURCE_PLL` = 110 MHz from PLLQ=5)
- USART1: PB14(TX)/PB15(RX), AF4, 115200 baud, interrupt enabled (priority 0,0)
- GPIO clocks enabled in `MX_GPIO_Init()` — banks A,B,C,D,E,F,G all enabled

## Build Process

### STM32 (Keil MDK-ARM)
- Project file: `STM32/MDK-ARM/FMC_DEMO.uvprojx`
- Open in Keil µVision, build with F7, flash with F8
- No CLI build script — everything is IDE-driven
- Compiler: ARM Compiler 6.24 (AC6), CPU: Cortex-M7
- HAL version: STM32H7xx_HAL_Driver V1.12.1
- **Note**: `waveform_gen.c` uses `math.h` (sinf, expf) — ensure FPU is enabled and math library is linked (`-lm`)

### FPGA (Quartus II)
- Project file: `FMC/FMC_Demo.qpf`
- Open in Quartus II 14.1, Compile (Ctrl+L), Programmer to flash `output_files/FMC_Demo.sof`
- Top-level entity: `FMC_Demo` (from `FMC_Demo.v`)
- Verilog files registered in QSF; new files must be added with: `set_global_assignment -name VERILOG_FILE <file>.v`
- IP cores included via QIP: `pll1.qip`, `ram_2port1.qip`
- Timing constraints: `FMC_Demo.sdc` — FMC inputs marked as false paths (async, synchronized internally)
- DAC pins are already assigned in QSF — no pre-build steps needed

## Key Patterns & Gotchas

1. **FMC address mapping**: `FPGA[addr]` on STM32 side → `FMC_A = addr` on FPGA side. Word index, not byte address. A 16-bit access to `FPGA[0x4000]` drives `FMC_A = 0x4000`.

2. **Cache coherency**: FMC region MUST be configured as device memory via MPU before enabling D-Cache/I-Cache. Failure causes stale reads. Current MPU config: 64MB at 0x60000000, TEX=0, non-cacheable, non-bufferable, shareable, no exec.

3. **Metastability**: All async FMC inputs must be double-synchronized to the FPGA clock domain. `stm32_fmc_16bit.v` does this correctly for NE1, NOE, NWE, and A[14:0] — do not remove the 2-stage sync. The SDC file declares these as false paths because they are async (from STM32's 110 MHz FMC_CLK domain, not related to the 125 MHz FPGA clock).

4. **Tri-state timing**: `user_rdata` must be driven combinationally from address. The address decoder uses `always @(*)` for reads — adding a register stage on the read data path will break FMC reads (data won't be valid during the NOE window).

5. **RAM read-back ambiguity**: The top-level connects `ram_rd_data = ram_wr_en ? ram_wr_data : dac_ram_rd_data`. STM32 writes waveform data then switches to read-only mode, so this is benign — STM32 rarely reads back waveform RAM during active DAC operation.

6. **CubeMX regeneration**: When updating `.ioc`, CubeMX regenerates `main.c`, `main.h`, `stm32h7xx_hal_msp.c`, etc. Keep all custom code inside `USER CODE BEGIN`/`END` blocks. If adding new peripherals, copy init code from regenerated sections into USER CODE blocks.

7. **Amplitude scaling precision**: The DDS amplitude scaling `(ram_rd_data * amplitude) >> 10` is all combinational. `LoadCurrentWaveform()` always generates waveforms at full swing (amplitude=511, offset=512), relying on the FPGA AMP register for output scaling. This means amplitude changes don't require waveform reload. For small amplitudes, quantization noise increases — for high-precision low-amplitude output, regenerate the waveform table.

8. **DDS frequency**: Max output = 125 MHz / 2 = 62.5 MHz (Nyquist). The UART parser enforces 62.5 MHz as a soft limit. Practical clean output is <~20 MHz with a 2048-point table. DDS runs at 125 MSPS (no sample_tick divider). Frequency formula: `Fout = FREQ_WORD × 125e6 / 2³²`. See `DDS_FSAMPLE` in `fpga_reg_map.h`.

9. **FPGA resource usage**: ~1 M9K block (2048×16 dual-port RAM), ~200 LEs (synchronizer + decoder + DAC controller). Significant room for expansion.

10. **Orphan signals**: `burst_en` and `wave_sel` bits in the MODE register are decoded by `fmc_addr_decoder` but **not connected** to `dac_controller`. They exist as dangling wires in `FMC_Demo.v`. To use them, add corresponding input ports to `dac_controller` and wire them in the top-level.

11. **RST_N handling**: The RST_N pin is assigned to IOBANK_1 with internal weak pull-up but **no specific pin location** in the QSF. If an external reset button is needed, assign a pin location and optionally remove the weak pull-up.
