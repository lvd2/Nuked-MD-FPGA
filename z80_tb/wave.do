onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group z80_sigs /tb/clk
add wave -noupdate -expand -group z80_sigs /tb/mclk
add wave -noupdate -expand -group z80_sigs /tb/rst_n
add wave -noupdate -expand -group z80_sigs /tb/zaddr
add wave -noupdate -expand -group z80_sigs /tb/zdata_i
add wave -noupdate -expand -group z80_sigs /tb/zdata_o
add wave -noupdate -expand -group z80_sigs /tb/zm1_n
add wave -noupdate -expand -group z80_sigs /tb/zmreq_n
add wave -noupdate -expand -group z80_sigs /tb/zrd_n
add wave -noupdate -expand -group z80_sigs /tb/zwr_n
add wave -noupdate -expand -group z80_sigs /tb/ziorq_n
add wave -noupdate -expand -group z80_sigs /tb/zrfsh_n
add wave -noupdate -expand -group z80_sigs /tb/zhalt_n
add wave -noupdate -expand -group z80_sigs /tb/zwait_n
add wave -noupdate -expand -group z80_sigs /tb/zint_n
add wave -noupdate -expand -group z80_sigs /tb/znmi_n
add wave -noupdate -expand -group z80_sigs /tb/zbusrq_n
add wave -noupdate -expand -group z80_sigs /tb/zbusak_n
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/zaddr_z
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/zdata_z
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/zmreq_z
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/ziorq_z
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/zrd_z
add wave -noupdate -expand -group z80_sigs -group z80_zz /tb/zwr_z
add wave -noupdate -expand -subitemconfig {{/tb/z80cpu/regs[0]} -expand} /tb/z80cpu/regs
add wave -noupdate -expand -subitemconfig {{/tb/z80cpu/regs2[1]} -expand {/tb/z80cpu/regs2[0]} -expand} /tb/z80cpu/regs2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3258400 ps} 0}
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
WaveRestoreZoom {199639400 ps} {200019 ns}
