module register(d, clk, clr, en, q);
	input [31:0]d;
	input clk, en, clr;
	output [31:0]q;

	wire clkEn;
	and and1(clkEn, clk, en);
	
	genvar i;
	generate
	for(i = 0 ; i < 32 ; i = i + 1) begin: loop
		my_dff a_dff(.d(d[i]), .clk(clkEn), .clr(clr), .q(q[i]));
	end
	endgenerate
endmodule
