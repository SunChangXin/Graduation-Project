transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {d:/quartus/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {d:/quartus/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/fiftyfivenm_ver
vmap fiftyfivenm_ver ./verilog_libs/fiftyfivenm_ver
vlog -vlog01compat -work fiftyfivenm_ver {d:/quartus/quartus/eda/sim_lib/fiftyfivenm_atoms.v}
vlog -vlog01compat -work fiftyfivenm_ver {d:/quartus/quartus/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v}

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {led_test.vo}

vlog -vlog01compat -work work +incdir+D:/ShuDianShiYan/led_test {D:/ShuDianShiYan/led_test/led_test_tb.v}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L gate_work -L work -voptargs="+acc"  led_test_tb

add wave *
view structure
view signals
run -all
