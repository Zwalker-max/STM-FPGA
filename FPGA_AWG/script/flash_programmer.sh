#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-generate-files.
#

$SOPC_KIT_NIOS2/bin/sof2flash --input="E:/Temporary/AWG/AWG.sof" --output="E:/Temporary/AWG/flash/AWG_epcs_flash_controller_0.flash" --epcs --verbose 

$SOPC_KIT_NIOS2/bin/nios2-flash-programmer "E:/Temporary/AWG/flash/AWG_epcs_flash_controller_0.flash" --base=0x1001800 --epcs --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster [USB-0]' --program --verbose 

$SOPC_KIT_NIOS2/bin/elf2flash --input="E:/Temporary/AWG/software/awg/awg.elf" --output="E:/Temporary/AWG/flash/awg_epcs_flash_controller_0.flash" --epcs --after="E:/Temporary/AWG/flash/AWG_epcs_flash_controller_0.flash" --verbose 

$SOPC_KIT_NIOS2/bin/nios2-flash-programmer "E:/Temporary/AWG/flash/awg_epcs_flash_controller_0.flash" --base=0x1001800 --epcs --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster [USB-0]' --program --verbose 

