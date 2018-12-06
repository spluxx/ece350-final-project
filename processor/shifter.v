module shifter(in, by, direction, lo, out); // direction 0 left, direction 1 right
	input signed [31:0] in;
	input [4:0] by;
	input lo, direction;
	output signed [31:0] out;
	
	assign out = lo ? 		
						(direction ? (in >> by) : (in << by)) :
						(direction ? (in >>> by) : (in << by));
endmodule 