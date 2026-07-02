/*********************************************************
* 模块：STM32H7 FMC 异步从机接口
* 功能：FMC 总线同步 + 地址译码 + DDS 寄存器 + ADC 寄存器 + 波形 RAM 桥接
*
* 地址映射（16 位字地址）：
*   DDS 子系统（保持原有）：
*     0x0000-0x03FF → ram_2port1 Port A（波形 RAM）
*     0x0400         → FTW shadow[15:0]
*     0x0401         → FTW shadow[31:16]
*     0x0404         → 更新触发（影子→活动 原子加载）
*     0x0408         → 相位复位脉冲
*     0x040C         → DAC 控制寄存器
*   ADC 子系统（新增）：
*     0x1000         → ADC 控制寄存器（bit0 = enable）
*     0x1001         → ADC 步进值低 16 位（只写）
*     0x1002         → ADC 步进值高 16 位（只写）
*     0x1003         → 步进更新触发（写 1 原子装载）
*     0x1004         → FIFO 数据端口（只读，读=弹出）
*     0x1005         → FIFO 状态寄存器（只读）
* FPGA：EP4CE10E22
* FPGA时钟：125MHz
* FMC总线：16bit 数据 / 15bit 地址 / 无NBL / NE1 NOE NWE
*
* FMC_D 三态在本模块内部处理（与原始 BDF 设计一致）
* user_rd_en 延迟 1 周期对齐 ram_2port1 寄存读延迟
*
* ADC CDC：步进值和使能位通过 toggle-ack 握手机制从 125 MHz
*          同步到 10 MHz ADC 域
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

    //ADC 子系统控制输出（125 MHz 域，准静态 → 顶层 CDC 到 10 MHz 域）
    output wire  [31:0]    adc_step_full,
    output wire             adc_enable,
    output wire             adc_step_toggle,   // 每次步进更新时翻转

    //FIFO 读接口（125 MHz 域）
    output wire             fifo_rd_req,    //单周期脉冲
    input  wire  [15:0]    fifo_q,         //FIFO 读数据
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
// DDS 原有译码
wire is_wf_ram   = (user_addr[14:10] == 5'd0);        // 0x0000-0x03FF
wire is_ftw_lo   = (user_addr == 15'h0400);          // FTW 低16位
wire is_ftw_hi   = (user_addr == 15'h0401);          // FTW 高16位
wire is_update   = (user_addr == 15'h0404);          // 更新触发
wire is_ph_rst   = (user_addr == 15'h0408);          // 相位复位
wire is_dac_ctrl = (user_addr == 15'h040C);          // DAC 控制

// ADC 新增译码
wire is_adc_ctrl       = (user_addr == 15'h1000);    // ADC 控制
wire is_adc_step_lo    = (user_addr == 15'h1001);    // 步进值低16位
wire is_adc_step_hi    = (user_addr == 15'h1002);    // 步进值高16位
wire is_adc_step_update= (user_addr == 15'h1003);    // 步进更新触发
wire is_adc_fifo_data  = (user_addr == 15'h1004);    // FIFO 数据（只读）
wire is_adc_fifo_status= (user_addr == 15'h1005);    // FIFO 状态（只读）

//---------------------------------------------------
//波形 RAM 桥接（地址 0x0000-0x03FF → ram_2port1 Port A）
//---------------------------------------------------
assign wf_wren   = user_wr_en & is_wf_ram;
assign wf_addr   = user_addr[9:0];
assign wf_wrdata = user_wdata;

//---------------------------------------------------
//DDS 控制寄存器（保持原有逻辑不变）
//---------------------------------------------------
reg [31:0] ftw_shadow;
reg [31:0] ftw_active_reg;
reg        phase_rst_reg;
reg        dac_enable_reg;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ftw_shadow     <= 32'd0;
        ftw_active_reg <= 32'd0;
        phase_rst_reg  <= 1'b0;
        dac_enable_reg <= 1'b0;
    end else begin
        // 相位复位脉冲自清除
        phase_rst_reg <= 1'b0;

        if (user_wr_en) begin
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
        end
    end
end

//---------------------------------------------------
//ADC 控制寄存器（125 MHz 域影子寄存器 → 输出到 10 MHz 域）
// adc_enable 和 adc_step_full 是准静态信号（仅 STM32 写时变化），
// 在顶层通过两级同步器进入 10 MHz 域即可
//---------------------------------------------------
reg [15:0] adc_step_lo_shadow;
reg [15:0] adc_step_hi_shadow;
reg        adc_step_lo_written;   // 标记：低 16 已写入
reg        adc_ctrl_reg;          // ADC 使能
reg [31:0] adc_step_full_reg;     // 完整步进值
reg        adc_step_toggle_reg;   // toggle 信号，每次步进更新时翻转

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        adc_step_lo_shadow  <= 16'd0;
        adc_step_hi_shadow  <= 16'd0;
        adc_step_lo_written <= 1'b0;
        adc_ctrl_reg        <= 1'b0;
        adc_step_full_reg   <= 32'd0;
        adc_step_toggle_reg <= 1'b0;
    end else begin
        if (user_wr_en) begin
            if (is_adc_ctrl) begin
                adc_ctrl_reg <= user_wdata[0];
            end
            else if (is_adc_step_lo) begin
                adc_step_lo_shadow  <= user_wdata;
                adc_step_lo_written <= 1'b1;
            end
            else if (is_adc_step_hi) begin
                adc_step_hi_shadow  <= user_wdata;
            end
            else if (is_adc_step_update && (user_wdata == 16'd1)) begin
                // 原子装载：组合 32 位步进值，翻转 toggle
                if (adc_step_lo_written) begin
                    adc_step_full_reg  <= {adc_step_hi_shadow, adc_step_lo_shadow};
                    adc_step_toggle_reg <= ~adc_step_toggle_reg;
                    adc_step_lo_written <= 1'b0;
                end
            end
        end
    end
end

// 准静态信号输出（adc_enable 可直接两级同步；adc_step_full 通过 toggle CDC）
assign adc_step_full   = adc_step_full_reg;
assign adc_enable      = adc_ctrl_reg;
assign adc_step_toggle = adc_step_toggle_reg;

//---------------------------------------------------
//FIFO 读请求生成（125 MHz 域）
// 当 STM32 读 fifo_data 地址时产生单周期脉冲
// 使用边沿检测：rd_and = user_rd_en & is_adc_fifo_data
//---------------------------------------------------
reg rd_and_q;
wire rd_and;
assign rd_and = user_rd_en & is_adc_fifo_data;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        rd_and_q <= 1'b0;
    end else begin
        rd_and_q <= rd_and;
    end
end

// 上升沿检测 → 单周期脉冲
assign fifo_rd_req = rd_and & ~rd_and_q;

//---------------------------------------------------
//读数据 MUX（组合逻辑）
//---------------------------------------------------
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
        user_rdata = {15'd0, adc_ctrl_reg};
    else if (is_adc_step_lo)
        user_rdata = adc_step_lo_shadow;
    else if (is_adc_step_hi)
        user_rdata = adc_step_hi_shadow;
    else if (is_adc_fifo_data)
        user_rdata = fifo_q;
    else if (is_adc_fifo_status)
        // bit0=empty, bit1=full, bits[11:2]=rdusedw
        user_rdata = {4'd0, fifo_rdusedw, fifo_full, fifo_empty};
    else
        user_rdata = 16'd0;
end

//---------------------------------------------------
//状态输出到 DDS 子系统
//---------------------------------------------------
assign ftw_active = ftw_active_reg;
assign phase_rst  = phase_rst_reg;
assign dac_enable = dac_enable_reg;

endmodule
