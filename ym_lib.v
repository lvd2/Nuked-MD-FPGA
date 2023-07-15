// ym3438, ym7101, fc1004 common cells

module ym_sr_bit #(parameter SR_LENGTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input bit_in,
	output sr_out
	);
	
	reg [SR_LENGTH-1:0] v1 = 0;
	reg [SR_LENGTH-1:0] v2 = 0;
	
	wire [SR_LENGTH-1:0] v2_assign = c2 ? v1 : v2;
	
	assign sr_out = v2_assign[SR_LENGTH-1];
	
	always @(posedge MCLK)
	begin
		if (c1)
		begin
			if (SR_LENGTH == 1)
				v1 <= bit_in;
			else
				v1 <= { v2[SR_LENGTH-2:0], bit_in };
		end
		v2 <= v2_assign;
	end


endmodule

module ym_sr_bit_array #(parameter SR_LENGTH = 1, DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out
	);
	
	wire out[0:DATA_WIDTH-1];
	
	generate
		genvar i;
		for (i = 0; i < DATA_WIDTH; i = i + 1)
		begin : l1
			ym_sr_bit #(.SR_LENGTH(SR_LENGTH)) sr (
			.MCLK(MCLK),
			.c1(c1),
			.c2(c2),
			.bit_in(data_in[i]),
			.sr_out(out[i])
			);
			
			assign data_out[i] = out[i];
		end
	endgenerate

endmodule

module ym_cnt_bit #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input c_in,
	input reset,
	output [DATA_WIDTH-1:0] val,
	output c_out
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	wire [DATA_WIDTH:0] sum;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
	
	assign sum = data_out + c_in;
	assign val = data_out;
	assign data_in = reset ? {DATA_WIDTH{1'h0}} : sum[DATA_WIDTH-1:0];
	assign c_out = sum[DATA_WIDTH];
	
endmodule

module ym_dlatch_1 #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input [DATA_WIDTH-1:0] inp,
	output [DATA_WIDTH-1:0] val,
	output [DATA_WIDTH-1:0] nval
	);
	
	reg [DATA_WIDTH-1:0] mem = {DATA_WIDTH{1'h0}};
	
	wire [DATA_WIDTH-1:0] mem_assign = c1 ? inp : mem;
	
	always @(posedge MCLK)
	begin
		mem <= mem_assign;
	end
	
	assign val = mem_assign;
	assign nval = ~mem_assign;
	
endmodule

module ym_dlatch_2 #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c2,
	input [DATA_WIDTH-1:0] inp,
	output [DATA_WIDTH-1:0] val,
	output [DATA_WIDTH-1:0] nval
	);
	
	reg [DATA_WIDTH-1:0] mem = {DATA_WIDTH{1'h0}};
	
	wire [DATA_WIDTH-1:0] mem_assign = c2 ? inp : mem;
	
	always @(posedge MCLK)
	begin
		mem <= mem_assign;
	end
	
	assign val = mem_assign;
	assign nval = ~mem_assign;
	
endmodule

module ym_edge_detect
	(
	input MCLK,
	input c1,
	input inp,
	output outp
	);
	
	wire prev_out;
	
	ym_dlatch_1 prev
		(
		.MCLK(MCLK),
		.c1(c1),
		.inp(inp),
		.val(prev_out),
		.nval()
		);
	assign outp = ~(prev_out | ~inp);
endmodule

module ym_slatch #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input en,
	input [DATA_WIDTH-1:0] inp,
	output [DATA_WIDTH-1:0] val,
	output [DATA_WIDTH-1:0] nval
	);
	
	reg [DATA_WIDTH-1:0] mem = {DATA_WIDTH{1'h0}};
	
	wire [DATA_WIDTH-1:0] mem_assign = en ? inp : mem;
	
	always @(posedge MCLK)
	begin
		mem <= mem_assign;
	end
	
	assign val = mem_assign;
	assign nval = ~mem_assign;
	
endmodule

module ym_rs_trig
	(
	input MCLK,
	input set,
	input rst,
	output q,
	output nq
	);
	
	reg mem = 1'h0;
	
	assign q = rst ? 1'h0 : (set ? 1'h1 : mem);
	assign nq = set ? 1'h0 : (rst ? 1'h1 : ~mem); 
	
	always @(posedge MCLK)
	begin
		mem <= q;
	end
	
endmodule

module ym_rs_trig_sync
	(
	input MCLK,
	input set,
	input rst,
	input c1,
	output q,
	output nq
	);
	
	reg mem = 1'h0;
	
	assign q = (c1 & rst) ? 1'h0 : ((c1 & set) ? 1'h1 : mem);
	assign nq = (c1 & set) ? 1'h0 : ((c1 & rst) ? 1'h1 : ~mem); 
	
	always @(posedge MCLK)
	begin
		mem <= q;
	end
	
endmodule

module ym_cnt_bit_load #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input c_in,
	input reset,
	input load,
	input [DATA_WIDTH-1:0] load_val,
	output [DATA_WIDTH-1:0] val,
	output c_out
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	wire [DATA_WIDTH:0] sum;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
	
	wire [DATA_WIDTH-1:0] base_val = load ? load_val : data_out;
	
	assign sum = base_val + c_in;
	assign data_in = reset ? {DATA_WIDTH{1'h0}} : sum[DATA_WIDTH-1:0];
	assign val = data_out;
	assign c_out = sum[DATA_WIDTH];
	
endmodule

module ym_dbg_read #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input prev,
	input load,
	input [DATA_WIDTH-1:0] load_val,
	output next
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
		
	wire [DATA_WIDTH-1:0] chain;
	
	assign data_in = chain | (load ? load_val : {DATA_WIDTH{1'h0}});
	
	generate
		if (DATA_WIDTH == 1)
			assign chain = prev;
		else
			assign chain = { prev, data_out[DATA_WIDTH-1:1] };
	endgenerate
	
	assign next = data_out[0];
	
endmodule

module ym_dbg_read_eg #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input prev,
	input load,
	input [DATA_WIDTH-1:0] load_val,
	output next
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
		
	wire [DATA_WIDTH-1:0] chain;
	
	assign data_in = chain | (load ? load_val : {DATA_WIDTH{1'h0}});
	
	generate
		if (DATA_WIDTH == 1)
			assign chain = prev;
		else
			assign chain = { data_out[DATA_WIDTH-2:0], prev };
	endgenerate
	
	assign next = data_out[DATA_WIDTH-1];
	
endmodule

module ym_slatch_r #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input en,
	input rst,
	input [DATA_WIDTH-1:0] inp,
	output [DATA_WIDTH-1:0] val,
	output [DATA_WIDTH-1:0] nval
	);
	
	reg [DATA_WIDTH-1:0] mem = {DATA_WIDTH{1'h0}};
	
	wire [DATA_WIDTH-1:0] mem_assign = rst ? {DATA_WIDTH{1'h0}} : (en ? inp : mem);
	
	always @(posedge MCLK)
	begin
		mem <= mem_assign;
	end
	
	assign val = mem_assign;
	assign nval = ~mem_assign;
	
endmodule

module ym_cnt_bit_rs #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input c_in,
	input reset,
	input set,
	output [DATA_WIDTH-1:0] val,
	output [DATA_WIDTH-1:0] nval,
	output c_out
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	wire [DATA_WIDTH-1:0] data_out_s = set ? {DATA_WIDTH{1'h1}} : data_out;
	wire [DATA_WIDTH:0] sum;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
	
	assign sum = data_out_s + c_in;
	assign val = data_out_s;
	assign nval = ~data_out_s;
	assign data_in = reset ? {DATA_WIDTH{1'h0}} : sum[DATA_WIDTH-1:0];
	assign c_out = sum[DATA_WIDTH];
	
endmodule

module ym_cnt_bit_rev #(parameter DATA_WIDTH = 1)
	(
	input MCLK,
	input c1,
	input c2,
	input c_in,
	input dec,
	input reset,
	output [DATA_WIDTH-1:0] val,
	output c_out
	);
	
	wire [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;
	wire [DATA_WIDTH:0] sum;
	
	ym_sr_bit_array #(.DATA_WIDTH(DATA_WIDTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(data_in),
		.data_out(data_out)
		);
	
	assign sum = data_out + {DATA_WIDTH{dec}} + c_in;
	assign val = data_out;
	assign data_in = reset ? {DATA_WIDTH{1'h0}} : sum[DATA_WIDTH-1:0];
	assign c_out = sum[DATA_WIDTH];
	
endmodule

module ym_sr_bit_en #(parameter SR_LENGTH = 2)
	(
	input MCLK,
	input c1,
	input c2,
	input en1,
	input en2,
	input data_in,
	output [SR_LENGTH-1:0] data_out
	);
	
	wire [SR_LENGTH-1:0] sr_out;
	wire [SR_LENGTH-1:0] sr_in =
		(en1 ? { sr_out[SR_LENGTH-2:0], data_in } : {SR_LENGTH{1'h0}}) |
		(en2 ? sr_out : {SR_LENGTH{1'h0}});
	
	assign data_out = sr_out;
	
	ym_sr_bit_array #(.DATA_WIDTH(SR_LENGTH)) mem
		(
		.MCLK(MCLK),
		.c1(c1),
		.c2(c2),
		.data_in(sr_in),
		.data_out(sr_out)
		);

endmodule
