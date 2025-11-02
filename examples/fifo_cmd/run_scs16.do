# the following applies for modelsim simulator

# 1. run time sniffer prints
# when scsu runs, it prints the sniffing data on the simulator window
# for the data to be aligned, it is recommended to change the font to courier.
# all the sniffer prints are also available in the scs16_log in the simulation dir 

do ../../verilog/modelsim.tcl

vlog -work work   +incdir+.  +incdir+../../verilog  +define+SCS_AHB_IF \
../../verilog/ahb_slave.v     \
../../verilog/cgate.v	      \
../../verilog/imem.v	      \
../../verilog/dmem.v	      \
../../verilog/scs16.v	      \
../../verilog/scs16_wrapper.v \
../../verilog/scsu.v          \
../../verilog/scsu_tf.v
       
vsim work.scsu_tf
log -r /*
destroy .wave
do ../../verilog/wave_AHB.do
run 40us



