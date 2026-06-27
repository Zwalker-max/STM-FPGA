/*********************************************************
 * Module: fmc_addr_decoder — FMC地址译码器
 * 功能：将FMC总线读写请求路由到正确的从设备
 *
 * 地址映射 (15bit, 32K字地址空间, 仅A[14:0]连接到FPGA)：
 *   0x0000 – 0x07FF  (A14:11=0): 双端口RAM (2048×16)
 *      写：FMC[addr] = data → Port A 写入
 *      读：data = FMC[addr] → Port A 回读
 *
 *   0x0800 – 0x3FFF  (A14=0, A13:11≠0): 未使用, 读写返回0
 *
 *   0x4000 – 0x401F  (A14=1, A[4:0]<32): 控制/状态寄存器
 *      0x4000: MODE   [0]=start [1]=dds_en [2]=burst_en [7:4]=wave_sel
 *      0x4001: FREQ_H [31:16]
 *      0x4002: FREQ_L [15:0]
 *      0x4003: AMP    [9:0]
 *      0x4004: PHASE_OFFSET [31:16]
 *      0x4005: PHASE_OFFSET [15:0]
 *      0x4006: WAVEFORM_BASE [10:0] (ping-pong buffer base)
 *      0x4010: STATUS  [0]=ram_busy [1]=dac_running (read-only)
 *      0x4011: CURRENT_SAMPLE [9:0] (read-only)
 *********************************************************/

module fmc_addr_decoder (
    input  wire          clk_125m,
    input  wire          rst_n,

    // FMC 用户接口 (来自 stm32_fmc_16bit)
    input  wire          user_wr_en,
    input  wire          user_rd_en,
    input  wire [14:0]   user_addr,
    input  wire [15:0]   user_wdata,
    output reg  [15:0]   user_rdata,

    // --- 双端口RAM Port A 接口 (RAM深度2048, 11-bit地址) ---
    output wire          ram_wr_en,
    output wire [10:0]   ram_wr_addr,
    output wire [15:0]   ram_wr_data,
    output wire          ram_rd_en,
    output wire [10:0]   ram_rd_addr,
    input  wire [15:0]   ram_rd_data,

    // --- 控制寄存器输出 (到DDS引擎/DAC控制器) ---
    output reg           dac_start,
    output reg           dds_en,
    output reg           burst_en,
    output reg  [3:0]    wave_sel,
    output reg  [31:0]   freq_word,
    output reg  [9:0]    amplitude,
    output reg  [31:0]   phase_offset,
    output reg  [10:0]   waveform_base,

    // --- 状态寄存器输入 ---
    input  wire          ram_busy,
    input  wire          dac_running,
    input  wire [9:0]    current_sample
);

//===========================================================
// 地址译码
//===========================================================
// A14:11 = 0 → RAM区域 (0x0000-0x07FF, 2048字)
// A14 = 1 → 控制/状态寄存器区域 (0x4000-0x7FFF)
// A14=0 且 A13:11≠0 → 未使用 (0x0800-0x3FFF), 读写返回0
wire region_ram       = (user_addr[14:11] == 4'b0000);    // 0x0000-0x07FF
wire region_ctrl      = user_addr[14];                      // 0x4000+
// region_unused: 0x0800-0x7FFF, 读写均被忽略 (region_ram=0, region_ctrl=0)
// 读路径已通过 else 分支显式返回0, 无需额外逻辑

// 控制寄存器内部地址 (使用低5位, 0-31)
wire [4:0] reg_addr = user_addr[4:0];

//===========================================================
// 双端口RAM接口 (Port A, 11-bit地址)
//===========================================================
// 写操作：FMC写周期 + RAM区域 → wren
assign ram_wr_en   = user_wr_en & region_ram;
assign ram_wr_addr = user_addr[10:0];   // 截取低11位
assign ram_wr_data = user_wdata;

// 读操作：FMC读周期 + RAM区域 → 从RAM读取
assign ram_rd_en   = user_rd_en & region_ram;
assign ram_rd_addr = user_addr[10:0];

//===========================================================
// 控制寄存器 写操作
//===========================================================
always @(posedge clk_125m or negedge rst_n) begin
    if (!rst_n) begin
        dac_start     <= 1'b0;
        dds_en        <= 1'b0;
        burst_en      <= 1'b0;
        wave_sel      <= 4'd0;
        freq_word     <= 32'd0;
        amplitude     <= 10'h3FF;    // 默认满幅度
        phase_offset  <= 32'd0;
        waveform_base <= 11'd0;
    end else if (user_wr_en && region_ctrl) begin
        case (reg_addr)
            5'd0: begin  // MODE
                dac_start <= user_wdata[0];
                dds_en    <= user_wdata[1];
                burst_en  <= user_wdata[2];
                wave_sel  <= user_wdata[7:4];
            end
            5'd1: freq_word[31:16] <= user_wdata;       // FREQ_H
            5'd2: freq_word[15:0]  <= user_wdata;       // FREQ_L
            5'd3: amplitude        <= user_wdata[9:0];   // AMP
            5'd4: phase_offset[31:16] <= user_wdata;     // PHASE_H
            5'd5: phase_offset[15:0]  <= user_wdata;     // PHASE_L
            5'd6: waveform_base    <= user_wdata[10:0];  // WAVEFORM_BASE (2048深度)
            default: ; // 保留地址, 无操作
        endcase
    end
end

//===========================================================
// 读数据多路复用 (组合逻辑)
//===========================================================
always @(*) begin
    if (user_rd_en) begin
        if (region_ram) begin
            user_rdata = ram_rd_data;    // RAM回读
        end else if (region_ctrl) begin
            // 状态寄存器回读
            case (reg_addr)
                5'd0:  user_rdata = {8'd0, wave_sel, 1'b0, burst_en, dds_en, dac_start};
                5'd1:  user_rdata = freq_word[31:16];
                5'd2:  user_rdata = freq_word[15:0];
                5'd3:  user_rdata = {6'd0, amplitude};
                5'd4:  user_rdata = phase_offset[31:16];
                5'd5:  user_rdata = phase_offset[15:0];
                5'd6:  user_rdata = {5'd0, waveform_base};
                5'h10: user_rdata = {14'd0, dac_running, ram_busy};
                5'h11: user_rdata = {6'd0, current_sample};
                default: user_rdata = 16'd0;
            endcase
        end else begin
            // 未使用区域 (0x0800-0x7FFF): 返回0
            user_rdata = 16'd0;
        end
    end else begin
        user_rdata = 16'd0;
    end
end

endmodule
