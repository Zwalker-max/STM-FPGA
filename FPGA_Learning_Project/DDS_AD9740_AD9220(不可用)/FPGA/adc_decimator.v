/*********************************************************
* 模块：adc_decimator
* 功能：AD9220 等效采样率控制（DDS 思想的抽取累加器）
*       10 MHz 固定采样时钟下，用 32 位相位累加器溢出脉冲决定
*       哪些 ADC 样点写入 FIFO，从而实现 <1 Hz 调节精度的等效采样率。
* 时钟：adc_clk = 10 MHz（pll1.c2）
* 复位：adc_rst_n（sys_rst_n 同步到 10 MHz 域后）
*
* 跨时钟域（FMC 125 MHz → ADC 10 MHz）：
*   32 位步进值与使能位采用 "稳定总线 + toggle" 握手。
*   FMC 域在更新触发时翻转 step_toggle / en_toggle，并保持
*   step_bus / en_bus 稳定；本模块在 10 MHz 域两级同步 toggle，
*   检测到翻转变化时把总线值锁存到本地寄存器（此时总线已稳定多周期，安全）。
*
* 输入：
*   step_bus[31:0]  — 来自 FMC 域的 32 位步进值（稳定）
*   en_bus          — 来自 FMC 域的使能位（稳定）
*   step_toggle     — FMC 域翻转位（每次更新触发翻转一次）
*   en_toggle       — FMC 域翻转位（每次使能写翻转一次）
*   adc_data_in[9:0]— AD9220 并行数据引脚
* 输出：
*   fifo_wr_en      — 写 FIFO 脉冲（单周期，与 10 MHz 上升沿对齐）
*   fifo_wr_data[15:0]— {6'd0, adc_data_in}（10→16 位零扩展）
*
* 设计要点：
*   - next_phase = phase_acc + step_local；无符号溢出即写脉冲
*   - 使能为 0 时累加器保持，不产生写脉冲
*   - 写数据在溢出当拍锁存，保证与 fifo_wr_en 同节拍
**********************************************************/
module adc_decimator (
    input  wire          clk,          // 10 MHz
    input  wire          rst_n,        // adc_rst_n

    // FMC 域稳定总线 + toggle 握手
    input  wire [31:0]   step_bus,
    input  wire          en_bus,
    input  wire          step_toggle,
    input  wire          en_toggle,

    // ADC 数据引脚
    input  wire [9:0]    adc_data_in,

    // FIFO 写端
    output reg           fifo_wr_en,
    output reg  [15:0]   fifo_wr_data
);

    //---------------------------------------------------
    // toggle 同步与锁存（FMC 125MHz -> ADC 10MHz）
    //---------------------------------------------------
    reg step_tg_sync1, step_tg_sync2, step_tg_prev;
    reg en_tg_sync1,   en_tg_sync2,   en_tg_prev;

    reg [31:0] step_local;
    reg        en_local;

    wire step_load = (step_tg_sync2 != step_tg_prev);
    wire en_load   = (en_tg_sync2   != en_tg_prev);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step_tg_sync1 <= 1'b0;
            step_tg_sync2 <= 1'b0;
            step_tg_prev  <= 1'b0;
            en_tg_sync1   <= 1'b0;
            en_tg_sync2   <= 1'b0;
            en_tg_prev    <= 1'b0;
            step_local    <= 32'd0;
            en_local      <= 1'b0;
        end else begin
            step_tg_sync1 <= step_toggle;
            step_tg_sync2 <= step_tg_sync1;
            step_tg_prev  <= step_tg_sync2;

            en_tg_sync1   <= en_toggle;
            en_tg_sync2   <= en_tg_sync1;
            en_tg_prev    <= en_tg_sync2;

            if (step_load)
                step_local <= step_bus;
            if (en_load)
                en_local   <= en_bus;
        end
    end

    //---------------------------------------------------
    // 32 位相位累加器 + 溢出检测
    //---------------------------------------------------
    reg  [31:0] phase_acc;
    wire [31:0] phase_next = phase_acc + step_local;
    wire        overflow   = (phase_next < phase_acc);   // 无符号回绕

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc     <= 32'd0;
            fifo_wr_en    <= 1'b0;
            fifo_wr_data  <= 16'd0;
        end else if (en_local) begin
            phase_acc     <= phase_next;
            fifo_wr_en    <= overflow;
            fifo_wr_data  <= {6'd0, adc_data_in};        // 溢出当拍锁存
        end else begin
            phase_acc     <= phase_acc;                  // 禁用时保持
            fifo_wr_en    <= 1'b0;
            fifo_wr_data  <= fifo_wr_data;
        end
    end

endmodule
