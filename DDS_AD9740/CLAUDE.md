# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DDS arbitrary waveform generator based on **EP4CE10E22C8N FPGA** + **STM32H723ZGT6** + **AD9740 DAC** (10-bit, 125MSPS). The STM32 communicates with the FPGA over a 16-bit asynchronous FMC bus to write waveform data and frequency control words. The FPGA runs a DDS core that drives the AD9740 DAC output.

## Repository Structure

```
FPGA/          — Quartus II 14.1 project (FMC_Demo)
  FMC_Demo.v             — **top-level Verilog** (replaces BDF): instantiates all modules
  FMC_Demo.qpf           — Quartus project file
  FMC_Demo.qsf           — pin assignments + project settings
  stm32_fmc_16bit.v      — FMC slave + address decoder + DDS control registers
  dds_core.v             — 32-bit DDS phase accumulator
  dac_control.v          — AD9740 DAC output pipeline
  ram_2port1.vhd         — 1024×16 dual-port waveform RAM (MegaWizard IP)
  ram_2port1.cmp         — VHDL component declaration
  pll1.v                 — ALTPLL (50MHz→125MHz, 3 outputs c0/c1/c2)
  pll1.bsf               — PLL block symbol
  stm32_fmc_16bit.v.bak  — backup (bridge version, before register integration)

STM32/         — STM32CubeMX-generated project, builds with Keil MDK-ARM
  FMC_DEMO.ioc                  — CubeMX project file
  Core/Inc/dds.h                — DDS driver API + register address macros
  Core/Src/dds.c                — DDS implementation (LUT, FTW, USART cmd handler)
  Core/Src/main.c               — application entry point (DDS init + loop)
  Core/Src/stm32h7xx_it.c       — interrupt handlers (USART1_IRQHandler)
  Core/Src/fmc.c                — FMC peripheral init
  Core/Src/usart.c              — USART1 init (115200 8N1)
  Core/Src/gpio.c               — GPIO clock enables
  Core/Src/stm32h7xx_hal_msp.c  — HAL MSP
  MDK-ARM/FMC_DEMO.uvprojx      — Keil project file

聊天文件/      — design discussion notes (Chinese)
  init.md                      — project requirements and DDS design specs
  125M采样率正弦波范围.md        — DeepSeek chat log on DDS theory
  plan.md                      — development plan document
```

## FPGA Module Architecture

```
FMC_Demo.bdf (top-level schematic, user-maintained in Block Editor)
 │
 ├── pll1 (50MHz→125MHz×3)
 │    ├── c0 → all module clk (internal logic, 125MHz/0°)
 │    ├── c1 → DAC_CLK output pin (MUST be 125MHz/+90°=2000ps)
 │    └── c2 → spare
 │
 ├── stm32_fmc_16bit (FMC slave + address decoder + DDS registers)
 │    ├── FMC signals → 2-stage sync → cs_valid, user_wr_en, user_rd_en, user_addr
 │    ├── M9K RAM: 20000×16 (general register file, addr > 0x040C)
 │    ├── 0x0000-0x03FF: route to/from ram_2port1 Port A (waveform RAM)
 │    ├── 0x0400/0x0401: ftw_shadow[31:0] (shadow FTW registers)
 │    ├── 0x0404: update trigger → ftw_shadow → ftw_active (atomic load)
 │    ├── 0x0408: phase reset → phase_rst pulse to dds_core
 │    ├── 0x040C: DAC ctrl → dac_enable to dac_control
 │    └── Read data MUX: by address region (wf_rddata / ftw_lo / ftw_hi / dac_ctrl / M9K / 0)
 │
 ├── dds_core (32-bit phase accumulator)
 │    ├── ftw[31:0] ← ftw_active from stm32_fmc_16bit
 │    ├── phase_rst ← phase_rst pulse
 │    └── rd_addr[9:0] = phase_acc[31:22] → ram_2port1 rdaddress
 │
 ├── ram_2port1 (MegaWizard dual-port RAM, 1024×16, M9K)
 │    ├── Port A (write): wren ← wf_wren, address ← wf_wraddr, data ← wf_wrdata
 │    └── Port B (read): rdaddress ← dds_core.rd_addr, q[15:0] → dac_control + stm32_fmc_16bit
 │
 └── dac_control (DAC output pipeline)
      ├── wf_data[9:0] ← ram_2port1 q[9:0]
      ├── dac_enable ← dac_ctrl from stm32_fmc_16bit
      └── dac_data[9:0] → DAC_D[9:0] output pins
```

## FPGA Register Map (FMC address offsets)

| Offset | Size | R/W | Function |
|--------|------|-----|----------|
| 0x0000–0x03FF | 16-bit×1024 | R/W | Waveform RAM (10-bit data in bits[9:0], exists in ram_2port1) |
| 0x0400 | 16-bit×1 | R/W | FTW shadow[15:0] (low word) |
| 0x0401 | 16-bit×1 | R/W | FTW shadow[31:16] (high word) |
| 0x0404 | 16-bit×1 | W | Update enable (write 0x0001: load shadow FTW→active atomically) |
| 0x0408 | 16-bit×1 | W | Phase reset (write 0x0001: clear phase accumulator) |
| 0x040C | 16-bit×1 | R/W | DAC control (bit0=1 normal, bit0=0 force mid-scale 0x200) |
| 0x040D–0x4E1F | 16-bit each | R/W | M9K general register file |

## DDS Design Parameters

- DAC sample clock: 125 MHz
- Phase accumulator: 32 bits → resolution 125MHz/2^32 ≈ 0.0291 Hz
- Waveform RAM: 1024 points × 10-bit (addr = phase_acc[31:22])
- FTW formula: `FTW = round(f_target × 2^32 / 125_000_000)`
- Output: 0.029 Hz ~ 62.5 MHz (Nyquist), recommended ≤ 20 MHz
- DAC disabled state: mid-scale = 0x200 = 512

### FTW Reference Values (125MHz, 32-bit)

| f_target | FTW (decimal) | FTW (hex) |
|----------|--------------|-----------|
| 1 Hz | 34 | 0x00000022 |
| 10 Hz | 344 | 0x00000158 |
| 100 Hz | 3,436 | 0x00000D6C |
| 1 kHz | 34,360 | 0x00008638 |
| 10 kHz | 343,597 | 0x00053E0D |
| 100 kHz | 3,435,974 | 0x00346D90 |
| 1 MHz | 34,359,738 | 0x020C49BA |
| 10 MHz | 343,597,384 | 0x147AE148 |

## Build & Development Commands

### STM32 Firmware
- **IDE**: Keil MDK-ARM (`.uvprojx` at `STM32/MDK-ARM/FMC_DEMO.uvprojx`)
- **CubeMX**: Open `STM32/FMC_DEMO.ioc` to modify pin/peripheral config, then regenerate
- All user code inside `USER CODE BEGIN/END` comment blocks
- USART1 debug: 115200 8N1 on PB14 (TX) / PB15 (RX)

### FPGA
- **IDE**: Quartus II 14.1 (64-bit)
- **Project file**: `FPGA/FMC_Demo.qpf`
- Top-level is `FMC_Demo.bdf` (Block Editor schematic)
- Run `quartus_sh -t generate_bsf.tcl` to generate .bsf symbols after Verilog changes
- Or in GUI: right-click each .v file → "Create Symbol Files for Current File"

### BDF Integration Checklist (user must complete in Block Editor)
1. Run `generate_bsf.tcl` to create .bsf symbols for dds_core, dac_control, updated stm32_fmc_16bit
2. Place dds_core, dac_control, ram_2port1 symbols in the schematic
3. Wire all ports per the module architecture diagram above
4. Add DAC_D[9:0] and DAC_CLK output pins
5. Add DAC pin assignments in QSF (set_location_assignment)
6. Reconfigure PLL: c1 to 125MHz/+90° phase shift via MegaWizard

## Key Constraints & Gotchas

1. **Shadow register is mandatory**: STM32 writes 32-bit FTW as two 16-bit halves. Without shadow/update mechanism, the DDS core could see a half-updated FTW and output a glitch frequency. Solved: `__disable_irq() → LO → HI → __DMB() → UPDATE → __enable_irq()` in STM32; `ftw_shadow[31:0] → ftw_active[31:0]` atomic load in FPGA.

2. **Blocking vs non-blocking assignment**: In `always @(posedge clk)` blocks, always use `<=` (non-blocking). All new modules use correct `<=` assignments.

3. **FTW must match accumulator width**: Both are 32-bit. Verified consistent.

4. **FMC timing**: `AddressSetupTime=4, DataSetupTime=3, AddressHoldTime=15`. Must meet FPGA setup/hold at 125MHz.

5. **MPU config**: Region 0 covers `0x60000000` (256MB) with full access, non-cacheable, non-bufferable.

6. **Waveform RAM write safety**: `DDS_WriteWaveformRAM()` disables DAC before bulk write, re-enables after.

7. **CubeMX regeneration**: Code inside `USER CODE BEGIN/END` blocks is preserved; code outside is overwritten.

8. **PLL phase shift**: c1 must be +90° (2000ps at 125MHz) for correct AD9740 setup/hold timing. c0 (0°) drives internal logic. This requires re-running the PLL MegaWizard.

9. **DAC pins**: DAC_D[9:0] and DAC_CLK pin assignments must be added to QSF. These are not in the repo.
