#==========================================================
# FMC_Demo 时序约束 (SDC)
#==========================================================

# --- 主时钟 ---
create_clock -name clk_50m  -period 20   [get_ports CLK_50M]

# PLL 输出：c0=125MHz(内部/FMC/DDS), c1=125MHz/90°(DAC_CLK), c2=10MHz(ADC)
create_clock -name clk_125m -period 8    [get_pins pll1_inst|c0]
create_clock -name dac_clk  -period 8    [get_pins pll1_inst|c1]
create_clock -name adc_clk  -period 100  [get_pins pll1_inst|c2]

# --- 异步时钟组（不同源/不同域，不互相做路径分析）---
set_clock_groups -asynchronous \
    -group {clk_50m} \
    -group {clk_125m dac_clk} \
    -group {adc_clk}

# --- ADC 数据输入相对 adc_clk 的建立/保持（按 AD9220 数据手册 t_OD 调整）---
# AD9220: 输出数据在 CLK 上升沿后 t_OD(~13ns 典型)有效，保持 t_OH(~3ns)
# 此处先给保守值，用户实测后调整
set_input_delay -clock adc_clk -max  15 [get_ports {ADC_D[*]}]
set_input_delay -clock adc_clk -min   3 [get_ports {ADC_D[*]}]

# --- FMC 异步输入：经 stm32_fmc_16bit 内两级同步器，做 false path ---
# 同步器第一级直接采异步信号，不需做时序收敛
set_false_path -to [get_pins stm32_fmc_16bit:*|ne1_sync1*]
set_false_path -to [get_pins stm32_fmc_16bit:*|noe_sync1*]
set_false_path -to [get_pins stm32_fmc_16bit:*|nwe_sync1*]
set_false_path -to [get_pins stm32_fmc_16bit:*|addr_sync1*]

# --- 跨时钟域 CDC 路径（toggle 握手 + FIFO 指针同步）已被异步组覆盖 ---
# 显式对 ADC<->FMC 之间的多bit稳定总线 false-path（仅 toggle 变化时采样）
set_false_path -from [get_clocks clk_125m] -to [get_clocks adc_clk]
set_false_path -from [get_clocks adc_clk]  -to [get_clocks clk_125m]
