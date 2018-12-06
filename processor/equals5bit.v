module equals5bit(verdict, a, b);
	output verdict;
	input [4:0] a, b;
	assign verdict = ~((a[4] ^ b[4]) | (a[3] ^ b[3]) | (a[2] ^ b[2]) | (a[1] ^ b[1]) | (a[0] ^ b[0]));
endmodule 