# ============================================================
# FMC_Demo SDC 时序约束文件
# 项目：STM32H7 + FPGA DDS + AD9220 ADC
# FPGA：EP4CE10E22C8N (Cyclone IV E)
# ============================================================

# ------------------------------------------------------------
# 1. 输入时钟定义
# ------------------------------------------------------------
# 板载 50 MHz 晶振 → FPGA PIN_23
create_clock -name clk_50m_in -period 20.000 [get_ports {CLK_50M}]

# ------------------------------------------------------------
# 2. PLL 输出时钟
#    ALTPLL 在 Cyclone IV 上需手动创建 generated clocks
#    pll1 参数：50M in → c0=125MHz/0°, c1=125MHz/90°, c2=10MHz/0°
# ------------------------------------------------------------

# PLL c0: 125 MHz / 0°（内部逻辑 + FMC 接口时钟）
create_generated_clock -name clk_125m_0deg \
    -source [get_ports {CLK_50M}] \
    -master_clock clk_50m_in \
    -multiply_by 5 \
    -divide_by 2 \
    [get_pins {pll1_inst|altpll_component|auto_generated|pll1|clk[0]}]

# PLL c1: 125 MHz / 90°（DAC_CLK 输出）
create_generated_clock -name clk_125m_90deg \
    -source [get_ports {CLK_50M}] \
    -master_clock clk_50m_in \
    -multiply_by 5 \
    -divide_by 2 \
    -phase 90 \
    [get_ports {DAC_CLK}]

# PLL c2: 10 MHz / 0°（ADC_CLK 输出 → AD9220）
create_generated_clock -name adc_clk_10m \
    -source [get_ports {CLK_50M}] \
    -master_clock clk_50m_in \
    -divide_by 5 \
    [get_ports {ADC_CLK}]

# ------------------------------------------------------------
# 3. 异步时钟组
#    125 MHz 域（clk_125m_0deg, clk_125m_90deg）与 10 MHz 域
#    （adc_clk_10m）完全异步。CDC 通过两级同步器处理。
#    50 MHz 输入晶振也与这些域异步（仅上电复位用）。
# ------------------------------------------------------------
set_clock_groups -asynchronous \
    -group {clk_50m_in} \
    -group {clk_125m_0deg clk_125m_90deg} \
    -group {adc_clk_10m}

# ------------------------------------------------------------
# 4. ADC 输入延迟（AD9220 ADC_D[11:0] 相对 adc_clk_10m）
#    AD9220 数据手册：Tpd_max ≈ 13 ns, Tpd_min ≈ 3 ns
#    保守约束：max=15 ns, min=1 ns（相对于 ADC_CLK 上升沿）
# ------------------------------------------------------------
set_input_delay -clock adc_clk_10m -max 15.000 \
    [get_ports {ADC_D[*]}]
set_input_delay -clock adc_clk_10m -min 1.000 \
    [get_ports {ADC_D[*]}]

# ------------------------------------------------------------
# 5. FMC 接口约束（来自 STM32 的异步输入）
#    STM32H7 FMC Bank1 NE1, 异步 SRAM 模式 A, 16-bit 数据
#    FMC 控制信号在 FPGA 内部用 125 MHz 时钟两级同步。
#    因 FMC 是异步接口，使用宽松约束避免误报。
#    约束参考 125 MHz 捕获时钟（8 ns 周期）。
# ------------------------------------------------------------
set_input_delay -clock clk_125m_0deg -max 8.000 \
    [get_ports {FMC_NE1 FMC_NOE FMC_NWE FMC_A[*] FMC_D[*]}]
set_input_delay -clock clk_125m_0deg -min -1.000 \
    [get_ports {FMC_NE1 FMC_NOE FMC_NWE FMC_A[*] FMC_D[*]}]

# ------------------------------------------------------------
# 6. 全局约束
# ------------------------------------------------------------
# 不进行过度约束，避免工具浪费布线资源。
# 跨时钟域路径已在时钟组中声明为异步，如有遗留违例手动豁免：
# set_false_path -from [get_clocks {clk_125m_0deg}] -to [get_clocks {adc_clk_10m}]
# set_false_path -from [get_clocks {adc_clk_10m}] -to [get_clocks {clk_125m_0deg}]
