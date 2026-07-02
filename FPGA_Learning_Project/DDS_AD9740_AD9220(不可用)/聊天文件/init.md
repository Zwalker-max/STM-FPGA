当前工程已实现 基于 EP4CE10E22C8N FPGA + STM32H723ZGT6 开发板，通过 FMC 总线实现一个 DDS 任意波形发生器，驱动 AD9740 DAC 输出 1Hz 正弦波（频率可调）。可以利用已实现的功能模块来完成以下内容。

【项目概述】
我正在开发一款基于 STM32H723ZGT6 与 FPGA EP4CE10E22I7 的高速数据采集系统。ADC 选用 AD9220（实际 10 位并行输出，最高 10MSPS）。FPGA 作为前端时序桥接与 FIFO 缓冲，STM32 通过 FMC 总线与 FPGA 交互。

【核心架构参数】
1. ADC 侧：采样时钟固定为 10MHz（由 FPGA PLL 提供），数据位宽 10-bit。
2. 采样率控制：采用 32 位相位累加器（DDS 思想）实现等效采样率精细调节，步进分辨率 = 10MHz / 2^32 ≈ 0.0023Hz，满足 <1Hz 的调节精度。
3. FPGA 内部：包含 FMC 从机接口、双 16 位影子寄存器（用于原子写入 32 步进值）、32 位累加器、异步 FIFO（16-bit 宽，深度 1K）。
4. STM32 端：FMC 配置为同步 PSRAM 模式，时钟 110MHz，16 位数据总线。地址映射见STM32程序，请自行设计ADC的地址映射，要求有ADC启用关闭、ADC采样率设置、ADCDATA等。
5. 数据搬运：STM32 使用 DMA 双缓冲（乒乓）模式从 FMC 地址自动读取 FIFO 数据，CPU 在中断回调中处理已填满的半区数据。
6. 关键约束：FMC 映射区域必须配置 MPU 为 Device/非缓存属性；FPGA 内 10MHz（ADC域）与 110MHz（FMC域）为异步时钟，需设置异步时钟组。

【开发环境】
- FPGA：Quartus Prime Lite / Standard，Verilog 2001。
- STM32：STM32CubeMX 6.x + MDK-ARM（Keil）或 STM32CubeIDE，HAL 库。
- 辅助工具：逻辑分析仪（或 SignalTap II）用于调试时序。

请以此背景为基础，准备协助我进行后续的分阶段开发与代码生成。