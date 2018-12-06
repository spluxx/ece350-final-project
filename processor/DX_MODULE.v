module DX_MODULE(
	// CLOCK / RESET
	clock,
	reset,
	
	// BRANCHING
	branch_to,
	branch_ctrl,
	
	// FD MODULE PORTS
	PC_in,
	A_in, 
	B_in,
	IR_in,
	
	// MW MODULE OUTPUTS for bypassing 
	ctrl_writeEnable,
	ctrl_writeReg,
	data_writeReg,
	
	is_MULTDIV_running,
	// bypassed A, B
	effective_A_in,
	effective_B_in,
	
	// DX REGISTER OUTPUT
	O_out,
	B_out,
	IR_out
);
	// PORTS
	input clock, reset;
	
	output [31:0] branch_to;
	output branch_ctrl;
	
	input [31:0] PC_in, A_in, B_in, IR_in;
		
	input ctrl_writeEnable;
	input [4:0] ctrl_writeReg;
	input [31:0] data_writeReg;
	
	input is_MULTDIV_running;

	output [31:0] effective_A_in, effective_B_in;
	
	output [31:0] O_out, B_out, IR_out;

	// UTILITIES
	wire LOW, HIGH, notClock;
	wire [31:0] NOP;
	wire [4:0] MINUS, PLUS;
	assign LOW = 1'b0;
	assign HIGH = 1'b1;
	assign NOP = 32'h00000000;
	assign PLUS = 5'b00000;
	assign MINUS = 5'b00001;
	assign notClock = ~clock;
	
	// WIRES
	wire is_J, is_JAL, is_JR, is_BNE, is_BLT, is_BEX;
	wire is_ADDI, is_SW, is_LW;
	wire is_ADD, is_SUB;
	wire is_MULT, is_DIV;
	
	wire [31:0] immed;
	wire is_immed;		
	wire [31:0] T;
	
	wire [31:0] branch_to_reg;
	wire [31:0] branch_to_immed;
	wire [31:0] branch_to_target;
	
	wire unconditional_branch_ctrl, conditional_branch_ctrl;
	wire [4:0] ALU_op;
	wire [31:0] ALU_res;
	wire isNotEqual, isLessThan, overflow;
	
	wire [31:0] instr;
	
	//----------------OPCODE IDENTIFICATION--------------------//
	
	// branch
	equals5bit isJ(is_J, IR_in[31:27], 5'b00001);
	equals5bit isJAL(is_JAL, IR_in[31:27], 5'b00011);
	equals5bit isJR(is_JR, IR_in[31:27], 5'b00100);
	equals5bit isBNE(is_BNE, IR_in[31:27], 5'b00010);
	equals5bit isBLT(is_BLT, IR_in[31:27], 5'b00110);
	equals5bit isBEX(is_BEX, IR_in[31:27], 5'b10110);
	
	// immediate
	equals5bit isADDI(is_ADDI, IR_in[31:27], 5'b00101);
	equals5bit isSW(is_SW, IR_in[31:27], 5'b00111);
	equals5bit isLW(is_LW, IR_in[31:27], 5'b01000);
	
	// ALU opcode (identified to handle exception appropriately)
	equals5bit isADD(is_ADD, IR_in[6:2], 5'b00000);
	equals5bit isSUB(is_SUB, IR_in[6:2], 5'b00001);
	
	
	//-----------------OPERAND EXTRACTION----------------------//
	
	// immed
	assign immed[31:17] = IR_in[16] ? 15'b111111111111111 : 15'b000000000000000;
	assign immed[16:0] = IR_in[16:0];
	
	assign is_immed = is_ADDI | is_SW | is_LW;		
	
	// T 
	assign T[31:27] = 5'b00000;
	assign T[26:0] = IR_in[26:0];
	
	//------------------BRANCHING LOGIC------------------------//
	
	// determine branch_to

	assign branch_to_reg = effective_A_in; // on jr, A holds $rd
	
	adder32bit branchTo(
		.a(PC_in),
		.b(immed),
		.ctrl_sub(LOW),
		.s(branch_to_immed),
		.p(), .g(), .isOvf(), .isNotEqual(), .isLessThan()
	);
	
	assign branch_to_target = T;
	
	assign branch_to = is_JR    				? branch_to_reg : 
							 (is_BNE | is_BLT) 	? branch_to_immed : 
														  branch_to_target;	
											
	// determine branch_ctrl
	// 1. unconditional jump (j   00001, jal 00011, jr  00100)
	// 2. conditional jump   (bne 00010, blt 00110, bex 10110)
	assign unconditional_branch_ctrl = is_J | is_JAL | is_JR;
	assign conditional_branch_ctrl = (is_BNE & isNotEqual) | (is_BLT & isLessThan) | (is_BEX & (~isNotEqual));
	assign branch_ctrl = unconditional_branch_ctrl | conditional_branch_ctrl;
	
	
	// ----------------- MX BYPASS ----------------//
	
	// is IR_out arithmetic op? // also need to consider jal...?
	wire is_arithmetic;
	assign is_arithmetic = (IR_out[31:27] == 5'b00101) | (IR_out[31:27] == 5'b00000);
	// which register is the result saved?
	wire [4:0] target_reg;
	assign target_reg = IR_out[26:22];
	// does A argument of IR_in use the register?
	wire M_to_A;
	assign M_to_A = is_arithmetic && (target_reg != 5'b00000) & (
 						((IR_in[31:27] == 5'b00000) & (IR_in[21:17] == target_reg)) |  // R type Arithmetic
						((IR_in[31:27] == 5'b00101) & (IR_in[21:17] == target_reg)) |  // ADDI
						((IR_in[31:27] == 5'b00111) & (IR_in[21:17] == target_reg)) |  // SW address
						((IR_in[31:27] == 5'b01000) & (IR_in[21:17] == target_reg)) |  // LW address
						((IR_in[31:27] == 5'b00010) & (IR_in[26:22] == target_reg)) |  // BNE A
						((IR_in[31:27] == 5'b00110) & (IR_in[26:22] == target_reg)) |  // BLT A
						((IR_in[31:27] == 5'b00100) & (IR_in[26:22] == target_reg)));   // JR Target
	
	// does B argument of IR_in use the register?
	wire M_to_B;
	assign M_to_B = is_arithmetic && (target_reg != 5'b00000) & (
						((IR_in[31:27] == 5'b00000) & (IR_in[16:12] == target_reg)) |  // R type Arithmetic
						((IR_in[31:27] == 5'b00111) & (IR_in[26:22] == target_reg)) |  // SW data
						((IR_in[31:27] == 5'b00010) & (IR_in[21:17] == target_reg)) |  // BNE B
						((IR_in[31:27] == 5'b00110) & (IR_in[21:17] == target_reg)));  // BLT B
	
	
	// ------------------ WX BYPASS ------------------- //
	
	// does A argument of IR_in use the register?
	wire W_to_A;
	assign W_to_A = (ctrl_writeReg != 5'b00000) & ctrl_writeEnable & (
						((IR_in[31:27] == 5'b00000) & (IR_in[21:17] == ctrl_writeReg)) |  // R type Arithmetic
						((IR_in[31:27] == 5'b00101) & (IR_in[21:17] == ctrl_writeReg)) |  // ADDI
						((IR_in[31:27] == 5'b00111) & (IR_in[21:17] == ctrl_writeReg)) |  // SW address
						((IR_in[31:27] == 5'b01000) & (IR_in[21:17] == ctrl_writeReg)) |  // LW address
						((IR_in[31:27] == 5'b00010) & (IR_in[26:22] == ctrl_writeReg)) |  // BNE A
						((IR_in[31:27] == 5'b00110) & (IR_in[26:22] == ctrl_writeReg)) |  // BLT A
						((IR_in[31:27] == 5'b00100) & (IR_in[26:22] == ctrl_writeReg)));   // JR Target
	
	// does B argument of IR_in use the register?
	wire W_to_B;
	assign W_to_B = (ctrl_writeReg != 5'b00000) & ctrl_writeEnable & (  
	               ((IR_in[31:27] == 5'b00000) & (IR_in[16:12] == ctrl_writeReg)) |  // R type Arithmetic
						((IR_in[31:27] == 5'b00111) & (IR_in[26:22] == ctrl_writeReg)) |  // SW data
						((IR_in[31:27] == 5'b00010) & (IR_in[21:17] == ctrl_writeReg)) |  // BNE B
						((IR_in[31:27] == 5'b00110) & (IR_in[21:17] == ctrl_writeReg)));  // BLT B
	
	//-------------------FINALIZE BYPASSING ------------------//
	
	// precedence; data from M (most recent) -> data from W -> data from D
	
	assign effective_A_in = M_to_A ? O_out : 
	                        W_to_A ? data_writeReg :
												A_in;
	
	assign effective_B_in = M_to_B ? O_out :
									W_to_B ? data_writeReg :
												B_in;
	
	//------------------ALU OPERATION-------------------------//
	
	
	//// ALU 
	// alu code
	// 1. arithmetic operations -> IR_in[6:2]
	// 2. conditional branching (bne, blt, bex -> minus) 
	// 3. memory operations -> PLUS
	
	assign ALU_op = (is_BNE | is_BLT | is_BEX) ? MINUS : 
						 (is_SW | is_LW | is_ADDI) ? PLUS : IR_in[6:2];
	
	
	alu alUnit(
		.data_operandA(effective_A_in),
		.data_operandB(is_immed ? immed : effective_B_in),
		.ctrl_ALUopcode(ALU_op),
		.ctrl_shiftamt(IR_in[11:7]),
		.data_result(ALU_res),
		.isNotEqual(isNotEqual),
		.isLessThan(isLessThan),
		.overflow(overflow)
	);
	
	// resolve exceptions -> change the Instruction to setx (exception code)

	assign instr[26:0] = overflow ? 
											(is_ADD  ? 27'd1 :
											 is_ADDI ? 27'd2 : 	
											 is_SUB  ? 27'd3 : 27'd0) : IR_in[26:0]; // need to handle MULTDIV later
	assign instr[31:27] = overflow ? 5'b10101 : IR_in[31:27];										 	
	//---------------RESOLVE DX REGISTER----------------------//
	
	register DX_O(
		.d(is_JAL ? PC_in : ALU_res),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(O_out)
	);	
	
	register DX_B(
		.d(effective_B_in),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(B_out)
	);	
	register DX_IR(
		.d(is_MULTDIV_running ? NOP : instr),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(IR_out)
	);	
endmodule 