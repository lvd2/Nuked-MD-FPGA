`define HALF_CLK (0.5)

`timescale 1ns/100ps

module tb;

	reg clk = 1'b1;
	reg mclk = 1'b1;
	reg rst_n;


	// clock
	always
	begin
		#(`HALF_CLK) mclk = ~mclk;
	end

	always @(posedge mclk)
	begin
		clk <= ~clk;
		@(posedge mclk); // clk must be 1/4 of mclk
	end

	// reset
	initial
	begin
		rst_n = 1'b0;

		repeat(10) @(posedge clk);

		rst_n <= 1'b1;
	end


	wire [15:0] zaddr;
	wire        zaddr_z;
	tri0 [ 7:0] zdata_i;
	wire [ 7:0] zdata_o;
	wire        zdata_z;
	wire        zm1_n;
	wire        zmreq_n;
	wire        zmreq_z;
	wire        ziorq_n;
	wire        ziorq_z;
	wire        zrd_n;
	wire        zrd_z;
	wire        zwr_n;
	wire        zwr_z;
	wire        zrfsh_n;
	wire        zhalt_n;
	tri1        zwait_n;
	tri1        zint_n;
	tri1        znmi_n;
	tri1        zbusrq_n;
	wire        zbusak_n;

	assign zdata_i = 8'h21;

	z80cpu z80cpu
	(
		.MCLK(mclk),
		.CLK (clk),
        
		.RESET    (rst_n),
        
		.ADDRESS  (zaddr   ),
		.ADDRESS_z(zaddr_z ),
		.DATA_i   (zdata_i ),
		.DATA_o   (zdata_o ),
		.DATA_z   (zdata_z ),
		.M1       (zm1_n   ),
		.MREQ     (zmreq_n ),
		.MREQ_z   (zmreq_z ),
		.IORQ     (ziorq_n ),
		.IORQ_z   (ziorq_z ),
		.RD       (zrd_n   ),
		.RD_z     (zrd_z   ),
		.WR       (zwr_n   ),
		.WR_z     (zwr_z   ),
		.RFSH     (zrfsh_n ),
		.HALT     (zhalt_n ),
		.WAIT     (zwait_n ),
		.INT      (zint_n  ),
		.NMI      (znmi_n  ),
		.BUSRQ    (zbusrq_n),
		.BUSAK    (zbusak_n)
	);




endmodule

