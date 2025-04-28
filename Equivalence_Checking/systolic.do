set log file systolic_lec.log -replace
read library ../LIB/slow_vdd1v0_basicCells.v -verilog -both
read design \
   ../RTL/tpu_top.v \
   ../RTL/addr_sel.v \
   ../RTL/quantize.v \
   ../RTL/systolic.v \
   ../RTL/systolic_controll.v \
   ../RTL/write_out.v \
   -verilog -golden

read design ../Synthesis/outputs/tpu_netlist.v -verilog -revised

set system mode lec
add compared point -all
compare
report verification
exit
