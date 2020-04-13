transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/intelFPGA_lite/top {D:/intelFPGA_lite/top/top.v}
vlog -vlog01compat -work work +incdir+D:/intelFPGA_lite/top {D:/intelFPGA_lite/top/ram.v}

