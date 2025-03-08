`define HALF_CLK (0.5)

`define START_PC (16'h8000)

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

	always
	begin
		@(posedge mclk); //
		@(posedge mclk); //
		@(posedge mclk); //
		@(posedge mclk); //
		clk <= ~clk;
	end

	// reset
	initial
	begin
		rst_n = 1'b0;

		repeat(10) @(posedge clk);

		rst_n <= 1'b1;
	end


	wire [15:0] zaddr_o;
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

	// regs[0][0](15:8) -- accu at rd 1->0
	// regs2[0][0] - nextPC, [0][1] - its inverse
	z80cpu z80cpu
	(
		.MCLK(mclk),
		.CLK (clk),
        
		.RESET    (rst_n),
        
		.ADDRESS  (zaddr_o ),
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

	// fix start PC
/*	initial
	begin
		wait(rst_n===1'b1);
		@(posedge mclk);

		force z80cpu.regs2[0][0] =  `START_PC;
		force z80cpu.regs2[0][1] = ~`START_PC;

		wait(zaddr_z===1'b0);
		@(posedge zm1_n);

		release z80cpu.regs2[0][0];
		release z80cpu.regs2[0][1];
	end
*/


	wire [15:0] zaddr = (zaddr_z || !zrfsh_n) ? 16'hZZZZ : zaddr_o;
	wire [ 7:0] zdata_wr = zdata_z ? 8'hZZ : zdata_o;
	wire ram_wr = !zmreq_n && !zmreq_z && !zwr_n && !zwr_z;
	wire [ 7:0] ram_data_rd;
	reg  [ 7:0] rom_data_rd;

	assign zdata_i = (zaddr<16'h4000) ? rom_data_rd : ram_data_rd;

	// RAM
	ram ram
	(
		.addr_i(zaddr),
		.data_i(zdata_wr),
		.data_o(ram_data_rd),
		.we_i  (ram_wr)
	);

	// load RAM
	initial
	begin : load_test

		integer fd,code;

		fd = $fopen(`TESTFILE,"rb");
		if( !fd )
		begin
			$display("%m: error opening file %s!",`TESTFILE);
			$stop();
		end

		code=$fread(ram.array,fd,32768);
		if( !code )
		begin
			$display("%m: can't read file %s!",`TESTFILE);
			$stop();
		end
	end


	// small ROM
	int halt=0;
	always @*
	begin
		case(zaddr)
		16'h0000: if( !halt ) rom_data_rd = 8'h31; // ld sp,fffd
		          else rom_data_rd = 8'h76;
		16'h0001: rom_data_rd = 8'hfd;
		16'h0002: rom_data_rd = 8'hff;

		16'h0003: begin rom_data_rd = 8'hc3; // jp 8000
		          halt=1; end
		16'h0004: rom_data_rd = 8'h00;
		16'h0005: rom_data_rd = 8'h80;

		16'h1601: rom_data_rd = 8'hc9; // ret

		16'h0010: rom_data_rd = 8'hc9; // ret

		default: rom_data_rd = 8'hXX;
		endcase
	end

	// rst 0x10 printer
	int skip=0;
	initial
	begin
		wait(rst_n===1'b1);

		forever
		begin
			@(negedge zmreq_n);
			if( !zmreq_z && !zm1_n && zaddr==16'h0010 )
			begin : print
				reg [7:0] a;

				if( !skip )
				begin
					a = z80cpu.regs[0][0]>>8;
					if( a==13 )
						$display(" ");
					else if( a==23 )
						skip=2;
					else
						$write("%c",a);
				end
				else
					skip=skip-1;
			end
		end
	end

	// stop condition
	initial
	begin
		wait(rst_n===1'b1);
		wait(zhalt_n===1'b0);
		$stop;
	end

endmodule

