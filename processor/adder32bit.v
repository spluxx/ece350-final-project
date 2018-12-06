module adder32bit(a, b, ctrl_sub, s, p, g, isOvf, isNotEqual, isLessThan); // p=OR, g=AND
	input [31:0] a, b;
	input ctrl_sub;
	
	output [31:0] s, p, g;
	output isOvf, isNotEqual, isLessThan;
	
	wire P2, P1, P0;
	wire G2, G1, G0;
	wire z3, z2, z1, z0;
	wire c7, c15, c23;
	wire [31:0] xo;
	wire neq0, neq1, neq2, neq3, neq4, neq5, neq6, neq7;
	
	wire propi0, propi1, propi2;
	wire prop01, prop02, prop12;
	wire fine, ns31, ovf0, ovf1, neg;
	
	genvar i;
	generate
		for(i = 0 ; i < 32 ; i = i + 1) begin: loop
			xnor xoxo(xo[i], a[i], b[i]);
		end
	endgenerate
	
	adder8bit adder0007(
		.a7(a[7]), .a6(a[6]), .a5(a[5]), .a4(a[4]), .a3(a[3]), .a2(a[2]), .a1(a[1]), .a0(a[0]),
		.b7(b[7]), .b6(b[6]), .b5(b[5]), .b4(b[4]), .b3(b[3]), .b2(b[2]), .b1(b[1]), .b0(b[0]), .cin(ctrl_sub),
		.s7(s[7]), .s6(s[6]), .s5(s[5]), .s4(s[4]), .s3(s[3]), .s2(s[2]), .s1(s[1]), .s0(s[0]),
		.P(P0), .G(G0), .isOvf(), .isNeg(),
		.p7(p[7]), .p6(p[6]), .p5(p[5]), .p4(p[4]), .p3(p[3]), .p2(p[2]), .p1(p[1]), .p0(p[0]),
		.g7(g[7]), .g6(g[6]), .g5(g[5]), .g4(g[4]), .g3(g[3]), .g2(g[2]), .g1(g[1]), .g0(g[0])
	);
	
	adder8bit adder0815(
		.a7(a[15]), .a6(a[14]), .a5(a[13]), .a4(a[12]), .a3(a[11]), .a2(a[10]), .a1(a[9]), .a0(a[8]),
		.b7(b[15]), .b6(b[14]), .b5(b[13]), .b4(b[12]), .b3(b[11]), .b2(b[10]), .b1(b[9]), .b0(b[8]), .cin(c7),
		.s7(s[15]), .s6(s[14]), .s5(s[13]), .s4(s[12]), .s3(s[11]), .s2(s[10]), .s1(s[9]), .s0(s[8]),
		.P(P1), .G(G1), .isOvf(), .isNeg(),
		.p7(p[15]), .p6(p[14]), .p5(p[13]), .p4(p[12]), .p3(p[11]), .p2(p[10]), .p1(p[9]), .p0(p[8]),
		.g7(g[15]), .g6(g[14]), .g5(g[13]), .g4(g[12]), .g3(g[11]), .g2(g[10]), .g1(g[9]), .g0(g[8])
	);
	
	adder8bit adder1623(
		.a7(a[23]), .a6(a[22]), .a5(a[21]), .a4(a[20]), .a3(a[19]), .a2(a[18]), .a1(a[17]), .a0(a[16]),
		.b7(b[23]), .b6(b[22]), .b5(b[21]), .b4(b[20]), .b3(b[19]), .b2(b[18]), .b1(b[17]), .b0(b[16]), .cin(c15),
		.s7(s[23]), .s6(s[22]), .s5(s[21]), .s4(s[20]), .s3(s[19]), .s2(s[18]), .s1(s[17]), .s0(s[16]),
		.P(P2), .G(G2), .isOvf(), .isNeg(),
		.p7(p[23]), .p6(p[22]), .p5(p[21]), .p4(p[20]), .p3(p[19]), .p2(p[18]), .p1(p[17]), .p0(p[16]),
		.g7(g[23]), .g6(g[22]), .g5(g[21]), .g4(g[20]), .g3(g[19]), .g2(g[18]), .g1(g[17]), .g0(g[16])
	);
	
	adder8bit adder2431(
		.a7(a[31]), .a6(a[30]), .a5(a[29]), .a4(a[28]), .a3(a[27]), .a2(a[26]), .a1(a[25]), .a0(a[24]),
		.b7(b[31]), .b6(b[30]), .b5(b[29]), .b4(b[28]), .b3(b[27]), .b2(b[26]), .b1(b[25]), .b0(b[24]), .cin(c23),
		.s7(s[31]), .s6(s[30]), .s5(s[29]), .s4(s[28]), .s3(s[27]), .s2(s[26]), .s1(s[25]), .s0(s[24]),
		.P(), .G(), .isOvf(isOvf), .isNeg(neg),
		.p7(p[31]), .p6(p[30]), .p5(p[29]), .p4(p[28]), .p3(p[27]), .p2(p[26]), .p1(p[25]), .p0(p[24]),
		.g7(g[31]), .g6(g[30]), .g5(g[29]), .g4(g[28]), .g3(g[27]), .g2(g[26]), .g1(g[25]), .g0(g[24])
	);
	
	and andi0(propi0, P0, ctrl_sub);
	and andi1(propi1, P1, P0, ctrl_sub);
	and andi2(propi2, P2, P1, P0, ctrl_sub);
	and and01(prop01, P1, G0);
	and and02(prop02, P2, P1, G0);
	and and12(prop12, P2, G1);
	
	or orc7(c7, G0, propi0);
	or orc15(c15, G1, prop01, propi1);
	or orc23(c23, G2, prop12, prop02, propi2);
	
	not novf(fine, isOvf);
	not nss(ns31, s[31]);
	and f0(ovf0, isOvf, ns31);
	and f1(ovf1, fine, neg);
	or fa(isLessThan, ovf0, ovf1);
	
	or n0(neq0, xo[0], xo[1], xo[2], xo[3]);
	or n1(neq1, xo[8], xo[9], xo[10], xo[11]);
	or n2(neq2, xo[16], xo[17], xo[18], xo[19]);
	or n3(neq3, xo[24], xo[25], xo[26], xo[27]);
	or n4(neq4, xo[4], xo[5], xo[6], xo[7]);
	or n5(neq5, xo[12], xo[13], xo[14], xo[15]);
	or n6(neq6, xo[20], xo[21], xo[22], xo[23]);
	or n7(neq7, xo[28], xo[29], xo[30], xo[31]);
	
	or neq(isNotEqual, neq0, neq1, neq2, neq3, neq4, neq5, neq6, neq7);
	
endmodule
