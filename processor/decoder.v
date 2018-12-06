module decoder(sel, en, out);
	input [4:0]sel;
	input en;
	
	output [31:0]out;
	
	wire[31:0] andRes, andResEn;
	wire[4:0] nsel;
	
	genvar i;
	generate 
		for(i = 0 ; i < 5 ; i = i + 1) begin: loop
			not not0(nsel[i], sel[i]);
			
		end
		for(i = 0 ; i < 32 ; i = i + 1) begin: loop2
			and and0(andResEn[i], andRes[i], en);
			assign out[i] = andResEn[i] ? 1'b1 : 1'b0;
		end
	endgenerate
	
	and and0(andRes[0], nsel[0], nsel[1], nsel[2], nsel[3], nsel[4]);
	and and1(andRes[1], nsel[0], nsel[1], nsel[2], nsel[3], sel[4]);
	and and2(andRes[2], nsel[0], nsel[1], nsel[2], sel[3], nsel[4]);
	and and3(andRes[3], nsel[0], nsel[1], nsel[2], sel[3], sel[4]);
	and and4(andRes[4], nsel[0], nsel[1], sel[2], nsel[3], nsel[4]);
	and and5(andRes[5], nsel[0], nsel[1], sel[2], nsel[3], sel[4]);
	and and6(andRes[6], nsel[0], nsel[1], sel[2], sel[3], nsel[4]);
	and and7(andRes[7], nsel[0], nsel[1], sel[2], sel[3], sel[4]);
	and and8(andRes[8], nsel[0], sel[1], nsel[2], nsel[3], nsel[4]);
	and and9(andRes[9], nsel[0], sel[1], nsel[2], nsel[3], sel[4]);
	and and10(andRes[10], nsel[0], sel[1], nsel[2], sel[3], nsel[4]);
	and and11(andRes[11], nsel[0], sel[1], nsel[2], sel[3], sel[4]);
	and and12(andRes[12], nsel[0], sel[1], sel[2], nsel[3], nsel[4]);
	and and13(andRes[13], nsel[0], sel[1], sel[2], nsel[3], sel[4]);
	and and14(andRes[14], nsel[0], sel[1], sel[2], sel[3], nsel[4]);
	and and15(andRes[15], nsel[0], sel[1], sel[2], sel[3], sel[4]);
	and and16(andRes[16], sel[0], nsel[1], nsel[2], nsel[3], nsel[4]);
	and and17(andRes[17], sel[0], nsel[1], nsel[2], nsel[3], sel[4]);
	and and18(andRes[18], sel[0], nsel[1], nsel[2], sel[3], nsel[4]);
	and and19(andRes[19], sel[0], nsel[1], nsel[2], sel[3], sel[4]);
	and and20(andRes[20], sel[0], nsel[1], sel[2], nsel[3], nsel[4]);
	and and21(andRes[21], sel[0], nsel[1], sel[2], nsel[3], sel[4]);
	and and22(andRes[22], sel[0], nsel[1], sel[2], sel[3], nsel[4]);
	and and23(andRes[23], sel[0], nsel[1], sel[2], sel[3], sel[4]);
	and and24(andRes[24], sel[0], sel[1], nsel[2], nsel[3], nsel[4]);
	and and25(andRes[25], sel[0], sel[1], nsel[2], nsel[3], sel[4]);
	and and26(andRes[26], sel[0], sel[1], nsel[2], sel[3], nsel[4]);
	and and27(andRes[27], sel[0], sel[1], nsel[2], sel[3], sel[4]);
	and and28(andRes[28], sel[0], sel[1], sel[2], nsel[3], nsel[4]);
	and and29(andRes[29], sel[0], sel[1], sel[2], nsel[3], sel[4]);
	and and30(andRes[30], sel[0], sel[1], sel[2], sel[3], nsel[4]);
	and and31(andRes[31], sel[0], sel[1], sel[2], sel[3], sel[4]);
endmodule
