module my_dff(d, clk, clr, q);
	input d, clk, clr;
	output q;
	reg q;

	initial
	begin
	  q = 1'b0;
	end

	always @(posedge clk, posedge clr) begin
		q <= clr ? 1'b0 : d;
	end
endmodule
