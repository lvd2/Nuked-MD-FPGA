module ram
(
	input  wire [15:0] addr_i,
	input  wire [ 7:0] data_i,
	output reg  [ 7:0] data_o,
	input  wire        we_i
);

	bit [7:0] array [65536];

	always @*
	begin
		if( we_i )
			array[addr_i] = data_i;
	end

	assign data_o = array[addr_i];

endmodule

