module mux32(	in01, in02, in03, in04, in05, in06, in07, in08, 
					in09, in10, in11, in12, in13, in14, in15, in16, 
					in17, in18, in19, in20, in21, in22, in23, in24, 
					in25, in26, in27, in28, in29, in30, in31, in32, 
					sel, out);
	input [31:0] in01, in02, in03, in04, in05, in06, in07, in08;
	input [31:0] in09, in10, in11, in12, in13, in14, in15, in16;
	input [31:0] in17, in18, in19, in20, in21, in22, in23, in24;
	input [31:0] in25, in26, in27, in28, in29, in30, in31, in32;
	input [4:0] sel;
	output [31:0] out;

	wire [31:0] decoded_sel;
	
	decoder dec(sel, 1'b1, decoded_sel);
	
	assign out = decoded_sel[0] ? in01 : 32'bz;
	assign out = decoded_sel[1] ? in02 : 32'bz;
	assign out = decoded_sel[2] ? in03 : 32'bz;
	assign out = decoded_sel[3] ? in04 : 32'bz;
	assign out = decoded_sel[4] ? in05 : 32'bz;
	assign out = decoded_sel[5] ? in06 : 32'bz;
	assign out = decoded_sel[6] ? in07 : 32'bz;
	assign out = decoded_sel[7] ? in08 : 32'bz;
	assign out = decoded_sel[8] ? in09 : 32'bz;
	assign out = decoded_sel[9] ? in10 : 32'bz;
	assign out = decoded_sel[10] ? in11 : 32'bz;
	assign out = decoded_sel[11] ? in12 : 32'bz;
	assign out = decoded_sel[12] ? in13 : 32'bz;
	assign out = decoded_sel[13] ? in14 : 32'bz;
	assign out = decoded_sel[14] ? in15 : 32'bz;
	assign out = decoded_sel[15] ? in16 : 32'bz;
	assign out = decoded_sel[16] ? in17 : 32'bz;
	assign out = decoded_sel[17] ? in18 : 32'bz;
	assign out = decoded_sel[18] ? in19 : 32'bz;
	assign out = decoded_sel[19] ? in20 : 32'bz;
	assign out = decoded_sel[20] ? in21 : 32'bz;
	assign out = decoded_sel[21] ? in22 : 32'bz;
	assign out = decoded_sel[22] ? in23 : 32'bz;
	assign out = decoded_sel[23] ? in24 : 32'bz;
	assign out = decoded_sel[24] ? in25 : 32'bz;
	assign out = decoded_sel[25] ? in26 : 32'bz;
	assign out = decoded_sel[26] ? in27 : 32'bz;
	assign out = decoded_sel[27] ? in28 : 32'bz;
	assign out = decoded_sel[28] ? in29 : 32'bz;
	assign out = decoded_sel[29] ? in30 : 32'bz;
	assign out = decoded_sel[30] ? in31 : 32'bz;
	assign out = decoded_sel[31] ? in32 : 32'bz;
endmodule
