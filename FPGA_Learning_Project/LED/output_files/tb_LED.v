`timescale 1ns / 1ps

module tb_LED();

reg  clk;
wire led_out;

// 例化待测模块
LED u_led (
    .i_clk  (clk),
    .led_1  (led_out)
);

// 生成 50MHz 时钟（周期 20ns）
initial begin
    clk = 0;
    forever #10 clk = ~clk;   // 10ns 翻转一次 -> 周期 20ns
end

// 控制仿真运行时间
initial begin
    #1000000;   // 仿真运行 1ms（实际对应 1 秒，可适当调整）
    $finish;
end

endmodule