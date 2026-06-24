module LED(
  input  i_clk,
  output led_1
);

localparam COUNT_DELAY = 25_000_000 - 1;   // 仿真用极小值，方便观察;  // 0.5s

reg [24:0] led_cnt;
reg        led_out;
reg [3:0]  por_cnt;      // 上电复位计数器
reg        por_rst;      // 内部复位信号

// 产生上电复位脉冲（持续16个时钟周期）
always @(posedge i_clk) begin
    if (por_cnt < 4'd15) begin
        por_cnt <= por_cnt + 1'b1;
        por_rst <= 1'b1;        // 复位有效
    end else begin
        por_rst <= 1'b0;        // 释放复位
    end
end

// 计数器（复位时清零）
always @(posedge i_clk) begin
    if (por_rst) begin
        led_cnt <= 25'd0;
    end else if (led_cnt == COUNT_DELAY) begin
        led_cnt <= 25'd0;
    end else begin
        led_cnt <= led_cnt + 1'b1;
    end
end

// LED输出（复位时置0）
always @(posedge i_clk) begin
    if (por_rst) begin
        led_out <= 1'b0;
    end else if (led_cnt == COUNT_DELAY) begin
        led_out <= ~led_out;
    end else begin
        led_out <= led_out;   // 保持
    end
end

assign led_1 = led_out;

endmodule