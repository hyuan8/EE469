# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./full_adders.sv"
vlog "./muxes.sv"
vlog "./bit_slice.sv"
vlog "./alu.sv"
vlog "./datapath.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./math.sv"
vlog "./decoders.sv"
vlog "./D_FF.sv"
vlog "./D_FF_enable.sv"
vlog "./regfile.sv"
vlog "./sign_extender.sv"
vlog "./control.sv"
vlog "./program_counter.sv"
vlog "./instruction_fetch.sv"
vlog "./cpu.sv"
vlog "./zero_extender.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_testbench_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
