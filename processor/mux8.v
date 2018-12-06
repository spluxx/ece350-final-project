module mux3(in0, in1, in2, in3, in4, in5, in6, in7, sel2, sel1, sel0, out);
	input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
	input sel0, sel1, sel2;
	output [31:0] out;
	
	wire nsel0, nsel1, nsel2;
	wire p000, p001, p010, p011, p100, p101, p110, p111;
	
	not n0(nsel0, sel0);
	not n1(nsel1, sel1);
	not n2(nsel2, sel2);
	
	and a000(p000, nsel2, nsel1, nsel0);
	and a001(p001, nsel2, nsel1, sel0);
	and a010(p010, nsel2, sel1, nsel0);
	and a011(p011, nsel2, sel1, sel0);
	and a100(p100, sel2, nsel1, nsel0);
	and a101(p101, sel2, nsel1, sel0);
	and a110(p110, sel2, sel1, nsel0);
	and a111(p111, sel2, sel1, sel0);
	
	assign out = p000 ? in0 :
					 p001 ? in1 :
					 p010 ? in2 :
					 p011 ? in3 :
					 p100 ? in4 :
					 p101 ? in5 :
					 p110 ? in6 :
					 p111 ? in7 : 32'bz;
endmodule
