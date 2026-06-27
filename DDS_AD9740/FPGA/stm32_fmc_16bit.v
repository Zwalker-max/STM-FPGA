/*********************************************************
* 模块：STM32H7 FMC 异步从机接口（带地址译码 + DDS控制寄存器）
* 功能：FMC信号同步、地址译码、M9K通用寄存器组、DDS控制
* FPGA：EP4CE10E22
* FPGA时钟：125MHz
* FMC总线：16bit 数据 / 15bit 地址 / NE1 NOE NWE
*
* 寄存器地址映射（FMC偏移地址）：
*   0x0000 ~ 0x03FF : 波形RAM（1024字，经 wf_* 端口路由到外部 ram_2port1）
*   0x0400         : FTW[15:0]（32位频率控制字，低16位）
*   0x0401         : FTW[31:16]（高16位）
*   0x0404         : 更新使能（写1加载ftw_shadow→ftw_active）
*   0x0408         : 相位复位（写1清零相位累加器）
*   0x040C         : DAC控制（bit0=1正常输出，0=强制中间值0x200）
*   0x040D ~ 0x4E1F: M9K通用寄存器（32K-32个16位，与旧代码兼容）
**********************************************************/
module stm32_fmc_16bit (
    //====== FMC 硬件接口 ======
    input  wire          FMC_NE1,       //片选 低有效
    input  wire          FMC_NOE,       //读使能 低有效
    input  wire          FMC_NWE,       //写使能 低有效
    input  wire [14:0]   FMC_A,         //15bit 地址
    inout  wire [15:0]   FMC_D,         //16bit 数据

    //====== 时钟和复位 ======
    input  wire          clk_125m,      //125MHz（必须来自PLL）
    input  wire          rst_n,         //低电平复位

    //====== 波形RAM接口（到外部 ram_2port1） ======
    output wire          wf_wren,       //波形RAM写使能
    output wire [9:0]    wf_wraddr,     //波形RAM写地址
    output wire [15:0]   wf_wrdata,     //波形RAM写数据
    input  wire [15:0]   wf_rddata,     //波形RAM读数据（用于FMC回读校验）

    //====== DDS控制输出 ======
    output wire [31:0]   ftw_active,    //活跃频率控制字（到dds_core）
    output wire          phase_rst,     //相位复位脉冲（到dds_core，高有效1周期）
    output wire          dac_ctrl/* synthesis keep */       //DAC使能（到dac_control，1=正常，0=中间值）
);

//===========================================================
// 1. 异步控制信号 两级同步（防亚稳态）
//===========================================================
reg        ne1_sync1, ne1_sync2;
reg        noe_sync1, noe_sync2;
reg        nwe_sync1, nwe_sync2;
reg [14:0] addr_sync1, addr_sync2;

always @(posedge clk_125m or negedge rst_n) begin
    if(!rst_n) begin
        ne1_sync1  <= 1'b1;
        ne1_sync2  <= 1'b1;
        noe_sync1  <= 1'b1;
        noe_sync2  <= 1'b1;
        nwe_sync1  <= 1'b1;
        nwe_sync2  <= 1'b1;
        addr_sync1 <= 15'd0;
        addr_sync2 <= 15'd0;
    end else begin
        ne1_sync1  <= FMC_NE1;
        ne1_sync2  <= ne1_sync1;
        noe_sync1  <= FMC_NOE;
        noe_sync2  <= noe_sync1;
        nwe_sync1  <= FMC_NWE;
        nwe_sync2  <= nwe_sync1;
        addr_sync1 <= FMC_A;
        addr_sync2 <= addr_sync1;
    end
end

//===========================================================
// 2. 读写控制信号
//===========================================================
wire cs_valid   = ~ne1_sync2;
wire user_wr_en = cs_valid & ~nwe_sync2;
wire user_rd_en = cs_valid & ~noe_sync2;
wire [14:0] user_addr = addr_sync2;

//===========================================================
// 3. 三态总线控制
//===========================================================
reg  [15:0] user_rdata;
assign FMC_D = user_rd_en ? user_rdata : 16'hzzzz;
wire [15:0] user_wdata = FMC_D;

//===========================================================
// 4. 地址译码（根据寄存器映射表）
//===========================================================
wire is_wram      = (user_addr[14:10] == 5'd0);             // 0x0000 - 0x03FF
wire is_ftw_lo    = (user_addr == 15'h0400);
wire is_ftw_hi    = (user_addr == 15'h0401);
wire is_update    = (user_addr == 15'h0404);
wire is_phase_rst = (user_addr == 15'h0408);
wire is_dac_ctrl  = (user_addr == 15'h040C);
wire is_m9k       = ~is_wram & ~is_ftw_lo & ~is_ftw_hi
                  & ~is_update & ~is_phase_rst & ~is_dac_ctrl;

//写使能（每个区域的独立写选通）
wire wram_wr      = user_wr_en & is_wram;
wire ftw_lo_wr    = user_wr_en & is_ftw_lo;
wire ftw_hi_wr    = user_wr_en & is_ftw_hi;
wire update_en    = user_wr_en & is_update & user_wdata[0];
wire phase_rst_wr = user_wr_en & is_phase_rst & user_wdata[0];
wire dac_ctrl_wr  = user_wr_en & is_dac_ctrl;

//===========================================================
// 5. M9K 通用寄存器组（20000×16bit）
//    注意：地址 0x0000-0x03FF 不写入M9K，走外部波形RAM
//===========================================================
(* ramstyle = "M9K" *) reg [15:0] m9k_ram [0:19999];

always @(posedge clk_125m) begin
    if(user_wr_en & is_m9k) begin
        m9k_ram[user_addr] <= user_wdata;
    end
end

//===========================================================
// 6. 波形RAM写端口路由（到外部 ram_2port1）
//===========================================================
assign wf_wren   = wram_wr;
assign wf_wraddr = user_addr[9:0];
assign wf_wrdata = user_wdata;      //ram_2port1是16bit宽，DDS只用[9:0]

//===========================================================
// 7. DDS 控制寄存器
//===========================================================
reg [31:0] ftw_shadow;       //影子寄存器（STM32直接写）
reg [31:0] ftw_active_reg;   //工作寄存器（更新使能后加载）
reg        dac_ctrl_reg;     //DAC控制（1=正常，0=中间值）
reg        phase_rst_prev;   //相位复位边沿检测

assign ftw_active   = ftw_active_reg;
assign phase_rst    = phase_rst_wr & ~phase_rst_prev;

// dac_ctrl：加一级寄存器输出，防止综合器优化跨模块控制信号
reg dac_ctrl_out;
assign dac_ctrl = dac_ctrl_out;

always @(posedge clk_125m or negedge rst_n) begin
    if(!rst_n) begin
        ftw_shadow     <= 32'd0;
        ftw_active_reg <= 32'd0;
        dac_ctrl_reg   <= 1'b1;       //默认DAC使能
        dac_ctrl_out   <= 1'b1;
        phase_rst_prev <= 1'b0;
    end else begin
        //FTW影子寄存器：两半独立写入，顺序无要求
        if(ftw_lo_wr)   ftw_shadow[15:0]  <= user_wdata;
        if(ftw_hi_wr)   ftw_shadow[31:16] <= user_wdata;

        //更新使能：写1将影子寄存器原子加载到工作寄存器
        if(update_en)   ftw_active_reg <= ftw_shadow;

        //DAC控制
        if(dac_ctrl_wr) dac_ctrl_reg <= user_wdata[0];

        //DAC控制寄存器输出（已注册，防综合器优化）
        dac_ctrl_out <= dac_ctrl_reg;

        //相位复位边沿检测（保存上一拍的值）
        if(phase_rst_wr) phase_rst_prev <= 1'b1;
        else             phase_rst_prev <= 1'b0;
    end
end

//===========================================================
// 8. 读数据多路选择
//===========================================================
always @(*) begin
    if(is_wram)          user_rdata = wf_rddata;           //从外部ram_2port1读回
    else if(is_ftw_lo)   user_rdata = ftw_shadow[15:0];
    else if(is_ftw_hi)   user_rdata = ftw_shadow[31:16];
    else if(is_dac_ctrl) user_rdata = {15'd0, dac_ctrl_reg};
    else if(is_m9k)      user_rdata = m9k_ram[user_addr];
    else                 user_rdata = 16'd0;               //写只读寄存器返回0
end

endmodule
