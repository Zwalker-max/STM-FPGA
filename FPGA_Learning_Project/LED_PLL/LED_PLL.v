// 顶层模块：连接 PLL 与 LED
module LED_PLL (
    input  wire clk_50m,   // 板载 50 MHz 时钟
    output wire led        // LED 输出
);

    // 内部信号：PLL 输出时钟
    wire pll_out_clk;

    // 实例化 PLL 模块（输入 50 MHz，输出 125 MHz）
    PLL1 u_PLL1 (
        .inclk0 (clk_50m),
        .c0     (pll_out_clk)
    );

    // 实例化 LED 闪烁模块
    LED u_LED (
        .i_clk  (pll_out_clk),
        .led_1  (led)
    );

endmodule