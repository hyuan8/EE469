onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate /cpu_testbench/clk
add wave -noupdate /cpu_testbench/reset
add wave -noupdate -divider {Instruction Fetch (IF)}
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/currentPC
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instruction_IF
add wave -noupdate -divider {Instruction Decode (ID)}
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/instruction_ID
add wave -noupdate -radix unsigned /cpu_testbench/dut/Rn_ID
add wave -noupdate -radix unsigned /cpu_testbench/dut/Ab_ID
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/Da_ID
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/Db_ID
add wave -noupdate -divider {Forwarding Unit Diagnostics}
add wave -noupdate -radix unsigned /cpu_testbench/dut/Rn_EX
add wave -noupdate -radix unsigned /cpu_testbench/dut/FU/Rd_MEM
add wave -noupdate -radix unsigned /cpu_testbench/dut/FU/Rd_WB
add wave -noupdate -color Yellow /cpu_testbench/dut/ForwardA
add wave -noupdate -color Cyan -radix hexadecimal /cpu_testbench/dut/ForwardA_out
add wave -noupdate -radix unsigned /cpu_testbench/dut/Rm_EX
add wave -noupdate -color Yellow /cpu_testbench/dut/ForwardB
add wave -noupdate -color Cyan -radix hexadecimal /cpu_testbench/dut/ForwardB_out
add wave -noupdate -divider {Execute (EX) Math & Control}
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/ALUB_EX
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/ALUOut_EX
add wave -noupdate /cpu_testbench/dut/BrTaken_EX
add wave -noupdate -divider {Memory (MEM)}
add wave -noupdate /cpu_testbench/dut/MemWrite_MEM
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/ALUOut_MEM
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/Db_MEM
add wave -noupdate -radix hexadecimal /cpu_testbench/dut/Dout_MEM
add wave -noupdate -divider {Writeback (WB)}
add wave -noupdate /cpu_testbench/dut/RegWrite_WB
add wave -noupdate -radix unsigned /cpu_testbench/dut/Rd_WB
add wave -noupdate -color Green -radix hexadecimal /cpu_testbench/dut/Dw_WB
add wave -noupdate -divider {Register File State}
add wave -noupdate -color {Sky Blue} -radix decimal /cpu_testbench/dut/register/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6717829883 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 385
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
WaveRestoreZoom {0 ps} {10589250 ns}
