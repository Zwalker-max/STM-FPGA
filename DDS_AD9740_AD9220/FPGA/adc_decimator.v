/*********************************************************
* 模块：adc_decimator
* 功能：32 位相位累加器，用于 ADC 采样率控制（抽取器）
* 输入：adc_d[11:0]     — AD9220 12-bit 数据
* 输入：step[31:0]      — 32 位步进值（来自 FMC 影子寄存器同步后）
* 输入：enable          — ADC 使能（0 = 停止，输出冻结）
* 输出：fifo_wr_en       — FIFO 写使能（单周期脉冲）
* 输出：fifo_wdata[15:0] — 补位后的 16-bit ADC 数据
* FPGA：EP4CE10E22C8N
* 时钟：10 MHz（adc_clk）
* 设计：
*   - 每个 10 MHz 周期累加 step
*   - 溢出检测：(next_phase < phase_acc) 产生单周期写脉冲
*   - 溢出时锁存 ADC 输入，高 4 位补 0 → 16 bit
*   - enable = 0 时保持累加器，不产生写脉冲
*   - 采样率 = 10 MHz * step / 2^32
*     例：1 MSPS → step = 1e6 * 2^32 / 10e6 ≈ 429,496,730
**********************************************************/

module adc_decimator (
    input wire          clk_10m,
    input wire          rst_n,

    input wire  [11:0]  adc_d,
    input wire  [31:0]  step,
    input wire          enable,

    output reg          fifo_wr_en,
    output reg  [15:0]  fifo_wdata
);

    // 32 位相位累加器
    reg [31:0] phase_acc;

    // 组合逻辑：下一累加值（用于溢出检测）
    wire [31:0] next_phase;
    assign next_phase = phase_acc + step;

    // 溢出检测：无符号累加，next < current 表示回绕
    wire overflow;
    assign overflow = (next_phase < phase_acc);

    always @(posedge clk_10m or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc   <= 32'd0;
            fifo_wr_en  <= 1'b0;
            fifo_wdata  <= 16'd0;
        end else if (!enable) begin
            // 禁用时保持累加器和输出
            fifo_wr_en  <= 1'b0;
        end else begin
            // 每个周期累加
            phase_acc <= next_phase;

            // 溢出时锁存 ADC 数据并产生写脉冲
            if (overflow) begin
                fifo_wr_en  <= 1'b1;
                fifo_wdata  <= {4'b0000, adc_d};   // 12-bit → 16-bit，高 4 位补 0
            end else begin
                fifo_wr_en  <= 1'b0;
            end
        end
    end

endmodule
