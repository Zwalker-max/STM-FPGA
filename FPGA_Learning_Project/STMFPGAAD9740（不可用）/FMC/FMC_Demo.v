/*********************************************************
 * Module: FMC_Demo — FPGA 顶层 (纯Verilog, 替代BDF)
 * 功能：整合FMC从机 + 地址译码 + 双端口RAM + DAC控制器
 *
 * 模块连接关系：
 *   CLK_50M → pll1 → clk_125m (C0: 系统时钟)
 *   FMC总线 → stm32_fmc_16bit → fmc_addr_decoder
 *     ├── Port A (write) → ram_2port1 (2048 × 16-bit)
 *     ├── 控制寄存器 → dac_controller
 *     └── 状态寄存器 ← dac_controller
 *   ram_2port1 Port B → dac_controller → DAC_DATA
 *   PLL C0 → DAC_CLK (125 MHz 直连)
 *
 * 平台：EP4CE10E22I7N (Cyclone IV E)
 * 目标：Quartus II 14.1
 * RAM：2048 × 16-bit (M9K, 11-bit地址)
 *********************************************************/

module FMC_Demo (
    // === 时钟 ===
    input  wire          CLK_50M,       // 50 MHz 外部晶振 → PLL输入

    // === FMC 总线 (STM32H7 ↔ FPGA) ===
    input  wire          FMC_NE1,       // 片选 低有效
    input  wire          FMC_NOE,       // 读使能 低有效
    input  wire          FMC_NWE,       // 写使能 低有效
    input  wire [14:0]   FMC_A,         // 15bit 地址线
    inout  wire [15:0]   FMC_D,         // 16bit 双向数据线

    // === 复位 (内部上拉, 低有效) ===
    input  wire          RST_N,         // 全局复位 (或连接到VCC if unused)

    // === AD9740 DAC 接口 ===
    // DAC_DATA: FPGA输出 (clk_125m下降沿更新)
    // DAC_CLK:  PLL C0直连 (125 MHz, 干净时钟)
    output wire [9:0]    DAC_DATA,      // DAC数据 DB9-DB0
    output wire          DAC_CLK        // DAC时钟 (PLL C0 125MHz直连)
);

//===========================================================
// 内部信号定义
//===========================================================

// PLL 输出时钟
wire clk_125m;       // C0: 125 MHz 系统时钟

// FMC 用户接口信号 (stm32_fmc_16bit → fmc_addr_decoder)
wire        user_wr_en;
wire        user_rd_en;
wire [14:0] user_addr;
wire [15:0] user_wdata;
wire [15:0] user_rdata;

// 双端口RAM Port A 接口 (fmc_addr_decoder → ram_2port1, 2048深度)
wire        ram_wr_en;
wire [10:0] ram_wr_addr;
wire [15:0] ram_wr_data;
wire        ram_rd_en;
wire [10:0] ram_rd_addr;
wire [15:0] ram_rd_data;

// 控制寄存器 (fmc_addr_decoder → dac_controller)
wire        dac_start;
wire        dds_en;
wire        burst_en;
wire [3:0]  wave_sel;
wire [31:0] freq_word;
wire [9:0]  amplitude;
wire [31:0] phase_offset;
wire [10:0] waveform_base;

// 状态寄存器 (dac_controller → fmc_addr_decoder)
wire        ram_busy;
wire        dac_running;
wire [9:0]  current_sample;

// DAC控制器 RAM接口 (dac_controller → ram_2port1 Port B, 2048深度)
wire [10:0] dac_ram_rd_addr;
wire [15:0] dac_ram_rd_data;

// 复位信号
wire sys_rst_n;

//===========================================================
// 复位处理
//===========================================================
assign sys_rst_n = RST_N;

//===========================================================
// 1. PLL 实例化 (50 MHz → 125 MHz)
//    由MegaWizard生成，文件: pll1.v
//===========================================================
pll1 u_pll (
    .inclk0 (CLK_50M),
    .c0     (clk_125m)
);

//===========================================================
// 2. FMC 从机接口 (STM32H7 异步总线 ↔ 内部用户逻辑)
//===========================================================
stm32_fmc_16bit u_fmc (
    // FMC 物理接口
    .FMC_NE1    (FMC_NE1),
    .FMC_NOE    (FMC_NOE),
    .FMC_NWE    (FMC_NWE),
    .FMC_A      (FMC_A),
    .FMC_D      (FMC_D),

    // FPGA 系统
    .clk_125m   (clk_125m),
    .rst_n      (sys_rst_n),

    // 用户逻辑接口
    .user_wr_en (user_wr_en),
    .user_rd_en (user_rd_en),
    .user_addr  (user_addr),
    .user_wdata (user_wdata),
    .user_rdata (user_rdata)
);

//===========================================================
// 3. 地址译码器 (地址空间分区 → RAM / 控制寄存器 / 状态寄存器)
//===========================================================
fmc_addr_decoder u_decoder (
    .clk_125m       (clk_125m),
    .rst_n          (sys_rst_n),

    // FMC 用户接口
    .user_wr_en     (user_wr_en),
    .user_rd_en     (user_rd_en),
    .user_addr      (user_addr),
    .user_wdata     (user_wdata),
    .user_rdata     (user_rdata),

    // 双端口RAM Port A
    .ram_wr_en      (ram_wr_en),
    .ram_wr_addr    (ram_wr_addr),
    .ram_wr_data    (ram_wr_data),
    .ram_rd_en      (ram_rd_en),
    .ram_rd_addr    (ram_rd_addr),
    .ram_rd_data    (ram_rd_data),

    // 控制寄存器 → DAC控制器
    .dac_start      (dac_start),
    .dds_en         (dds_en),
    .burst_en       (burst_en),
    .wave_sel       (wave_sel),
    .freq_word      (freq_word),
    .amplitude      (amplitude),
    .phase_offset   (phase_offset),
    .waveform_base  (waveform_base),

    // 状态寄存器 ← DAC控制器
    .ram_busy       (ram_busy),
    .dac_running    (dac_running),
    .current_sample (current_sample)
);

//===========================================================
// 4. 双端口RAM (2048×16-bit, M9K)
//    Port A: STM32 读写 (通过FMC+地址译码器)
//    Port B: DAC控制器读取 (DDS地址生成)
//===========================================================
ram_2port1 u_ram (
    .clock      (clk_125m),

    // Port A (写端口)
    .wren       (ram_wr_en),
    .wraddress  (ram_wr_addr),
    .data       (ram_wr_data),

    // Port B (读端口)
    .rdaddress  (dac_ram_rd_addr),
    .q          (dac_ram_rd_data)
);

// Port A 读回: 同一端口不支持同时读写，这里用Port B的data代理
// 简化处理：RAM读回时直接读取Port A的写入数据
// 实际波形中STM32通常写一次后不再回读，可接受
assign ram_rd_data = ram_wr_en ? ram_wr_data : dac_ram_rd_data;

//===========================================================
// 5. DAC 控制器 (DDS引擎 + AD9740接口)
//===========================================================
wire [9:0] dac_data_internal;  // DAC输出内部信号（幅度缩放后）

dac_controller u_dac (
    .clk_125m       (clk_125m),
    .rst_n          (sys_rst_n),

    // 控制信号
    .start          (dac_start),
    .dds_en         (dds_en),
    .freq_word      (freq_word),
    .amplitude      (amplitude),
    .phase_offset   (phase_offset),
    .waveform_base  (waveform_base),
    .waveform_len   (11'd2047),    // 默认全范围 (2048深度)

    // 双端口RAM Port B
    .ram_rd_addr    (dac_ram_rd_addr),
    .ram_rd_data    (dac_ram_rd_data),

    // AD9740 物理接口
    .dac_data       (dac_data_internal)
);

// DAC_CLK: PLL C0 直连 (125 MHz, 干净无抖动)
assign DAC_CLK  = clk_125m;
assign DAC_DATA = dac_data_internal;

//===========================================================
// 状态信号
//===========================================================
assign ram_busy     = 1'b0;        // TODO: 检测RAM访问冲突
assign dac_running  = dac_start;
assign current_sample = dac_data_internal;  // 幅度缩放后的实际DAC输出值

endmodule
