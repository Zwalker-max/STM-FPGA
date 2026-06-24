module LED(
  input  i_clk,
  output led_1
);

localparam COUNT_DELAY = 25_000_000 - 1;   // 仿真用极小值

reg [24:0] led_cnt = 25'd0;
reg        led_out = 1'b0;
reg [3:0]  por_cnt = 4'd0;
reg        por_rst = 1'b1;        // 上电复位有效

// 产生上电复位脉冲（持续16个时钟周期）
always @(posedge i_clk) begin
    if (por_cnt < 4'd15) begin
        por_cnt <= por_cnt + 1'b1;
        por_rst <= 1'b1;
    end else begin
        por_rst <= 1'b0;
    end
end

// 计数器（复位时清零）
always @(posedge i_clk) begin
    if (por_rst)
        led_cnt <= 25'd0;
    else if (led_cnt == COUNT_DELAY)
        led_cnt <= 25'd0;
    else
        led_cnt <= led_cnt + 1'b1;
end

// LED输出（复位时置0）
always @(posedge i_clk) begin
    if (por_rst)
        led_out <= 1'b0;
    else if (led_cnt == COUNT_DELAY)
        led_out <= ~led_out;
    else
        led_out <= led_out;
end

assign led_1 = led_out;

endmodule