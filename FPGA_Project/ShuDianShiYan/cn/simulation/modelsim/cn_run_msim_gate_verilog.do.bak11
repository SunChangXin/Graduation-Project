transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/maxii_ver
vmap maxii_ver ./verilog_libs/maxii_ver
vlog -vlog01compat -work maxii_ver {d:/quartus/quartus/eda/sim_lib/maxii_atoms.v}

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {cn.vo}

vlog -vlog01compat -work work +incdir+D:/ShuDianShiYan/cn {D:/ShuDianShiYan/cn/cn_tb.v}

vsim -t 1ps -L maxii_ver -L gate_work -L work -voptargs="+acc"  cn_tb

add wave *
view structure
view signals
run -all
