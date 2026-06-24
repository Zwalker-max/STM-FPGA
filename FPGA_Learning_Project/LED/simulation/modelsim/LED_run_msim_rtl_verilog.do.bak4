transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/FPGA_Learning_Project {D:/File/CubeMX/STM-FPGA/FPGA_Learning_Project/LED.v}

vlog -vlog01compat -work work +incdir+D:/File/CubeMX/STM-FPGA/FPGA_Learning_Project/output_files {D:/File/CubeMX/STM-FPGA/FPGA_Learning_Project/output_files/tb_LED.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_LED

add wave *
view structure
view signals
run -all
