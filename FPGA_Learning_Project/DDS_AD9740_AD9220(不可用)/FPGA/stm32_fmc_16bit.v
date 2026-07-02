/*********************************************************
* 模块：STM32H7 FMC 异步从机接口
* 功能：FMC 总线同步 + 地址译码 + DDS 寄存器 + ADC 寄存器 + FIFO 读桥接
*       0x0000-0x03FF → ram_2port1 Port A（波形 RAM）          [DDS]
*       0x0400         → FTW shadow[15:0]                       [DDS]
*       0x0401         → FTW shadow[31:16]                      [DDS]
*       0x0404         → 更新触发（影子→活动 原子加载）          [DDS]
*       0x0408         → 相位复位脉冲                            [DDS]
*       0x040C         → DAC 控制寄存器                          [DDS]
*       0x1000         → ADC 控制（bit0=使能，可回读）           [ADC]
*       0x1001         → 采样率步进值 shadow[15:0]              [ADC]
*       0x1002         → 采样率步进值 shadow[31:16]             [ADC]
*       0x1003         → 步进更新触发（写1 装载+CDC 翻转）       [ADC]
*       0x1004         → FIFO 数据（只读，读一次弹一个）         [ADC]
*       0x1005         → FIFO 状态（只读：bit0空 bit1满 [11:2]usedw）[ADC]
*       （原 0x040D-0x4E1F M9K 通用寄存器组已删除，释放给 ADC 子系统）
* FPGA：EP4CE10E22
* FPGA时钟：125MHz（FMC/DDS 域）；ADC 域 10MHz 由 adc_decimator/async_fifo 处理
* FMC总线：16bit 数据 / 15bit 地址 / 无NBL / NE1 NOE NWE
*
* FMC_D 三态在本模块内部处理（与原始 BDF 设计一致）
* user_rd_en 延迟 1 周期对齐 ram_2port1 寄存读延迟
* ADC 步进/使能跨时钟域采用 "稳定总线 + toggle" 握手，由 adc_decimator 锁存
* FIFO 读采用上升沿单周期脉冲（rd_and & ~rd_and_q），保证一次 FMC 读只弹一个
**********************************************************/

module stm32_fmc_16bit (
    //FMC 硬件接口
    input wire          FMC_NE1,        //片选 低有效
    input wire          FMC_NOE,        //读使能 低有效
    input wire          FMC_NWE,        //写使能 低有效
    input wire [14:0]   FMC_A,          //15bit 地址
    inout wire [15:0]   FMC_D,          //16bit 双向数据

    //FPGA 125MHz 时钟（必须来自PLL，不是外部50M直接输入）
    input wire          clk_125m,
    input wire          rst_n,          //低电平复位

    //波形 RAM Port A 接口（连到 ram_2port1）
    output wire             wf_wren,
    output wire  [9:0]     wf_addr,
    output wire  [15:0]    wf_wrdata,
    input  wire  [15:0]    wf_rddata,

    //DDS 子系统控制输出
    output wire  [31:0]    ftw_active,
    output wire             phase_rst,
    output wire             dac_enable,

    //ADC 子系统：稳定总线 + toggle 握手（跨到 10MHz 域由 adc_decimator 锁存）
    output wire  [31:0]    adc_step_bus,
    output wire             adc_en_bus,
    output wire             adc_step_toggle,
    output wire             adc_en_toggle,

    //ADC 子系统：FIFO 读端口（读时钟 = 125MHz FMC 域）
    output wire             fifo_rd_en,
    input  wire  [15:0]    fifo_q,
    input  wire             fifo_empty,
    input  wire             fifo_full,
    input  wire  [9:0]     fifo_rdusedw
);

//---------------------------------------------------
//异步控制信号 两级同步（防亚稳态）
//---------------------------------------------------
reg ne1_sync1, ne1_sync2;
reg noe_sync1, noe_sync2;
reg nwe_sync1, nwe_sync2;
reg [14:0] addr_sync1, addr_sync2;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ne1_sync1 <= 1'b1;
        ne1_sync2 <= 1'b1;
        noe_sync1 <= 1'b1;
        noe_sync2 <= 1'b1;
        nwe_sync1 <= 1'b1;
        nwe_sync2 <= 1'b1;
        addr_sync1 <= 15'd0;
        addr_sync2 <= 15'd0;
    end else begin
        ne1_sync1 <= FMC_NE1;
        ne1_sync2 <= ne1_sync1;
        noe_sync1 <= FMC_NOE;
        noe_sync2 <= noe_sync1;
        nwe_sync1 <= FMC_NWE;
        nwe_sync2 <= nwe_sync1;
        addr_sync1 <= FMC_A;
        addr_sync2 <= addr_sync1;
    end
end

//---------------------------------------------------
//读写使能（稳定无毛刺）
//---------------------------------------------------
wire cs_valid    = ~ne1_sync2;
wire user_wr_en  = cs_valid & ~nwe_sync2;
wire user_rd_en  = cs_valid & ~noe_sync2;
wire [14:0] user_addr = addr_sync2;

//---------------------------------------------------
//三态总线控制（在模块内部处理，与原始 BDF 一致）
//---------------------------------------------------
reg [15:0] user_rdata;
assign FMC_D = user_rd_en ? user_rdata : 16'hzzzz;
wire [15:0] user_wdata = FMC_D;

//---------------------------------------------------
//地址译码
//---------------------------------------------------
wire is_wf_ram       = (user_addr[14:10] == 5'd0);   // 0x0000-0x03FF
wire is_ftw_lo       = (user_addr == 15'h0400);      // FTW 低16位
wire is_ftw_hi       = (user_addr == 15'h0401);      // FTW 高16位
wire is_update       = (user_addr == 15'h0404);      // 更新触发
wire is_ph_rst       = (user_addr == 15'h0408);      // 相位复位
wire is_dac_ctrl     = (user_addr == 15'h040C);      // DAC 控制

wire is_adc_ctrl     = (user_addr == 15'h1000);      // ADC 控制
wire is_adc_step_lo  = (user_addr == 15'h1001);      // 步进低16
wire is_adc_step_hi  = (user_addr == 15'h1002);      // 步进高16
wire is_adc_step_upd = (user_addr == 15'h1003);      // 步进更新触发
wire is_adc_fifo_dat = (user_addr == 15'h1004);      // FIFO 数据
wire is_adc_fifo_st  = (user_addr == 15'h1005);      // FIFO 状态

//---------------------------------------------------
//波形 RAM 桥接（地址 0x0000-0x03FF → ram_2port1 Port A）
//---------------------------------------------------
assign wf_wren   = user_wr_en & is_wf_ram;
assign wf_addr   = user_addr[9:0];
assign wf_wrdata = user_wdata;

//---------------------------------------------------
//DDS 控制寄存器
//---------------------------------------------------
reg [31:0] ftw_shadow;
reg [31:0] ftw_active_reg;
reg        phase_rst_reg;
reg        dac_enable_reg;

//---------------------------------------------------
//ADC 控制寄存器（影子 + toggle）
//---------------------------------------------------
reg [31:0] adc_step_shadow;
reg        adc_en_reg;
reg        adc_step_toggle_reg;
reg        adc_en_toggle_reg;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ftw_shadow        <= 32'd0;
        ftw_active_reg    <= 32'd0;
        phase_rst_reg     <= 1'b0;
        dac_enable_reg    <= 1'b0;

        adc_step_shadow      <= 32'd0;
        adc_en_reg           <= 1'b0;
        adc_step_toggle_reg  <= 1'b0;
        adc_en_toggle_reg    <= 1'b0;
    end else begin
        // 相位复位脉冲自清除
        phase_rst_reg <= 1'b0;

        if (user_wr_en) begin
            // ---- DDS ----
            if (is_ftw_lo)
                ftw_shadow[15:0]  <= user_wdata;
            else if (is_ftw_hi)
                ftw_shadow[31:16] <= user_wdata;
            else if (is_update)
                ftw_active_reg    <= ftw_shadow;
            else if (is_ph_rst)
                phase_rst_reg     <= 1'b1;
            else if (is_dac_ctrl)
                dac_enable_reg    <= user_wdata[0];

            // ---- ADC ----
            else if (is_adc_step_lo)
                adc_step_shadow[15:0]  <= user_wdata;
            else if (is_adc_step_hi)
                adc_step_shadow[31:16] <= user_wdata;
            else if (is_adc_step_upd)
                adc_step_toggle_reg    <= ~adc_step_toggle_reg;   // 翻转，通知 ADC 域锁存
            else if (is_adc_ctrl) begin
                adc_en_reg             <= user_wdata[0];
                adc_en_toggle_reg      <= ~adc_en_toggle_reg;     // 每次写都翻转
            end
        end
    end
end

//---------------------------------------------------
//FIFO 读脉冲：上升沿单周期（保证一次 FMC 读只弹一个）
//---------------------------------------------------
reg rd_and_q;
wire rd_and = user_rd_en & is_adc_fifo_dat;
assign fifo_rd_en = rd_and & ~rd_and_q;     // 仅在 rd_and 由0→1 当拍为高

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n)
        rd_and_q <= 1'b0;
    else
        rd_and_q <= rd_and;
end

//---------------------------------------------------
//读数据 MUX（组合逻辑）
//---------------------------------------------------
wire [15:0] fifo_status = {4'd0, fifo_rdusedw[9:0], fifo_full, fifo_empty};

always @(*) begin
    if (is_wf_ram)
        user_rdata = wf_rddata;
    else if (is_ftw_lo)
        user_rdata = ftw_shadow[15:0];
    else if (is_ftw_hi)
        user_rdata = ftw_shadow[31:16];
    else if (is_dac_ctrl)
        user_rdata = {15'd0, dac_enable_reg};
    else if (is_adc_ctrl)
        user_rdata = {15'd0, adc_en_reg};
    else if (is_adc_fifo_dat)
        user_rdata = fifo_q;                 // FIFO 寄存化输出（读后下一周期有效，FMC 异步读足够慢）
    else if (is_adc_fifo_st)
        user_rdata = fifo_status;
    else
        user_rdata = 16'd0;
end

//---------------------------------------------------
//状态输出
//---------------------------------------------------
assign ftw_active      = ftw_active_reg;
assign phase_rst       = phase_rst_reg;
assign dac_enable      = dac_enable_reg;

assign adc_step_bus    = adc_step_shadow;
assign adc_en_bus      = adc_en_reg;
assign adc_step_toggle = adc_step_toggle_reg;
assign adc_en_toggle   = adc_en_toggle_reg;

endmodule
