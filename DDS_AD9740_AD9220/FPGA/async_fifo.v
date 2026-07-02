/*********************************************************
* 模块：async_fifo
* 功能：16bit × 1024 深度 异步双时钟 FIFO（手推断式）
* 写时钟域：10 MHz（ADC 采样时钟）
* 读时钟域：125 MHz（FMC 逻辑时钟）
* 设计：
*   - M9K 推断双端口 RAM（16 × 1024）
*   - Gray 码指针实现跨时钟域同步（无亚稳态风险）
*   - 寄存型 full / empty 标志
*   - rdusedw[9:0] 输出（可读字数，仅供调试）
*   - 异步复位（同时清零两侧指针和标志）
* FPGA：EP4CE10E22C8N
**********************************************************/

module async_fifo (
    // 写端（10 MHz ADC 时钟域）
    input wire          wr_clk,
    input wire          wr_en,
    input wire  [15:0]  wr_data,

    // 读端（125 MHz FMC 时钟域）
    input wire          rd_clk,
    input wire          rd_en,
    output wire [15:0]  rd_data,

    // 状态标志
    output wire         empty,
    output wire         full,
    output wire [9:0]   rdusedw,

    // 异步复位（高有效）
    input wire          areset
);

    //===========================================================
    // 双端口 RAM（M9K 推断，1024 × 16）
    //===========================================================
    (* ramstyle = "M9K" *) reg [15:0] mem [0:1023];

    //===========================================================
    // 二进制指针（各自时钟域）
    //===========================================================
    reg [10:0] wr_bin;      // 写二进制指针 [10] 为额外位区分空/满
    reg [10:0] rd_bin;      // 读二进制指针 [10] 为额外位区分空/满

    //===========================================================
    // Gray 码指针
    //===========================================================
    reg [10:0] wr_gray;
    reg [10:0] rd_gray;

    //===========================================================
    // Gray 码同步到对方时钟域（两级同步器）
    //===========================================================
    (* ASYNC_REG = "TRUE" *) reg [10:0] wr_gray_sync1, wr_gray_sync2;   // 写指针 → 读时钟域
    (* ASYNC_REG = "TRUE" *) reg [10:0] rd_gray_sync1, rd_gray_sync2;   // 读指针 → 写时钟域

    //===========================================================
    // 二进制→Gray 转换函数
    //===========================================================
    function [10:0] bin2gray;
        input [10:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction

    //===========================================================
    // Gray→二进制转换函数
    //===========================================================
    function [10:0] gray2bin;
        input [10:0] gray;
        reg [10:0] bin;
        integer i;
        begin
            bin[10] = gray[10];
            for (i = 9; i >= 0; i = i - 1)
                bin[i] = bin[i+1] ^ gray[i];
            gray2bin = bin;
        end
    endfunction

    //===========================================================
    // 写端逻辑（10 MHz 域）
    //===========================================================
    wire [10:0] rd_bin_wr_domain;     // 同步过来的读指针（二进制，写域用）

    // 同步读 Gray 指针到写域
    always @(posedge wr_clk or posedge areset) begin
        if (areset) begin
            rd_gray_sync1 <= 11'd0;
            rd_gray_sync2 <= 11'd0;
        end else begin
            rd_gray_sync1 <= rd_gray;
            rd_gray_sync2 <= rd_gray_sync1;
        end
    end
    assign rd_bin_wr_domain = gray2bin(rd_gray_sync2);

    // 写操作 + 指针更新
    always @(posedge wr_clk or posedge areset) begin
        if (areset) begin
            wr_bin <= 11'd0;
        end else if (wr_en && !full) begin
            mem[wr_bin[9:0]] <= wr_data;
            wr_bin <= wr_bin + 11'd1;
        end
    end

    // 写 Gray 指针
    always @(posedge wr_clk or posedge areset) begin
        if (areset) begin
            wr_gray <= 11'd0;
        end else begin
            wr_gray <= bin2gray(wr_bin);
        end
    end

    // full 标志（寄存）：写指针追上同步后的读指针一圈
    wire wr_full_next;
    assign wr_full_next = (wr_bin[10] != rd_bin_wr_domain[10])
                       && (wr_bin[9:0] == rd_bin_wr_domain[9:0]);

    reg  full_reg;
    always @(posedge wr_clk or posedge areset) begin
        if (areset) begin
            full_reg <= 1'b0;
        end else begin
            full_reg <= wr_full_next;
        end
    end
    assign full = full_reg;

    //===========================================================
    // 读端逻辑（125 MHz 域）
    //===========================================================
    wire [10:0] wr_bin_rd_domain;     // 同步过来的写指针（二进制，读域用）

    // 同步写 Gray 指针到读域
    always @(posedge rd_clk or posedge areset) begin
        if (areset) begin
            wr_gray_sync1 <= 11'd0;
            wr_gray_sync2 <= 11'd0;
        end else begin
            wr_gray_sync1 <= wr_gray;
            wr_gray_sync2 <= wr_gray_sync1;
        end
    end
    assign wr_bin_rd_domain = gray2bin(wr_gray_sync2);

    // 读操作 + 指针更新
    always @(posedge rd_clk or posedge areset) begin
        if (areset) begin
            rd_bin <= 11'd0;
        end else if (rd_en && !empty) begin
            rd_bin <= rd_bin + 11'd1;
        end
    end

    // 读数据（寄存读，对齐 M9K 读延迟）
    reg [15:0] rd_data_reg;
    always @(posedge rd_clk or posedge areset) begin
        if (areset) begin
            rd_data_reg <= 16'd0;
        end else begin
            rd_data_reg <= mem[rd_bin[9:0]];
        end
    end
    assign rd_data = rd_data_reg;

    // 读 Gray 指针
    always @(posedge rd_clk or posedge areset) begin
        if (areset) begin
            rd_gray <= 11'd0;
        end else begin
            rd_gray <= bin2gray(rd_bin);
        end
    end

    // empty 标志（寄存）：读指针追上同步后的写指针
    wire rd_empty_next;
    assign rd_empty_next = (wr_bin_rd_domain[10:0] == rd_bin[10:0]);

    reg  empty_reg;
    always @(posedge rd_clk or posedge areset) begin
        if (areset) begin
            empty_reg <= 1'b1;    // 复位时空标志为 1
        end else begin
            empty_reg <= rd_empty_next;
        end
    end
    assign empty = empty_reg;

    //===========================================================
    // rdusedw 输出（可读字数，读域）
    //===========================================================
    wire [10:0] used_w;
    assign used_w = (wr_bin_rd_domain[10] == rd_bin[10])
                  ? (wr_bin_rd_domain[9:0] - rd_bin[9:0])
                  : (1024 - rd_bin[9:0] + wr_bin_rd_domain[9:0]);

    assign rdusedw = used_w[9:0];

endmodule
