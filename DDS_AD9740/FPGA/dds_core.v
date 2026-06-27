/*********************************************************
* 模块：dds_core
* 功能：32位 DDS 相位累加器
* 描述：每个 clk 周期累加 FTW，输出高10位作为波形RAM读地址
*
* 工作原理：
*   phase_acc <= phase_acc + ftw   （每个125MHz时钟周期）
*   rd_addr = phase_acc[31:22]      （取高10位寻址1024点波形RAM）
*
* 频率计算公式：
*   f_out = (FTW / 2^32) × 125MHz
*   分辨率 = 125MHz / 2^32 ≈ 0.029Hz
*
* 典型FTW值：
*   1Hz   → FTW = round(1 × 2^32 / 125M) = 34
*   1kHz  → FTW = round(1k × 2^32 / 125M) = 34359738
*   1MHz  → FTW = round(1M × 2^32 / 125M) = 34359738368 >> 16 = 准确值见dds.c
**********************************************************/
module dds_core (
    //====== 时钟和复位 ======
    input  wire          clk,           //125MHz DAC采样时钟
    input  wire          rst_n,         //异步复位 低有效

    //====== 控制接口 ======
    input  wire [31:0]   ftw,           //频率控制字（来自stm32_fmc_16bit）
    input  wire          phase_rst,     //相位复位脉冲（高有效1个clk周期）

    //====== 地址输出 ======
    output wire [9:0]    rd_addr        //波形RAM读地址（到ram_2port1的rdaddress）
);

    //相位累加器
    reg [31:0] phase_acc;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            phase_acc <= 32'd0;
        else if(phase_rst)
            phase_acc <= 32'd0;             //相位复位
        else
            phase_acc <= phase_acc + ftw;   //每周期累加FTW（32位无符号，溢出自动回绕）
    end

    //取累加器高10位作为波形RAM地址（1024点）
    //低22位充当"余数寄存器"，实现分数倍时钟等效
    assign rd_addr = phase_acc[31:22];

endmodule
