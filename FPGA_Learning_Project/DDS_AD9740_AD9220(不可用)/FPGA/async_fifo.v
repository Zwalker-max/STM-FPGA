/*********************************************************
* 模块：async_fifo
* 功能：异步 FIFO（双时钟域），16 位宽 × 1024 深
*       用于 AD9220 ADC 采样数据从 10 MHz 采样域到 125 MHz FMC 域的跨时钟传递
* 写端 (wrclk)：接 adc_decimator 的写脉冲与补位后的 16 位采样数据
* 读端 (rdclk)：接 stm32_fmc_16bit 的 FIFO 读脉冲，返回 16 位数据
* 设计（Cliff Cummings 经典双时钟 FIFO 结构）：
*   - 双端口 RAM 推断 M9K（与 ram_2port1 风格一致）
*   - 二进制+Gray 双指针，Gray 码跨域两级同步
*   - full/empty 寄存化（避免组合环路；由 next 指针计算 next 标志）
*   - 读出寄存化（q 在 rd_en 有效后下一周期更新并保持）
*   - 复位异步assert（指针与标志直接清零）
* FPGA：EP4CE10E22C8N
**********************************************************/
module async_fifo #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 10          // 深度 = 2^10 = 1024
)(
    // 写时钟域（10 MHz ADC 域）
    input  wire                  wrclk,
    input  wire                  wrst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,
    output wire [ADDR_WIDTH-1:0] wrusedw,   // 写域占用字数（0..1023，满由 full 指示）

    // 读时钟域（125 MHz FMC 域）
    input  wire                  rdclk,
    input  wire                  rrst_n,
    input  wire                  rd_en,
    output reg [DATA_WIDTH-1:0] q,
    output wire                  empty,
    output wire [ADDR_WIDTH-1:0] rdusedw    // 读域剩余可读字数（0..1023）
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;   // 多 1 位用于区分空/满
    localparam DEPTH     = (1 << ADDR_WIDTH);

    // 双端口存储体（M9K 推断）
    (* ramstyle = "M9K" *) reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // ============== Gray 编码函数 ==============
    function [PTR_WIDTH-1:0] bin2gray;
        input [PTR_WIDTH-1:0] b;
        bin2gray = b ^ (b >> 1);
    endfunction

    function [PTR_WIDTH-1:0] gray2bin;
        input [PTR_WIDTH-1:0] g;
        integer i;
        reg   [PTR_WIDTH-1:0] b;
        begin
            b[PTR_WIDTH-1] = g[PTR_WIDTH-1];
            for (i = PTR_WIDTH-2; i >= 0; i = i - 1)
                b[i] = b[i+1] ^ g[i];
            gray2bin = b;
        end
    endfunction

    // ============== 写指针（二进制 + Gray，寄存化 full）==============
    reg  [PTR_WIDTH-1:0] wr_bin, wr_gray;
    reg                  full_r;
    // 读指针 Gray 同步到写域
    reg  [PTR_WIDTH-1:0] rd_gray_sync1, rd_gray_sync2;

    wire [PTR_WIDTH-1:0] wr_bin_next  = wr_bin + (wr_en & ~full_r);
    wire [PTR_WIDTH-1:0] wr_gray_next = bin2gray(wr_bin_next);
    // 满：写指针的下一 Gray == 同步读指针的高两位取反、低位相同
    wire full_next = (wr_gray_next == {~rd_gray_sync2[PTR_WIDTH-1],
                                       ~rd_gray_sync2[PTR_WIDTH-2],
                                        rd_gray_sync2[PTR_WIDTH-3:0]});

    always @(posedge wrclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wr_bin  <= {PTR_WIDTH{1'b0}};
            wr_gray <= {PTR_WIDTH{1'b0}};
            full_r  <= 1'b0;
        end else begin
            wr_bin  <= wr_bin_next;
            wr_gray <= wr_gray_next;
            full_r  <= full_next;
        end
    end

    always @(posedge wrclk) begin
        if (wr_en & ~full_r)
            mem[wr_bin[ADDR_WIDTH-1:0]] <= wr_data;
    end

    always @(posedge wrclk or negedge wrst_n) begin
        if (!wrst_n) begin
            rd_gray_sync1 <= {PTR_WIDTH{1'b0}};
            rd_gray_sync2 <= {PTR_WIDTH{1'b0}};
        end else begin
            rd_gray_sync1 <= rd_gray;
            rd_gray_sync2 <= rd_gray_sync1;
        end
    end

    assign full = full_r;
    wire [PTR_WIDTH-1:0] wr_fill = wr_bin - gray2bin(rd_gray_sync2);
    assign wrusedw = wr_fill[ADDR_WIDTH-1:0];

    // ============== 读指针（二进制 + Gray，寄存化 empty）==============
    reg  [PTR_WIDTH-1:0] rd_bin, rd_gray;
    reg                  empty_r;
    // 写指针 Gray 同步到读域
    reg  [PTR_WIDTH-1:0] wr_gray_sync1, wr_gray_sync2;

    wire [PTR_WIDTH-1:0] rd_bin_next  = rd_bin + (rd_en & ~empty_r);
    wire [PTR_WIDTH-1:0] rd_gray_next = bin2gray(rd_bin_next);
    // 空：读指针下一 Gray == 同步写指针 Gray
    wire empty_next = (rd_gray_next == wr_gray_sync2);

    always @(posedge rdclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rd_bin  <= {PTR_WIDTH{1'b0}};
            rd_gray <= {PTR_WIDTH{1'b0}};
            empty_r <= 1'b1;            // 复位后为空
        end else begin
            rd_bin  <= rd_bin_next;
            rd_gray <= rd_gray_next;
            empty_r <= empty_next;
        end
    end

    always @(posedge rdclk or negedge rrst_n) begin
        if (!rrst_n)
            q <= {DATA_WIDTH{1'b0}};
        else if (rd_en & ~empty_r)
            q <= mem[rd_bin[ADDR_WIDTH-1:0]];
    end

    always @(posedge rdclk or negedge rrst_n) begin
        if (!rrst_n) begin
            wr_gray_sync1 <= {PTR_WIDTH{1'b0}};
            wr_gray_sync2 <= {PTR_WIDTH{1'b0}};
        end else begin
            wr_gray_sync1 <= wr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
        end
    end

    assign empty = empty_r;
    wire [PTR_WIDTH-1:0] rd_fill = gray2bin(wr_gray_sync2) - rd_bin;
    assign rdusedw = rd_fill[ADDR_WIDTH-1:0];

endmodule
