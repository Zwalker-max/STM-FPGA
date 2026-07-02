# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
STM32H723ZGT6 + Altera Cyclone IV (EP4CE10E22C8N) co-design board, linked by an
FMC bus. The FPGA is the bus slave + real-time engine; the STM32 is the bus
master + host. Current implementation: **AD9740 DDS arbitrary waveform
generator** (10-bit DAC, 125 MHz sample clock). Planned extension (see
`聊天文件/init.md`): **AD9220 ADC acquisition** (10-bit, 10 MSPS) reusing the
same FMC bridge + 32-bit accumulator + dual-port RAM pattern.

## Repository Layout
Two independent toolchains live side by side — never mix them.
- `FPGA/` — Quartus Prime project `FMC_Demo` (Verilog 2001). Source `.v` files,
  `FMC_Demo.qsf` (pin assignments), `FMC_Demo.qpf`, `stp1.stp` (SignalTap).
  Build artifacts: `db/`, `incremental_db/`, `output_files/` (regenerated).
- `STM32/` — STM32CubeMX project (`FMC_DEMO.ioc`) + MDK-ARM/Keil project
  (`MDK-ARM/FMC_DEMO.uvprojx`). `Core/Src`, `Core/Inc` are user code; `Drivers/`
  is HAL/CMSIS (do not hand-edit).
- `聊天文件/` — Chinese design notes and background (`init.md` = project spec /
  roadmap). Treat as authoritative requirements source.

## Build & Flash
- **FPGA**: open `FPGA/FMC_Demo.qpf` in Quartus Prime (Lite/Standard),
  compile (Processing ▶ Start Compilation), program via Programmer (.sof in
  `output_files/`). No CLI build is wired up; use the GUI. The top-level entity
  is `FMC_Demo` (set in `FMC_Demo.qsf`).
- **STM32**: open `STM32/MDK-ARM/FMC_DEMO.uvprojx` in Keil MDK, Build, Flash.
  CubeMX regeneration: edit `STM32/FMC_DEMO.ioc`, regenerate, then re-apply any
  user code in `USER CODE BEGIN/END` blocks (these are preserved by CubeMX).
- No automated tests, no linter, no CI.

## Architecture (the big picture that spans files)

### Clock & reset
`CLK_50M` (board 50 MHz, PIN_23) → `pll1` IP → `c0` = 125 MHz / 0° (all
internal logic) and `c1` = 125 MHz / 90° (drives `DAC_CLK` for AD9740
setup/hold — no DDR primitive needed). A 10-bit POR counter
(`FMC_Demo.v`, ~20 µs on the 50 MHz domain) releases `sys_rst_n` only after
the PLL is locked — do not reset off 125 MHz directly.

### FMC memory map (the contract between STM32 and FPGA)
STM32 FMC Bank1/NE1, async SRAM, 16-bit data, base `0x60000000`. Addresses are
**16-bit word offsets** (STM32 sees `FPGA[offset]`, see `dds.h`). Decoded in
`stm32_fmc_16bit.v`:
- `0x0000–0x03FF` — waveform RAM Port A (1024×16)
- `0x0400` — FTW shadow `[15:0]`
- `0x0401` — FTW shadow `[31:16]`
- `0x0404` — update trigger: atomic load shadow→active (write 1)
- `0x0408` — phase-accumulator reset pulse (self-clearing)
- `0x040C` — DAC control (bit0 = enable; 0 = mid-scale 0x200)
- `0x040D–0x4E1F` — M9K general register file

FTW writes are **two 16-bit shadow writes then an atomic update trigger** —
never write FTW directly. STM32 wraps this in `DDS_SetFrequency()` with
`__disable_irq()` + `__DMB()`.

### Data path (DDS/TX, current)
`stm32_fmc_16bit` ↔ `ram_2port1` Port A (STM32 read/write) —
`dds_core` drives Port B read address (`phase_acc[31:22]`, top 10 bits) —
`ram_2port1` Port B → `dac_control` → `DAC_D[9:0]`.

- `dds_core.v`: 32-bit phase accumulator. Frequency resolution =
  125 MHz / 2³² ≈ 0.029 Hz. `rd_addr` is combinational; RAM sync read adds
  1 cycle (matched by `user_rd_en` 1-cycle delay in the FMC slave).
- `ram_2port1.v`: inferred M9K true dual-port RAM, 1024×16, **registered
  reads on both ports** (do not switch to combinational read without redoing
  the read-data alignment in `stm32_fmc_16bit.v`).
- `dac_control.v`: single pipeline register; outputs `0x200` when disabled.

### STM32 driver layer (`STM32/Core/`)
- `dds.h` defines the `FPGA` macro: `((volatile uint16_t *)0x60000000)` — all
  FPGA access goes through `FPGA[addr]`.
- `dds.c`: generates 1024-point LUTs (sine, triangle, square w/ duty, rising/
  falling sawtooth, DC, sinc, exp-decay, gaussian, LFSR noise, custom),
  uploads to waveform RAM, computes FTW, atomic freq update, DAC enable,
  phase reset, RAM verify/checksum. `DDS_SetWaveform()` is the unified entry.
- `fmc.c`: FMC HAL SRAM init — async mode A, 16-bit, NE1, `FMC_CONTINUOUS_CLOCK_SYNC_ONLY`.
- `main.c`: `MPU_Config()` marks the entire 0x60000000 (256 MB) region as
  **Device / non-cacheable / non-bufferable** — required for FMC register
  access; do not enable caching on this region. D-Cache/I-Cache are enabled
  globally. USART1 @115200 8N1 is **TX-only** (RX interrupt intentionally off).

### Async clock-domain crossing
FMC control signals (`NE1/NOE/NWE/A`) are synchronized by **2-stage shift
registers** in `stm32_fmc_16bit.v` before decoding — keep this when extending.
The 125 MHz (FMC/logic) and any new 10 MHz (ADC) domains are asynchronous;
when adding ADC sampling, set an async clock group in Quartus and reuse the
2-flop synchronizer pattern.

## Conventions
- Verilog files open with a Chinese block comment documenting module purpose,
  interface, clock, and key design choices — match this style for new modules.
- STM32 user code stays inside `/* USER CODE BEGIN … END */` markers so
  CubeMX regeneration preserves it.
- Regenerate `.ioc` edits through CubeMX, not by hand-editing generated files.
- Pin assignments live in `FPGA/FMC_Demo.qsf`; the STM32 pin map is in
  `fmc.c` `HAL_FMC_MspInit` comments and the `.ioc`.

## AD9220 ADC acquisition (implemented, per `聊天文件/plan.md`)
The ADC subsystem runs **in parallel** with DDS on the same FMC bus, on a
separate address range. No DDS register/behavior was changed.

- FMC offsets (added in `stm32_fmc_16bit.v`): `0x1000` ADC ctrl (bit0=enable),
  `0x1001/0x1002` sample-rate step shadow lo/hi, `0x1003` step update trigger
  (atomic, toggle-CDC to 10 MHz domain), `0x1004` FIFO data (RO, read=pops one),
  `0x1005` FIFO status (bit0=empty, bit1=full, bits[11:2]=rdusedw). The old
  unused M9K general register file (`ram[0:19999]`, `0x040D–0x4E1F`) was
  **deleted** to free this range.
- `adc_clk` (10 MHz) = `pll1.c2` (user must reconfigure the `pll1` ALTPLL IP
  in Quartus to add c2; `FMC_Demo.v` already instantiates `.c2()`). ADC domain
  reset = 2-flop sync of `sys_rst_n`.
- `adc_decimator.v`: 32-bit phase accumulator on 10 MHz, overflow → latch
  `ADC_D[9:0]` (zero-extended to 16b) → FIFO write. Step/enable cross from
  125 MHz via toggle-ack handshake.
- `async_fifo.v`: hand-inferred 16b×1024 dual-clock FIFO (Gray pointers,
  registered full/empty). Write on 10 MHz, read on 125 MHz.
- FIFO read in `stm32_fmc_16bit.v`: single-cycle pulse via edge-detect of the
  synced read strobe (`rd_and & ~rd_and_q`) — one FMC read pops exactly one.
- `FMC_Demo.sdc`: 50/125/10 MHz clocks, async clock groups, `ADC_D` input delay.
- STM32 driver `adc.c/h`: `ADC_Init/Enable/SetSampleRate/Start/Stop`,
  `ADC_GetFIFOData/Status`. DMA2_Stream0 `Request=TIM2_UP`, PERIPH_TO_MEM,
  circular + HT/TC ping-pong (NOT free-running mem2mem — FMC has no DMA
  request line, so TIM2 paces reads at the sample rate to match the decimator).
  DMA buffers in AXI SRAM (`ADC_DMA_BUF` section in `FMC_DEMO.sct`, 32-aligned)
  with `SCB_InvalidateDCache_by_Addr` per callback. `DMA2_Stream0_IRQHandler`
  lives in `adc.c` (overrides weak startup). `ADC_ProcessData` is `__weak`.
- ADC pins (`ADC_CLK`, `ADC_D[9:0]`) in `FMC_Demo.qsf` are **provisional** —
  user must set them from the board schematic.
