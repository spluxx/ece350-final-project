module shiftRightRegister(in, clk, clr, out);
	input in, clk, clr;
	output [31:0] out;
	wire[31:0] Q;
	
	genvar i;
	generate
		for(i = 1 ; i < 32 ; i = i + 1) begin: loop
			//dflipflop(d, clk, clr, pr, ena, q)
			dflipflop dff(.d(Q[i-1]), .clk(clk), .clr(clr), .pr(1'b0), .ena(1'b1), .q(Q[i]));
		end
		for(i = 0 ; i < 32 ; i = i + 1) begin: loop2
			assign out[i] = Q[i];
		end
	endgenerate
	dflipflop entryPoint(.d(in), .clk(clk), .clr(clr), .pr(1'b0), .ena(1'b1), .q(Q[0]));
endmodule 