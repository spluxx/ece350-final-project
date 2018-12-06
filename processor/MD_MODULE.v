module MD_MODULE(
	clock,
	reset,
	
	effective_A_in,
	effective_B_in,
	IR_in,
	
	is_MULTDIV_running,
	
	override_MW,
	ctrl_writeEnable,
	ctrl_writeReg,
	data_writeReg
);
	input clock, reset;
	input [31:0] effective_A_in, effective_B_in, IR_in;
	output is_MULTDIV_running;
	output override_MW;
	
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg;
	output [31:0] data_writeReg;
	
	wire is_MULT, is_DIV, is_MULT_p, multdiv_ex;
	
	wire data_resultRDY;
	wire [31:0] multdiv_res;
	wire [31:0] persisted_IR_in;
	
	assign is_MULT = (IR_in[31:27] == 5'b00000) & (IR_in[6:2] == 5'b00110);
	assign is_DIV = (IR_in[31:27] == 5'b00000) & (IR_in[6:2] == 5'b00111);

	assign is_MULT_p = (persisted_IR_in[31:27] == 5'b00000) & 
								(persisted_IR_in[6:2] == 5'b00110);
	// ----------------------MULTDIV--------------------------//
		

	register persistIR(
		.d(IR_in),
		.clk(clock),
		.clr(1'b0),
		.en(is_MULT | is_DIV),
		.q(persisted_IR_in)
	);
	
	dflipflop isMULTDIVrunning(
		.d(1'b0), 
		.clk(clock), // might need to flip	
		.clr(data_resultRDY), 
		.pr(is_MULT | is_DIV), 
		.ena(1'b0), 
		.q(is_MULTDIV_running)
	);
	
	multdiv md(
		.data_operandA(effective_A_in),
		.data_operandB(effective_B_in),
		.ctrl_MULT(is_MULT),
		.ctrl_DIV(is_DIV),
		.clock(~clock),
		.data_result(multdiv_res),
		.data_exception(multdiv_ex),
		.data_resultRDY(data_resultRDY)
	);
	
	assign override_MW = data_resultRDY;
	assign ctrl_writeEnable = data_resultRDY;
	assign ctrl_writeReg = multdiv_ex ? 5'd30 : persisted_IR_in[26:22];
	assign data_writeReg = multdiv_ex ? 
									(is_MULT_p ? 5'd4 : 5'd5) : multdiv_res;
	
endmodule