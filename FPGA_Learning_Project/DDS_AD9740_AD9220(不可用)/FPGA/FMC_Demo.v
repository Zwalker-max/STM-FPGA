/*********************************************************
* 顶层模块：FMC_Demo
* 功能：STM32H7 + FPGA DDS 任意波形发生器（AD9740）+ AD9220 ADC 采集
* 架构：
*   CLK_50M → pll1 → c0(125MHz/0°)  → 内部逻辑/FMC/DDS 时钟
*                    → c1(125MHz/90°) → DAC_CLK 输出（AD9740 建立/保持）
*                    → c2(10MHz/0°)   → ADC 采样时钟（AD9220）
*   STM32 ←→ stm32_fmc_16bit ←→ ram_2port1 ←→ dds_core
*                                      ↓
*                                 dac_control → DAC_D[9:0]
*   STM32 ←→ stm32_fmc_16bit(ADC 译码) ←→ async_fifo ←→ adc_decimator ← ADC_D[9:0]
*
* FMC_D 双向总线直接传入 stm32_fmc_16bit 处理（与原始 BDF 一致）
* ADC 子系统与 DDS 子系统地址独立、逻辑并行，互不影响
* FPGA：EP4CE10E22C8N
*
* 注意：pll1 需在 Quartus 中重新配置增加 c2=10MHz 输出（见聊天文件/plan.md 阶段1）
**********************************************************/

module FMC_Demo (
    // 系统时钟
    input wire          CLK_50M,

    // FMC 总线（连 STM32）
    input wire          FMC_NE1,
    input wire          FMC_NOE,
    input wire          FMC_NWE,
    input wire  [14:0]  FMC_A,
    inout wire  [15:0]  FMC_D,

    // DAC 输出（连 AD9740）
    output wire         DAC_CLK,
    output wire  [9:0]  DAC_D,

    // ADC 输入/输出（连 AD9220）
    output wire         ADC_CLK,        // 10MHz 采样时钟输出
    input  wire [9:0]   ADC_D           // AD9220 10 位并行数据
);

//===========================================================
// 上电复位（POR）
// 计数器在 50MHz 时钟域运行（PLL 可能未锁定，125MHz 不可靠）
// 1023 周期 ≈ 20μs，远超 Cyclone IV PLL 锁相时间（~10μs）
//===========================================================
reg  [9:0] por_cnt;
wire       sys_rst_n;

always @(posedge CLK_50M) begin
    if (por_cnt != 10'h3FF)
        por_cnt <= por_cnt + 10'd1;
end
assign sys_rst_n = (por_cnt == 10'h3FF);

//===========================================================
// 内部互联信号
//===========================================================
wire                clk_125m;       // PLL c0: 125MHz / 0° 内部逻辑时钟
wire                adc_clk_10m;    // PLL c2: 10MHz / 0° ADC 采样时钟

// stm32_fmc_16bit ↔ ram_2port1 (Port A)
wire                wf_wren;
wire    [9:0]       wf_addr;
wire    [15:0]      wf_wrdata;
wire    [15:0]      wf_rddata;

// stm32_fmc_16bit → dds_core
wire    [31:0]      ftw_active;
wire                phase_rst;

// stm32_fmc_16bit → dac_control
wire                /* synthesis keep */dac_enable;

// dds_core → ram_2port1 (Port B)
wire    [9:0]       rd_addr;

// ram_2port1 (Port B) → dac_control
wire    [15:0]      ram_q_b;

// stm32_fmc_16bit → adc_decimator（稳定总线 + toggle 握手）
wire    [31:0]      adc_step_bus;
wire                adc_en_bus;
wire                adc_step_toggle;
wire                adc_en_toggle;

// adc_decimator → async_fifo（写端，10MHz 域）
wire                fifo_wr_en;
wire    [15:0]      fifo_wr_data;

// stm32_fmc_16bit ↔ async_fifo（读端，125MHz 域）
wire                fifo_rd_en;
wire    [15:0]      fifo_q;
wire                fifo_empty;
wire                fifo_full;
wire    [9:0]       fifo_rdusedw;

// ADC 域复位（sys_rst_n 同步到 10MHz 域：异步assert 同步deassert）
reg [1:0] adc_rst_sync;
wire      adc_rst_n;

always @(posedge adc_clk_10m or negedge sys_rst_n) begin
    if (!sys_rst_n)
        adc_rst_sync <= 2'b00;
    else
        adc_rst_sync <= {adc_rst_sync[0], 1'b1};
end
assign adc_rst_n = adc_rst_sync[1];

//===========================================================
// PLL 例化（50MHz → c0=125MHz/0°, c1=125MHz/90°, c2=10MHz/0°）
// !! 用户须在 Quartus 中重新配置 pll1 增加 c2=10MHz 输出 !!
//===========================================================
pll1 pll1_inst (
    .inclk0 (CLK_50M),
    .c0     (clk_125m),
    .c1     (DAC_CLK),
    .c2     (adc_clk_10m)      // AD9220 采样时钟
);

assign ADC_CLK = adc_clk_10m;  // 引到顶层输出驱动 AD9220 CLKIN

//===========================================================
// FMC 从机接口 + 地址译码 + DDS/ADC 寄存器 + FIFO 读桥接
//===========================================================
stm32_fmc_16bit fmc_inst (
    .FMC_NE1    (FMC_NE1),
    .FMC_NOE    (FMC_NOE),
    .FMC_NWE    (FMC_NWE),
    .FMC_A      (FMC_A),
    .FMC_D      (FMC_D),

    .clk_125m   (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_wren    (wf_wren),
    .wf_addr    (wf_addr),
    .wf_wrdata  (wf_wrdata),
    .wf_rddata  (wf_rddata),

    .ftw_active (ftw_active),
    .phase_rst  (phase_rst),
    .dac_enable (dac_enable),

    // ADC 子系统
    .adc_step_bus    (adc_step_bus),
    .adc_en_bus      (adc_en_bus),
    .adc_step_toggle (adc_step_toggle),
    .adc_en_toggle   (adc_en_toggle),

    .fifo_rd_en   (fifo_rd_en),
    .fifo_q       (fifo_q),
    .fifo_empty   (fifo_empty),
    .fifo_full    (fifo_full),
    .fifo_rdusedw (fifo_rdusedw)
);

//===========================================================
// 双端口波形 RAM（1024 × 16）
// Port A：STM32 写 / 读    Port B：DDS 只读
//===========================================================
ram_2port1 ram_inst (
    .clk        (clk_125m),

    .wren_a     (wf_wren),
    .address_a  (wf_addr),
    .data_a     (wf_wrdata),
    .q_a        (wf_rddata),

    .address_b  (rd_addr),
    .q_b        (ram_q_b)
);

//===========================================================
// DDS 核心：32 位相位累加器
//===========================================================
dds_core dds_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .ftw        (ftw_active),
    .phase_rst  (phase_rst),
    .rd_addr    (rd_addr)
);

//===========================================================
// DAC 输出流水线
//===========================================================
dac_control dac_ctrl_inst (
    .clk        (clk_125m),
    .rst_n      (sys_rst_n),

    .wf_data    (ram_q_b[9:0]),
    .dac_enable (dac_enable),
    .dac_data   (DAC_D)
);

//===========================================================
// ADC 抽取累加器：10MHz 域 32 位相位累加器，溢出即写 FIFO
//===========================================================
adc_decimator adc_dec_inst (
    .clk          (adc_clk_10m),
    .rst_n        (adc_rst_n),

    .step_bus     (adc_step_bus),
    .en_bus       (adc_en_bus),
    .step_toggle  (adc_step_toggle),
    .en_toggle    (adc_en_toggle),

    .adc_data_in  (ADC_D),

    .fifo_wr_en   (fifo_wr_en),
    .fifo_wr_data (fifo_wr_data)
);

//===========================================================
// 异步 FIFO：10MHz 写域 → 125MHz 读域，16bit × 1024
//===========================================================
async_fifo fifo_inst (
    // 写端（10MHz ADC 域）
    .wrclk     (adc_clk_10m),
    .wrst_n    (adc_rst_n),
    .wr_en     (fifo_wr_en),
    .wr_data   (fifo_wr_data),
    .full      (fifo_full),
    .wrusedw   (),                  // 未使用

    // 读端（125MHz FMC 域）
    .rdclk     (clk_125m),
    .rrst_n    (sys_rst_n),
    .rd_en     (fifo_rd_en),
    .q         (fifo_q),
    .empty     (fifo_empty),
    .rdusedw   (fifo_rdusedw)
);

endmodule
