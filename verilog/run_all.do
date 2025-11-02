# set PrefMain(font) {{Courier New} 8 roman normal}
do modelsim.tcl

vlog -work work      ocp_slave.v  
vlog -work work      cgate.v
vlog -work work      imem.v
vlog -work work      dmem.v
vlog -work work      scs16.v
vlog -work work      scs16_wrapper.v  +define+SCS_OCP_IF
vlog -work work      scsu.v           +define+SCS_OCP_IF
vlog -work work      scsu_tf.v        +define+SCS_OCP_IF

vsim work.scsu_tf
log -r /*
run 40us
destroy .wave
do wave.do


