/*********************************************************
 * Module: dac_controller — AD9740 DAC 控制器 + DDS 引擎
 * 功能：双端口RAM读取 → 幅度缩放 → AD9740输出
 *
 * 特性：
 *   - 32-bit DDS 相位累加器 (125 MHz 全速, 无分频)
 *   - 双端口RAM Port B 读地址生成 (2048 × 16-bit)
 *   - 10-bit 幅度缩放 (乘除运算)
 *   - Start/Stop 控制 + 中值输出(空闲时)
 *
 * 时钟架构:
 *   - clk_125m posedge: DDS引擎, RAM地址, 幅度计算
 *   - clk_125m negedge: DAC_DATA 输出 (4ns建立时间)
 *   - DAC_CLK: 顶层 PLL C0 直连 (125 MHz)
 *
 * AD9740 时序 (125 MHz, 8ns周期):
 *   - DAC_DATA 在下降沿更新 → 4ns后上升沿锁存
 *   - 建立时间 ~4ns, AD9740 要求 ~2ns ✓
 *
 * DDS公式: Fout = FREQ_WORD * 125e6 / 2^32
 *   相位累加器每周期推进, 125 MSPS 全速率
 * RAM深度：2048 (11-bit address)
 *********************************************************/

module dac_controller (
    // === 系统时钟 & 复位 ===
    input  wire          clk_125m,       // PLL C0: 125 MHz
    input  wire          rst_n,

    // === 控制接口 ===
    input  wire          start,
    input  wire          dds_en,
    input  wire [31:0]   freq_word,      // Fout = freq * 125MHz / 2^32
    input  wire [9:0]    amplitude,
    input  wire [31:0]   phase_offset,
    input  wire [10:0]   waveform_base,
    input  wire [10:0]   waveform_len,

    // === 双端口RAM Port B (读端口) ===
    output reg  [10:0]   ram_rd_addr,
    input  wire [15:0]   ram_rd_data,

    // === AD9740 物理接口 ===
    output reg  [9:0]    dac_data        // DAC_CLK 由顶层 PLL C0 直连
);

//===========================================================
// clk_125m posedge: DDS引擎 (125 MSPS 全速, 无分频)
//===========================================================

//===========================================================
// 1. 32-bit DDS 相位累加器 (每周期推进, 125 MSPS)
//===========================================================
reg [31:0] phase_acc;

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        phase_acc <= 32'd0;
    end else if (start) begin
        phase_acc <= phase_acc + freq_word;
    end else begin
        phase_acc <= 32'd0;
    end
end

//===========================================================
// 2. RAM读地址生成 (11-bit, 2048深度)
//===========================================================
wire [31:0] phase_with_offset;
assign phase_with_offset = phase_acc + phase_offset;

wire [10:0] phase_addr;
assign phase_addr = dds_en ? phase_with_offset[31:21]
                           : phase_with_offset[10:0];

always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        ram_rd_addr <= 11'd0;
    end else begin
        ram_rd_addr <= phase_addr + waveform_base;
    end
end

//===========================================================
// 3. 幅度缩放 (组合逻辑)
//===========================================================
wire [25:0] scaled_data;
assign scaled_data = ram_rd_data * {6'd0, amplitude};

wire [9:0] dac_value;
assign dac_value = scaled_data[19:10];

//===========================================================
// clk_125m negedge: DAC_DATA 输出
//   下降沿更新 → 4ns后上升沿 AD9740 锁存
//===========================================================

//===========================================================
// 4. DAC数据输出 (125 MSPS)
//    - 每周期下降沿更新
//    - 空闲: 10'h200 (中值)
//===========================================================
always @(negedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= 10'h200;
    end else if (start) begin
        dac_data <= dac_value;
    end else begin
        dac_data <= 10'h200;
    end
end

endmodule
