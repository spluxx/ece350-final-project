module counter33(clk, reset, isReady);
	input clk, reset;
	output isReady;
	wire [31:0] Q;
	
	genvar i;
	generate
		for(i = 0 ; i <= 30 ; i = i + 1) begin: loop
			dflipflop flops(.d(Q[i+1]), .clk(clk), .clr(reset), .pr(1'b0), .ena(1'b1), .q(Q[i]));
		end
	endgenerate
	dflipflop dff32(.d(1'b0), .clk(clk), .clr(1'b0), .pr(reset), .ena(1'b1), .q(Q[31]));
	
	assign isReady = Q[0];
endmodule
