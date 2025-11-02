# files should come from the following 
# set PrefMain(font) {{Courier New} 8 roman normal}
do modelsim.tcl

vlog -work work      ahb_slave.v  
vlog -work work      ahb_tf.v        +define+SCS_AHB_IF

vsim work.ahb_tf
log -r /*
run 40us
destroy .wave
do ahb_wave.do


