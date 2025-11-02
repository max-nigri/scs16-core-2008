onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /scsu_tf/clk
add wave -noupdate -format Logic /scsu_tf/rst
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/rst
add wave -noupdate -format Literal /scsu_tf/cycles
add wave -noupdate -format Literal -radix ascii /scsu_tf/scsu_0/x_scs16/msg
add wave -noupdate -format Literal -radix unsigned /scsu_tf/scsu_0/x_scs16/pc
add wave -noupdate -divider Debug
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/bkpt
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/cont
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/step
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/no_update
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/no_update_pcir
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16/debug_state
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/cmd_boundery
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/wait_via_branch
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/first_in_halt
add wave -noupdate -divider {AHB slave internal}
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_some_cs
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_rnw
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_ack
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_imem_cs
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_dmem_cs
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/s_rfile_cs
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/s_addr
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/s_wr_data
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/s_be
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/internal_ready
add wave -noupdate -divider {clock gating}
add wave -noupdate -format Logic /scsu_tf/scsu_0/scs16_clk
add wave -noupdate -format Logic /scsu_tf/scsu_0/mems_clk
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/glue_clk
add wave -noupdate -divider {glue regs}
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/SCSU_CTL
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/SCSU_GPR0
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/SCSU_GPR1
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/SCSU_TST
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/SCSU_MSI
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/APP_OUT0
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/APP_OUT1
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT2
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT3
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT4
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT5
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT6
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/APP_OUT7
add wave -noupdate -format Logic -height 15 {/scsu_tf/scsu_0/x_scs16/pulse[4]}
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scs16_app_out_cs
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/app_out_addr
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/app_out_be
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/app_out_wr_data
add wave -noupdate -divider imem
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/iram_rd_data
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/iram_wr_data
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/iram_addr
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/iram_we
add wave -noupdate -format Logic -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/iram_cs
add wave -noupdate -divider dram
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/dram_rd_data
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/dram_wr_data
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/dram_addr
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/dram_we
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/dram_cs
add wave -noupdate -divider scs16
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/interupt
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16/hard_break
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16/condition
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/S0
add wave -noupdate -format Analog-Step -offset -10000.0 -radix hexadecimal -scale 0.002 /scsu_tf/scsu_0/x_scs16/S1
add wave -noupdate -format Literal -radix unsigned -scale 0.001 /scsu_tf/scsu_0/x_scs16/S1
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/device
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16/pulse
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R0
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R1
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R2
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R3
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R4
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R5
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R6
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/R7
add wave -noupdate -divider {AHB Slave}
add wave -noupdate -format Logic /scsu_tf/scsu_0/scs16_clk
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_s_mhtrans
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_s_mhsize
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_s_mhwrite
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_s_mhaddr
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_s_mhwdata
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_s_ahb_shrdata
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scsu_s_ahb_shready
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_s_ahb_shresp
add wave -noupdate -divider {AHB Master <-> Slave Ram}
add wave -noupdate -format Logic /scsu_tf/ahb_slave/ram_wr
add wave -noupdate -format Logic /scsu_tf/ahb_slave/ram_cs
add wave -noupdate -format Logic /scsu_tf/ahb_slave/ram_ack
add wave -noupdate -divider {AHB Master}
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/ext_bus_en
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scs16_ext_bus_cs
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scs16_ext_bus_done
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scs16_dram_cs
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/mh_state
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16/ram_rd_data
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/master_access_start
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_m_ahb_mhtrans
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_m_ahb_mhsize
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/scsu_m_ahb_mhwrite
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_m_ahb_mhaddr
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/scsu_m_ahb_mhwdata
add wave -noupdate -format Literal -radix hexadecimal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_m_shrdata
add wave -noupdate -format Logic /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_m_shready
add wave -noupdate -format Literal /scsu_tf/scsu_0/x_scs16_wrapper/ahb_scsu_m_shresp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8436 ns} 0}
WaveRestoreZoom {7483 ns} {9361 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
