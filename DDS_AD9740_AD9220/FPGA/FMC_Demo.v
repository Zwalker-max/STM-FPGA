/*********************************************************
* 顶层模块：FMC_Demo
* 功能：STM32H7 + FPGA DDS 任意波形发生器（AD9740 DAC）
*       + AD9220 ADC 采集（12bit，10 MSPS）
* 架构：
*   CLK_50M → pll1 → c0(125MHz/0°) → 内部逻辑时钟
*                    → c1(125MHz/90°) → DAC_CLK 输出
*                    → c2(10MHz/0°)   → ADC_CLK 输出
*   STM32 ←→ stm32_fmc_16bit ←→ ram_2port1 ←→ dds_core
*                  ↓                   ↓
*             dac_control → DAC_D[9:0]
*
*   ADC_D[11:0] → adc_decimator → async_fifo → stm32_fmc_16bit
*                     ↑
*                adc_clk_10m (PLL c2)
*
* FMC_D 双向总线直接传入 stm32_fmc_16bit 处理（与原始 BDF 一致）
* FPGA：EP4CE10E22C8N
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

    // ADC 接口（连 AD9220）
    output wire         ADC_CLK,        // 10 MHz 采样时钟输出
    input  wire  [11:0] ADC_D           // 12-bit ADC 数据输入
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

// ADC 子系统信号
wire                adc_rst_n;          // ADC 域复位（sys_rst_n 两级同步到 10 MHz）
wire    [31:0]      adc_step_full;      // 32-bit 采样率步进值（125 MHz 域）
wire                adc_enable;         // ADC 使能（125 MHz 域）
wire                adc_step_toggle;    // 步进值更新 toggle（125 MHz 域）
wire                fifo_wr_en;         // FIFO 写使能（10 MHz 域）
wire    [15:0]      fifo_wdata;         // FIFO 写数据（ADC 采样，高 4 位补 0）
wire                fifo_rd_req;        // FIFO 读请求（125 MHz 域，单周期脉冲）
wire    [15:0]      fifo_q;             // FIFO 读数据（125 MHz 域）
wire                fifo_empty;         // FIFO 空标志
wire                fifo_full;          // FIFO 满标志
wire    [9:0]       fifo_rdusedw;       // FIFO 可读字数

// ADC 域复位同步器（sys_rst_n 从 50 MHz → 10 MHz，两级同步）
// ADC 控制信号同步器（adc_enable 为准静态，直接两级同步；adc_step_full 用 toggle CDC）
(* ASYNC_REG = "TRUE" *) reg [1:0] adc_rst_sync;
(* ASYNC_REG = "TRUE" *) reg [1:0] adc_enable_sync;             // adc_enable CDC：125 MHz → 10 MHz（两级同步）
(* ASYNC_REG = "TRUE" *) reg [1:0] adc_toggle_sync;             // adc_step_toggle CDC：125 MHz → 10 MHz（两级同步）
reg       adc_toggle_q;                // toggle 上一拍（边沿检测用）
reg [31:0] adc_step_full_10m;          // 32 位步进值（10 MHz 域，toggle 边沿时锁存）
reg        adc_enable_10m_synced;      // 使能（10 MHz 域，同步后）

always @(posedge adc_clk_10m or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        adc_rst_sync         <= 2'b00;
        adc_enable_sync      <= 2'b00;
        adc_toggle_sync      <= 2'b00;
        adc_toggle_q         <= 1'b0;
        adc_step_full_10m    <= 32'd0;
        adc_enable_10m_synced<= 1'b0;
    end else begin
        adc_rst_sync         <= {adc_rst_sync[0], 1'b1};
        adc_enable_sync      <= {adc_enable_sync[0], adc_enable};
        adc_toggle_sync      <= {adc_toggle_sync[0], adc_step_toggle};
        adc_toggle_q         <= adc_toggle_sync[1];
        // 检测 toggle 边沿 → 锁存 32 位步进值（此时 adc_step_full 已稳定）
        if (adc_toggle_sync[1] != adc_toggle_q)
            adc_step_full_10m <= adc_step_full;
        adc_enable_10m_synced<= adc_enable_sync[1];
    end
end
assign adc_rst_n = adc_rst_sync[1];

//===========================================================
// PLL 例化（50MHz → 125MHz/0° + 125MHz/90° + 10MHz/0°）
// PLL c2 已在 pll1.v 中配置（clk2_divide_by=5 → 10MHz / 0°）
//===========================================================
pll1 pll1_inst (
    .inclk0 (CLK_50M),
    .c0     (clk_125m),
    .c1     (DAC_CLK),
    .c2     (adc_clk_10m)
);

//===========================================================
// FMC 从机接口 + 地址译码 + DDS 寄存器 + ADC 寄存器
// FMC_D 直接传入模块内部处理三态（与原始 BDF 一致）
//===========================================================
stm32_fmc_16bit fmc_inst (
    .FMC_NE1    (FMC_NE1),
    .FMC_NOE    (FMC_NOE),
    .FMC_NWE    (FMC_NWE),
    .FMC_A      (FMC_A),
    .FMC_D      (FMC_D),

    .clk_125m   (clk_125m),
    .rst_n      (sys_rst_n),

    // 波形 RAM Port A
    .wf_wren    (wf_wren),
    .wf_addr    (wf_addr),
    .wf_wrdata  (wf_wrdata),
    .wf_rddata  (wf_rddata),

    // DDS 控制
    .ftw_active (ftw_active),
    .phase_rst  (phase_rst),
    .dac_enable (dac_enable),

    // ADC 控制（125 MHz 域 → 10 MHz 域 CDC 在顶层处理）
    .adc_step_full  (adc_step_full),
    .adc_enable     (adc_enable),
    .adc_step_toggle(adc_step_toggle),

    // FIFO 读接口
    .fifo_rd_req    (fifo_rd_req),
    .fifo_q         (fifo_q),
    .fifo_empty     (fifo_empty),
    .fifo_full      (fifo_full),
    .fifo_rdusedw   (fifo_rdusedw)
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
// ADC 时钟输出
//===========================================================
assign ADC_CLK = adc_clk_10m;

//===========================================================
// ADC 抽取器（32 位相位累加器，10 MHz 域）
// 输入使用两级同步后的准静态信号
//===========================================================
adc_decimator adc_dec_inst (
    .clk_10m    (adc_clk_10m),
    .rst_n      (adc_rst_n),

    .adc_d      (ADC_D),
    .step       (adc_step_full_10m),
    .enable     (adc_enable_10m_synced),

    .fifo_wr_en (fifo_wr_en),
    .fifo_wdata (fifo_wdata)
);

//===========================================================
// 异步 FIFO（写 10MHz / 读 125MHz）
//===========================================================
async_fifo fifo_inst (
    .wr_clk     (adc_clk_10m),
    .rd_clk     (clk_125m),

    .wr_en      (fifo_wr_en),
    .wr_data    (fifo_wdata),

    .rd_en      (fifo_rd_req),
    .rd_data    (fifo_q),

    .empty      (fifo_empty),
    .full       (fifo_full),
    .rdusedw    (fifo_rdusedw),

    .areset     (~sys_rst_n)    // 低有效 sys_rst_n → 高有效 areset
);

endmodule
