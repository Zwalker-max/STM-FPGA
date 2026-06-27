# Quartus II Tcl Script: Generate BSF symbols for DDS modules
# Run in Quartus: Tools -> Tcl Scripts -> Run this script
# OR: quartus_sh -t generate_bsf.tcl

# Load the project
project_open FMC_Demo

# Generate BSF for dds_core.v
set dds_core_path [file join [pwd] "dds_core.v"]
if {[file exists $dds_core_path]} {
    create_symbol_file -overwrite $dds_core_path
    puts "SUCCESS: dds_core.bsf generated"
} else {
    puts "ERROR: dds_core.v not found at $dds_core_path"
}

# Generate BSF for dac_control.v
set dac_control_path [file join [pwd] "dac_control.v"]
if {[file exists $dac_control_path]} {
    create_symbol_file -overwrite $dac_control_path
    puts "SUCCESS: dac_control.bsf generated"
} else {
    puts "ERROR: dac_control.v not found at $dac_control_path"
}

# Update BSF for the modified stm32_fmc_16bit.v
set fmc_path [file join [pwd] "stm32_fmc_16bit.v"]
if {[file exists $fmc_path]} {
    create_symbol_file -overwrite $fmc_path
    puts "SUCCESS: stm32_fmc_16bit.bsf regenerated (with new ports)"
} else {
    puts "ERROR: stm32_fmc_16bit.v not found at $fmc_path"
}

project_close
puts "BSF generation complete."
puts "IMPORTANT: After running this script, update FMC_Demo.bdf in the Block Editor."
puts "You must re-add the updated stm32_fmc_16bit symbol and wire the new ports."
