transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/maxii_ver
vmap maxii_ver ./verilog_libs/maxii_ver
vlog -vlog01compat -work maxii_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/maxii_atoms.v}

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {display.vo}

vlog -vlog01compat -work work +incdir+E:/Multisim\ and\ Quartus/Digital\ and\ Electrical\ Comprehensive\ Experiment/display_sight_test_new_new/tb {E:/Multisim and Quartus/Digital and Electrical Comprehensive Experiment/display_sight_test_new_new/tb/display_tb.v}

vsim -t 1ps -L maxii_ver -L gate_work -L work -voptargs="+acc"  display_tb

add wave *
view structure
view signals
run -all
