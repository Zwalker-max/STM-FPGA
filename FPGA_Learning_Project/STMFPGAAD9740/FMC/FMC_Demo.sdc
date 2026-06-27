# ============================================================
# FMC_Demo.sdc — Timing Constraints for FPGA DAC Controller
# Target: EP4CE10E22I7N (Cyclone IV E), Quartus II 14.1
# ============================================================

#=============================================================
# 1. 时钟约束
#=============================================================

# 50 MHz 外部晶振
create_clock -name CLK_50M -period 20.000 [get_ports CLK_50M]

# PLL 输出时钟 (由 altpll MegaWizard 自动约束)
#   C0: 125 MHz 系统时钟 → 同时直连 DAC_CLK 输出
derive_pll_clocks
derive_clock_uncertainty

#=============================================================
# 2. FMC 异步输入 (False Path)
#=============================================================
# FMC 控制/地址异步输入 — 由2级同步器保护，保持 false path
set_false_path -from [get_ports {FMC_NE1 FMC_NOE FMC_NWE FMC_A[*]}]
# FMC 数据输入 — 现在经过 user_wdata_reg 注册 → 需要时序约束
# (FMC_D[*] 已从 -from 列表中移除，使 input-to-register 路径受 125MHz 约束)
#
# FMC 数据输出 — FPGA 驱动总线供 STM32 异步读，保持 false path
set_false_path -to   [get_ports {FMC_D[*]}]

#=============================================================
# 3. 异步复位 (False Path)
#=============================================================
set_false_path -from [get_ports RST_N]

#=============================================================
# 4. DAC 输出时序 (AD9740, 125 MHz)
#    DAC_CLK:  PLL C0 直连 (125 MHz, 不经过逻辑)
#    DAC_DATA: clk_125m 下降沿更新
#    → 建立时间 ~4ns (半周期), AD9740 要求 ~2ns ✓
#=============================================================
set_output_delay -add_delay \
    -clock [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] \
    -max 2.0 [get_ports {DAC_DATA[*]}]
set_output_delay -add_delay \
    -clock [get_clocks {u_pll|altpll_component|auto_generated|pll1|clk[0]}] \
    -min -1.5 [get_ports {DAC_DATA[*]}]
