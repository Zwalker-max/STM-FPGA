# BDF Wiring Guide (供 Block Editor 连线参考)

## Step 1: 生成 BSF 符号
在 Quartus II 中运行：
```
Tools → Tcl Scripts → 运行 generate_bsf.tcl
```
或分别右键 dds_core.v / dac_control.v / stm32_fmc_16bit.v → Create Symbol Files

## Step 2: PLL 输出
| PLL 引脚 | 频率 | 相移 | 用途 |
|----------|------|------|------|
| c0 | 125MHz | 0° | 内部逻辑时钟 (stm32_fmc_16bit, dds_core, dac_control, ram_2port1) |
| c1 | 125MHz | +90° (2000ps) | DAC_CLK 输出引脚 (满足 AD9740 建立/保持时序) |
| c2 | 125MHz | 0° | 备用 |

**重要**: 需要在 MegaWizard 中重新配置 PLL，将 c1 相移从 0 改为 +90°。

## Step 3: 完整连线表

### 时钟网络 (所有模块共享)
```
pll1|c0  ────┬── stm32_fmc_16bit|clk_125m
              ├── dds_core|clk
              ├── dac_control|clk
              └── ram_2port1|clock
```
(在 BDF 中用 4 条线从 c0 连到各模块的 clk/clock 输入)

### 复位
```
顶层输入引脚 ────┬── stm32_fmc_16bit|rst_n
                  ├── dds_core|rst_n
                  └── dac_control|rst_n
```
(如果没有外部复位引脚，可以接 VCC = 永远不复位)

### FMC 总线 (已在原 BDF 中连接，保持不变)
```
FMC_NE1, FMC_NOE, FMC_NWE, FMC_A[14..0], FMC_D[15..0]
→ stm32_fmc_16bit|FMC_NE1/FMC_NOE/FMC_NWE/FMC_A/FMC_D
```

### DDS 控制路径
```
stm32_fmc_16bit|ftw_active[31..0]  ───→ dds_core|ftw[31..0]
stm32_fmc_16bit|phase_rst          ───→ dds_core|phase_rst
```

### 波形 RAM 写路径 (FMC → RAM)
```
stm32_fmc_16bit|wf_wren            ───→ ram_2port1|wren
stm32_fmc_16bit|wf_wraddr[9..0]   ───→ ram_2port1|wraddress[9..0]
stm32_fmc_16bit|wf_wrdata[15..0]  ───→ ram_2port1|data[15..0]
```

### 波形 RAM 读路径 (DDS → RAM)
```
dds_core|rd_addr[9..0]            ───→ ram_2port1|rdaddress[9..0]
```

### RAM 输出分发
```
ram_2port1|q[15..0] ────┬── stm32_fmc_16bit|wf_rddata[15..0]  (FMC回读全16位)
                         └── dac_control|wf_data[9..0]           (DAC只需低10位)
```

### DAC 控制与输出
```
stm32_fmc_16bit|dac_ctrl          ───→ dac_control|dac_enable
dac_control|dac_data[9..0]       ───→ 顶层输出引脚 DAC_D[9..0]
```

### DAC 时钟输出
```
pll1|c1                          ───→ 顶层输出引脚 DAC_CLK
```

## Step 4: QSF 引脚分配 (示例)

```tcl
# DAC 数据输出 (用户根据实际 PCB 连接修改引脚号)
set_location_assignment PIN_?? -to DAC_D[9]
set_location_assignment PIN_?? -to DAC_D[8]
set_location_assignment PIN_?? -to DAC_D[7]
set_location_assignment PIN_?? -to DAC_D[6]
set_location_assignment PIN_?? -to DAC_D[5]
set_location_assignment PIN_?? -to DAC_D[4]
set_location_assignment PIN_?? -to DAC_D[3]
set_location_assignment PIN_?? -to DAC_D[2]
set_location_assignment PIN_?? -to DAC_D[1]
set_location_assignment PIN_?? -to DAC_D[0]

# DAC 时钟输出
set_location_assignment PIN_?? -to DAC_CLK

# IO 电平标准 (AD9740 数字供电通常 3.3V)
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_D[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to DAC_CLK
```

## 联调步骤

1. **BDF 连线** → 编译 → 确认无语法/综合错误
2. **下载 FPGA** → STM32 上电 → USART 收到 "=== DDS_AD9740 Startup ===" 消息
3. **波形验证**: 发送 `VW` 命令 → 应返回 "OK: Waveform verified"
4. **频率查询**: 发送 `QF` → 应返回 ~1kHz
5. **示波器探头接到 DAC_D[9:0] 引脚** → 观察 1kHz 正弦波
6. **频率切换**: 发送 `F 10000` → 示波器确认 10kHz
7. **DAC 控制**: 发送 `DD` → 输出下降到中间电平；`DE` → 恢复
