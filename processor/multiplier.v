module multiplier(A, B, clk, fetch, res, exception);
	input [31:0] A, B;
	input fetch, clk;
	output [31:0] res;
	output exception;

	assign res = A * B;
	assign exception = 1'b0;
endmodule
