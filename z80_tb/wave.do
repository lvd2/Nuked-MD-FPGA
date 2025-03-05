onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/mclk
add wave -noupdate /tb/rst_n
add wave -noupdate /tb/zaddr
add wave -noupdate /tb/zaddr_z
add wave -noupdate /tb/zdata_i
add wave -noupdate /tb/zdata_o
add wave -noupdate /tb/zdata_z
add wave -noupdate /tb/zm1_n
add wave -noupdate /tb/zmreq_n
add wave -noupdate /tb/zmreq_z
add wave -noupdate /tb/ziorq_n
add wave -noupdate /tb/ziorq_z
add wave -noupdate /tb/zrd_n
add wave -noupdate /tb/zrd_z
add wave -noupdate /tb/zwr_n
add wave -noupdate /tb/zwr_z
add wave -noupdate /tb/zrfsh_n
add wave -noupdate /tb/zhalt_n
add wave -noupdate /tb/zwait_n
add wave -noupdate /tb/zint_n
add wave -noupdate /tb/znmi_n
add wave -noupdate /tb/zbusrq_n
add wave -noupdate /tb/zbusak_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 20
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {53200 ps}
