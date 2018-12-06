module regfile(clock, ctrl_writeEnable, ctrl_reset, 
					ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, 
					data_writeReg, data_readRegA, data_readRegB,
					r20, r21, r22, r23, r24, r25_en, r25_data, r26
);
	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	
	output [31:0]data_readRegA, data_readRegB;
	
	wire [31:0] decoded_ctrl_writeReg; 
	wire [4:0] flipped_ctrl_A, flipped_ctrl_B;
	wire [31:0] res[0:31]; 
	
	// TO GAME MODULE
	output [31:0] r20, r21, r22, r23, r24, r26;
	input [31:0] r25_data;
	input r25_en;
	
	assign r20 = res[20];
	assign r21 = res[21];
	assign r22 = res[22];
	assign r23 = res[23];
	assign r24 = res[24];
	assign r26 = res[26];
	
	assign flipped_ctrl_A[4] = ctrl_readRegA[0];
	assign flipped_ctrl_A[3] = ctrl_readRegA[1];
	assign flipped_ctrl_A[2] = ctrl_readRegA[2];
	assign flipped_ctrl_A[1] = ctrl_readRegA[3];
	assign flipped_ctrl_A[0] = ctrl_readRegA[4];
	
	assign flipped_ctrl_B[4] = ctrl_readRegB[0];
	assign flipped_ctrl_B[3] = ctrl_readRegB[1];
	assign flipped_ctrl_B[2] = ctrl_readRegB[2];
	assign flipped_ctrl_B[1] = ctrl_readRegB[3];
	assign flipped_ctrl_B[0] = ctrl_readRegB[4];
	
	// decode ctrl signals
	assign decoded_ctrl_writeReg = ctrl_writeEnable << ctrl_writeReg;
	
	mux32 mA(.in01(res[0]), .in02(res[1]), .in03(res[2]), .in04(res[3]),
				.in05(res[4]), .in06(res[5]), .in07(res[6]), .in08(res[7]),
				.in09(res[8]), .in10(res[9]), .in11(res[10]), .in12(res[11]),
				.in13(res[12]), .in14(res[13]), .in15(res[14]), .in16(res[15]),
				.in17(res[16]), .in18(res[17]), .in19(res[18]), .in20(res[19]),
				.in21(res[20]), .in22(res[21]), .in23(res[22]), .in24(res[23]),
				.in25(res[24]), .in26(res[25]), .in27(res[26]), .in28(res[27]),
				.in29(res[28]), .in30(res[29]), .in31(res[30]), .in32(res[31]),
				.sel(flipped_ctrl_A), .out(data_readRegA));
				
	mux32 mB(.in01(res[0]), .in02(res[1]), .in03(res[2]), .in04(res[3]),
				.in05(res[4]), .in06(res[5]), .in07(res[6]), .in08(res[7]),
				.in09(res[8]), .in10(res[9]), .in11(res[10]), .in12(res[11]),
				.in13(res[12]), .in14(res[13]), .in15(res[14]), .in16(res[15]),
				.in17(res[16]), .in18(res[17]), .in19(res[18]), .in20(res[19]),
				.in21(res[20]), .in22(res[21]), .in23(res[22]), .in24(res[23]),
				.in25(res[24]), .in26(res[25]), .in27(res[26]), .in28(res[27]),
				.in29(res[28]), .in30(res[29]), .in31(res[30]), .in32(res[31]),
				.sel(flipped_ctrl_B), .out(data_readRegB));
	
	// generate registers
	register zeroR(.d(32'b0), .clk(clock), .clr(ctrl_reset), .en(decoded_ctrl_writeReg[0]), .q(res[0]));
	genvar i;
	generate
		for(i = 1 ; i <= 24 ; i = i + 1) begin: loop
			register r(.d(data_writeReg), .clk(clock), .clr(ctrl_reset), .en(decoded_ctrl_writeReg[i]), .q(res[i]));
		end
		for(i = 26 ; i < 32 ; i = i + 1) begin: loop2
			register r(.d(data_writeReg), .clk(clock), .clr(ctrl_reset), .en(decoded_ctrl_writeReg[i]), .q(res[i]));
		end
	endgenerate
	register dodo(.d(r25_data), .clk(clock), .clr(ctrl_reset), .en(r25_en), .q(res[25])); 
endmodule