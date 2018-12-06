module register8(d, clk, clr, pr, en, q);
	input [7:0]d;
	input clk, en, clr, pr;
	output [7:0]q;
	
	genvar i;
	generate
	for(i = 0 ; i < 8 ; i = i + 1) begin: loop
		dflipflop a_dff(.d(d[i]), .clk(clk), .clr(clr), .pr(pr), .ena(en), .q(q[i]));
	end
	endgenerate
endmodule
