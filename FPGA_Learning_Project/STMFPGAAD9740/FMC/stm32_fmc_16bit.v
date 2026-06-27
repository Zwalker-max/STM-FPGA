/*********************************************************
 * Module: stm32_fmc_16bit — FMC异步从机接口 (纯接口版)
 * 功能：STM32H7 FMC异步总线 → 用户逻辑桥接
 *       两级同步器 + 三态总线控制 + 用户端口导出
 * 平台：EP4CE10E22I7N (Cyclone IV E)
 * 时钟：125MHz (PLL)
 * 总线：16bit数据 / 15bit地址 / NE1 NOE NWE
 *
 * 与旧版区别：
 *   - 移除内部寄存器组，通过 user_* 端口导出信号
 *   - 外部模块负责地址译码、RAM存取、寄存器读写
 *********************************************************/

module stm32_fmc_16bit (
    // === FMC 硬件接口 (FPGA侧物理引脚) ===
    input  wire          FMC_NE1,      // 片选 低有效
    input  wire          FMC_NOE,      // 读使能 低有效
    input  wire          FMC_NWE,      // 写使能 低有效
    input  wire [14:0]   FMC_A,        // 15bit 地址线
    inout  wire [15:0]   FMC_D,        // 16bit 双向数据线

    // === FPGA系统时钟与复位 ===
    input  wire          clk_125m,     // 125MHz 系统时钟 (PLL)
    input  wire          rst_n,        // 低电平复位

    // === 用户逻辑接口 ===
    output wire          user_wr_en,   // 写使能 (高有效, 同步后)
    output wire          user_rd_en,   // 读使能 (高有效, 同步后)
    output wire [14:0]   user_addr,    // 地址总线 (同步后)
    output wire [15:0]   user_wdata,   // 写数据总线
    input  wire [15:0]   user_rdata    // 读数据总线 ← 用户逻辑提供
);

//===========================================================
// 1. 异步控制信号 两级同步 (防亚稳态)
//    FMC总线来自STM32 (110MHz域)，FPGA工作在125MHz域
//    所有控制/地址信号必须进行两级同步
//    写数据也注册一级：与 user_wr_en pipeline 对齐，
//    避免组合逻辑直通带来的建立/保持时间问题
//===========================================================
reg        ne1_sync1, ne1_sync2;
reg        noe_sync1, noe_sync2;
reg        nwe_sync1, nwe_sync2;
reg [14:0] addr_sync1, addr_sync2;
reg [15:0] user_wdata_reg;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ne1_sync1  <= 1'b1;
        ne1_sync2  <= 1'b1;
        noe_sync1  <= 1'b1;
        noe_sync2  <= 1'b1;
        nwe_sync1  <= 1'b1;
        nwe_sync2  <= 1'b1;
        addr_sync1 <= 15'd0;
        addr_sync2 <= 15'd0;
        user_wdata_reg <= 16'd0;
    end else begin
        // 第一级：寄存异步输入
        ne1_sync1  <= FMC_NE1;
        noe_sync1  <= FMC_NOE;
        nwe_sync1  <= FMC_NWE;
        addr_sync1 <= FMC_A;
        user_wdata_reg <= FMC_D;   // 写数据注册 (与控制信号同步对齐)
        // 第二级：稳定后输出
        ne1_sync2  <= ne1_sync1;
        noe_sync2  <= noe_sync1;
        nwe_sync2  <= nwe_sync1;
        addr_sync2 <= addr_sync1;
    end
end

//===========================================================
// 2. 读写有效信号生成 (同步后, 无毛刺)
//===========================================================
wire cs_valid = ~ne1_sync2;                     // 片选有效 (高有效)

assign user_wr_en = cs_valid & ~nwe_sync2;      // 写使能 (高有效)
assign user_rd_en = cs_valid & ~noe_sync2;      // 读使能 (高有效)
assign user_addr  = addr_sync2;                  // 地址输出
assign user_wdata = user_wdata_reg;               // 写数据 (注册后的同步版本)

//===========================================================
// 3. 三态数据总线控制
//    关键：仅在读周期且片选有效时才驱动FMC_D
//    写周期时STM32驱动，FPGA必须释放总线避免冲突
//===========================================================
assign FMC_D = (user_rd_en) ? user_rdata : 16'hzzzz;

endmodule
