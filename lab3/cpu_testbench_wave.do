onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate /cpu_testbench/clk
add wave -noupdate /cpu_testbench/reset
add wave -noupdate -divider {Instruction Fetch}
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/IF/currentPC
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instruction
add wave -noupdate -divider {Control & Flags}
add wave -noupdate /cpu_testbench/dut/CTL/BrTaken
add wave -noupdate /cpu_testbench/dut/CTL/UncondBr
add wave -noupdate /cpu_testbench/dut/negative
add wave -noupdate /cpu_testbench/dut/zero
add wave -noupdate /cpu_testbench/dut/overflow
add wave -noupdate /cpu_testbench/dut/carry_out
add wave -noupdate -divider Registers
add wave -noupdate -color {Sky Blue} -radix decimal /cpu_testbench/dut/DP/register/q
add wave -noupdate -divider Datapath
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/DP/Da
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/DP/Db
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/DP/ALUOut
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/DP/Dw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {565283075 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 196
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {690611424 ps}
