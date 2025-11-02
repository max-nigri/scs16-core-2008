onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ahb_tf/clk
add wave -noupdate -format Logic /ahb_tf/rst
add wave -noupdate -format Literal /ahb_tf/cycles
add wave -noupdate -format Literal -radix unsigned /ahb_tf/ahb_scsu_s_mhtrans
add wave -noupdate -format Literal /ahb_tf/ahb_scsu_s_mhsize
add wave -noupdate -format Logic /ahb_tf/ahb_scsu_s_mhwrite
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_scsu_s_mhaddr
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_scsu_s_mhwdata
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/scsu_s_ahb_shrdata
add wave -noupdate -format Logic /ahb_tf/scsu_s_ahb_shready
add wave -noupdate -format Literal /ahb_tf/scsu_s_ahb_shresp
add wave -noupdate -divider {slave internal}
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_slave/slave_ram
add wave -noupdate -format Logic /ahb_tf/ahb_slave/s_wr
add wave -noupdate -format Literal /ahb_tf/ahb_slave/s_size
add wave -noupdate -format Logic /ahb_tf/ahb_slave/s_cs
add wave -noupdate -format Literal -radix decimal /ahb_tf/ahb_slave/wait_cnt
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_slave/scsu_m_ahb_mhaddr_latch
add wave -noupdate -format Literal /ahb_tf/ahb_slave/scsu_m_ahb_mhsize_latch
add wave -noupdate -format Logic /ahb_tf/ahb_slave/scsu_m_ahb_mhwrite_latch
add wave -noupdate -divider {slave ram}
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_wr
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_cs
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_slave/s_addr
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_slave/s_rd_data
add wave -noupdate -format Literal -radix hexadecimal /ahb_tf/ahb_slave/s_wr_data
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_wr
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_cs
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_ack
add wave -noupdate -format Logic /ahb_tf/ahb_slave/access_start
add wave -noupdate -format Logic /ahb_tf/ahb_slave/ram_rd_valid
add wave -noupdate -format Logic /ahb_tf/ahb_slave/internal_ready
add wave -noupdate -format Literal -radix unsigned /ahb_tf/ahb_slave/wait_cnt1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7249 ns} 0}
WaveRestoreZoom {6917 ns} {7557 ns}
configure wave -namecolwidth 259
configure wave -valuecolwidth 46
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
