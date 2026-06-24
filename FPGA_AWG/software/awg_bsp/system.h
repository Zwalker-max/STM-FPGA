/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'cpu_0' in SOPC Builder design 'AWG'
 * SOPC Builder design path: ../../AWG.sopcinfo
 *
 * Generated: Sat Jun 05 15:22:36 CST 2010
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x1001020
#define NIOS2_CPU_FREQ 50000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x0
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 25
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x800020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 25
#define NIOS2_RESET_ADDR 0x1001800


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_EPCS_FLASH_CONTROLLER
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_UART
#define __ALTERA_NIOS2


/*
 * System configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2"
#define ALT_CPU_FREQ 50000000
#define ALT_CPU_NAME "cpu_0"
#define ALT_DEVICE_FAMILY "CYCLONEII"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/uart_0"
#define ALT_STDERR_BASE 0x1002000
#define ALT_STDERR_DEV uart_0
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_uart"
#define ALT_STDIN "/dev/uart_0"
#define ALT_STDIN_BASE 0x1002000
#define ALT_STDIN_DEV uart_0
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_uart"
#define ALT_STDOUT "/dev/uart_0"
#define ALT_STDOUT_BASE 0x1002000
#define ALT_STDOUT_DEV uart_0
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_uart"
#define ALT_SYSTEM_NAME "AWG"


/*
 * UART2DPRAM configuration
 *
 */

#define ALT_MODULE_CLASS_UART2DPRAM altera_avalon_pio
#define UART2DPRAM_BASE 0x1002020
#define UART2DPRAM_BIT_CLEARING_EDGE_REGISTER 0
#define UART2DPRAM_BIT_MODIFYING_OUTPUT_REGISTER 0
#define UART2DPRAM_CAPTURE 0
#define UART2DPRAM_DATA_WIDTH 12
#define UART2DPRAM_DO_TEST_BENCH_WIRING 0
#define UART2DPRAM_DRIVEN_SIM_VALUE 0x0
#define UART2DPRAM_EDGE_TYPE "NONE"
#define UART2DPRAM_FREQ 50000000u
#define UART2DPRAM_HAS_IN 0
#define UART2DPRAM_HAS_OUT 1
#define UART2DPRAM_HAS_TRI 0
#define UART2DPRAM_IRQ -1
#define UART2DPRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define UART2DPRAM_IRQ_TYPE "NONE"
#define UART2DPRAM_NAME "/dev/UART2DPRAM"
#define UART2DPRAM_RESET_VALUE 0x800
#define UART2DPRAM_SPAN 16
#define UART2DPRAM_TYPE "altera_avalon_pio"


/*
 * WRaddress configuration
 *
 */

#define ALT_MODULE_CLASS_WRaddress altera_avalon_pio
#define WRADDRESS_BASE 0x1002030
#define WRADDRESS_BIT_CLEARING_EDGE_REGISTER 0
#define WRADDRESS_BIT_MODIFYING_OUTPUT_REGISTER 0
#define WRADDRESS_CAPTURE 0
#define WRADDRESS_DATA_WIDTH 10
#define WRADDRESS_DO_TEST_BENCH_WIRING 0
#define WRADDRESS_DRIVEN_SIM_VALUE 0x0
#define WRADDRESS_EDGE_TYPE "NONE"
#define WRADDRESS_FREQ 50000000u
#define WRADDRESS_HAS_IN 0
#define WRADDRESS_HAS_OUT 1
#define WRADDRESS_HAS_TRI 0
#define WRADDRESS_IRQ -1
#define WRADDRESS_IRQ_INTERRUPT_CONTROLLER_ID -1
#define WRADDRESS_IRQ_TYPE "NONE"
#define WRADDRESS_NAME "/dev/WRaddress"
#define WRADDRESS_RESET_VALUE 0x0
#define WRADDRESS_SPAN 16
#define WRADDRESS_TYPE "altera_avalon_pio"


/*
 * altera_extended_hal_bsp configuration
 *
 */

#define ALT_MAX_FD 32
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * dpram_rdclk_en configuration
 *
 */

#define ALT_MODULE_CLASS_dpram_rdclk_en altera_avalon_pio
#define DPRAM_RDCLK_EN_BASE 0x1002080
#define DPRAM_RDCLK_EN_BIT_CLEARING_EDGE_REGISTER 0
#define DPRAM_RDCLK_EN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DPRAM_RDCLK_EN_CAPTURE 0
#define DPRAM_RDCLK_EN_DATA_WIDTH 1
#define DPRAM_RDCLK_EN_DO_TEST_BENCH_WIRING 0
#define DPRAM_RDCLK_EN_DRIVEN_SIM_VALUE 0x0
#define DPRAM_RDCLK_EN_EDGE_TYPE "NONE"
#define DPRAM_RDCLK_EN_FREQ 50000000u
#define DPRAM_RDCLK_EN_HAS_IN 0
#define DPRAM_RDCLK_EN_HAS_OUT 1
#define DPRAM_RDCLK_EN_HAS_TRI 0
#define DPRAM_RDCLK_EN_IRQ -1
#define DPRAM_RDCLK_EN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DPRAM_RDCLK_EN_IRQ_TYPE "NONE"
#define DPRAM_RDCLK_EN_NAME "/dev/dpram_rdclk_en"
#define DPRAM_RDCLK_EN_RESET_VALUE 0x0
#define DPRAM_RDCLK_EN_SPAN 16
#define DPRAM_RDCLK_EN_TYPE "altera_avalon_pio"


/*
 * dpram_wr_en configuration
 *
 */

#define ALT_MODULE_CLASS_dpram_wr_en altera_avalon_pio
#define DPRAM_WR_EN_BASE 0x1002040
#define DPRAM_WR_EN_BIT_CLEARING_EDGE_REGISTER 0
#define DPRAM_WR_EN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DPRAM_WR_EN_CAPTURE 0
#define DPRAM_WR_EN_DATA_WIDTH 1
#define DPRAM_WR_EN_DO_TEST_BENCH_WIRING 0
#define DPRAM_WR_EN_DRIVEN_SIM_VALUE 0x0
#define DPRAM_WR_EN_EDGE_TYPE "NONE"
#define DPRAM_WR_EN_FREQ 50000000u
#define DPRAM_WR_EN_HAS_IN 0
#define DPRAM_WR_EN_HAS_OUT 1
#define DPRAM_WR_EN_HAS_TRI 0
#define DPRAM_WR_EN_IRQ -1
#define DPRAM_WR_EN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DPRAM_WR_EN_IRQ_TYPE "NONE"
#define DPRAM_WR_EN_NAME "/dev/dpram_wr_en"
#define DPRAM_WR_EN_RESET_VALUE 0x0
#define DPRAM_WR_EN_SPAN 16
#define DPRAM_WR_EN_TYPE "altera_avalon_pio"


/*
 * dpram_wrclk configuration
 *
 */

#define ALT_MODULE_CLASS_dpram_wrclk altera_avalon_pio
#define DPRAM_WRCLK_BASE 0x1002070
#define DPRAM_WRCLK_BIT_CLEARING_EDGE_REGISTER 0
#define DPRAM_WRCLK_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DPRAM_WRCLK_CAPTURE 0
#define DPRAM_WRCLK_DATA_WIDTH 1
#define DPRAM_WRCLK_DO_TEST_BENCH_WIRING 0
#define DPRAM_WRCLK_DRIVEN_SIM_VALUE 0x0
#define DPRAM_WRCLK_EDGE_TYPE "NONE"
#define DPRAM_WRCLK_FREQ 50000000u
#define DPRAM_WRCLK_HAS_IN 0
#define DPRAM_WRCLK_HAS_OUT 1
#define DPRAM_WRCLK_HAS_TRI 0
#define DPRAM_WRCLK_IRQ -1
#define DPRAM_WRCLK_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DPRAM_WRCLK_IRQ_TYPE "NONE"
#define DPRAM_WRCLK_NAME "/dev/dpram_wrclk"
#define DPRAM_WRCLK_RESET_VALUE 0x0
#define DPRAM_WRCLK_SPAN 16
#define DPRAM_WRCLK_TYPE "altera_avalon_pio"


/*
 * dpram_wrclk_en configuration
 *
 */

#define ALT_MODULE_CLASS_dpram_wrclk_en altera_avalon_pio
#define DPRAM_WRCLK_EN_BASE 0x1002050
#define DPRAM_WRCLK_EN_BIT_CLEARING_EDGE_REGISTER 0
#define DPRAM_WRCLK_EN_BIT_MODIFYING_OUTPUT_REGISTER 0
#define DPRAM_WRCLK_EN_CAPTURE 0
#define DPRAM_WRCLK_EN_DATA_WIDTH 1
#define DPRAM_WRCLK_EN_DO_TEST_BENCH_WIRING 0
#define DPRAM_WRCLK_EN_DRIVEN_SIM_VALUE 0x0
#define DPRAM_WRCLK_EN_EDGE_TYPE "NONE"
#define DPRAM_WRCLK_EN_FREQ 50000000u
#define DPRAM_WRCLK_EN_HAS_IN 0
#define DPRAM_WRCLK_EN_HAS_OUT 1
#define DPRAM_WRCLK_EN_HAS_TRI 0
#define DPRAM_WRCLK_EN_IRQ -1
#define DPRAM_WRCLK_EN_IRQ_INTERRUPT_CONTROLLER_ID -1
#define DPRAM_WRCLK_EN_IRQ_TYPE "NONE"
#define DPRAM_WRCLK_EN_NAME "/dev/dpram_wrclk_en"
#define DPRAM_WRCLK_EN_RESET_VALUE 0x0
#define DPRAM_WRCLK_EN_SPAN 16
#define DPRAM_WRCLK_EN_TYPE "altera_avalon_pio"


/*
 * epcs_flash_controller_0 configuration
 *
 */

#define ALT_MODULE_CLASS_epcs_flash_controller_0 altera_avalon_epcs_flash_controller
#define EPCS_FLASH_CONTROLLER_0_BASE 0x1001800
#define EPCS_FLASH_CONTROLLER_0_IRQ 1
#define EPCS_FLASH_CONTROLLER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define EPCS_FLASH_CONTROLLER_0_NAME "/dev/epcs_flash_controller_0"
#define EPCS_FLASH_CONTROLLER_0_REGISTER_OFFSET 512
#define EPCS_FLASH_CONTROLLER_0_SPAN 2048
#define EPCS_FLASH_CONTROLLER_0_TYPE "altera_avalon_epcs_flash_controller"


/*
 * freq_word configuration
 *
 */

#define ALT_MODULE_CLASS_freq_word altera_avalon_pio
#define FREQ_WORD_BASE 0x1002060
#define FREQ_WORD_BIT_CLEARING_EDGE_REGISTER 0
#define FREQ_WORD_BIT_MODIFYING_OUTPUT_REGISTER 0
#define FREQ_WORD_CAPTURE 0
#define FREQ_WORD_DATA_WIDTH 23
#define FREQ_WORD_DO_TEST_BENCH_WIRING 0
#define FREQ_WORD_DRIVEN_SIM_VALUE 0x0
#define FREQ_WORD_EDGE_TYPE "NONE"
#define FREQ_WORD_FREQ 50000000u
#define FREQ_WORD_HAS_IN 0
#define FREQ_WORD_HAS_OUT 1
#define FREQ_WORD_HAS_TRI 0
#define FREQ_WORD_IRQ -1
#define FREQ_WORD_IRQ_INTERRUPT_CONTROLLER_ID -1
#define FREQ_WORD_IRQ_TYPE "NONE"
#define FREQ_WORD_NAME "/dev/freq_word"
#define FREQ_WORD_RESET_VALUE 0x0
#define FREQ_WORD_SPAN 16
#define FREQ_WORD_TYPE "altera_avalon_pio"


/*
 * sdram_0 configuration
 *
 */

#define ALT_MODULE_CLASS_sdram_0 altera_avalon_new_sdram_controller
#define SDRAM_0_BASE 0x800000
#define SDRAM_0_CAS_LATENCY 3
#define SDRAM_0_CONTENTS_INFO ""
#define SDRAM_0_INIT_NOP_DELAY 0.0
#define SDRAM_0_INIT_REFRESH_COMMANDS 2
#define SDRAM_0_IRQ -1
#define SDRAM_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_0_IS_INITIALIZED 1
#define SDRAM_0_NAME "/dev/sdram_0"
#define SDRAM_0_POWERUP_DELAY 100.0
#define SDRAM_0_REFRESH_PERIOD 15.625
#define SDRAM_0_REGISTER_DATA_IN 1
#define SDRAM_0_SDRAM_ADDR_WIDTH 22
#define SDRAM_0_SDRAM_BANK_WIDTH 2
#define SDRAM_0_SDRAM_COL_WIDTH 8
#define SDRAM_0_SDRAM_DATA_WIDTH 16
#define SDRAM_0_SDRAM_NUM_BANKS 4
#define SDRAM_0_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_0_SDRAM_ROW_WIDTH 12
#define SDRAM_0_SHARED_DATA 0
#define SDRAM_0_SIM_MODEL_BASE 1
#define SDRAM_0_SPAN 8388608
#define SDRAM_0_STARVATION_INDICATOR 0
#define SDRAM_0_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_0_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_0_T_AC 5.5
#define SDRAM_0_T_MRD 3
#define SDRAM_0_T_RCD 20.0
#define SDRAM_0_T_RFC 70.0
#define SDRAM_0_T_RP 20.0
#define SDRAM_0_T_WR 14.0


/*
 * uart_0 configuration
 *
 */

#define ALT_MODULE_CLASS_uart_0 altera_avalon_uart
#define UART_0_BASE 0x1002000
#define UART_0_BAUD 19200
#define UART_0_DATA_BITS 8
#define UART_0_FIXED_BAUD 1
#define UART_0_FREQ 50000000u
#define UART_0_IRQ 0
#define UART_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define UART_0_NAME "/dev/uart_0"
#define UART_0_PARITY 'N'
#define UART_0_SIM_CHAR_STREAM ""
#define UART_0_SIM_TRUE_BAUD 0
#define UART_0_SPAN 32
#define UART_0_STOP_BITS 1
#define UART_0_SYNC_REG_DEPTH 2
#define UART_0_TYPE "altera_avalon_uart"
#define UART_0_USE_CTS_RTS 0
#define UART_0_USE_EOP_REGISTER 0

#endif /* __SYSTEM_H_ */
