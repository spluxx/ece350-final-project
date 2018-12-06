module FD_MODULE(
	// CLOCK / RESET
	clock,
	reset,
	
	// BRANCHING
	branch_ctrl,
	
	// PC MODULE PORTS
	PC_in,
	IR_in,
	
	// REGISTER FILE
	ctrl_readRegA,                  // O: Register to read from port A of regfile
	ctrl_readRegB,                  // O: Register to read from port B of regfile
	data_readRegA,                  // I: Data from port A of regfile
	data_readRegB,                   // I: Data from port B of regfile
	
	needs_stall,
	
	// FD REGISTER OUTPUT
	PC_out,
	A_out,
	B_out,
	IR_out
);

	// PORTS
	input clock, reset;
	
	input branch_ctrl;
	
	input [31:0] PC_in, IR_in;
	
	output [4:0] ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_readRegA, data_readRegB;
	
	input needs_stall;
	
	output [31:0] PC_out, A_out, B_out, IR_out;
	
	// UTILITIES
	wire LOW, HIGH, notClock;
	wire [31:0] NOP;
	wire [4:0] MINUS;
	assign LOW = 1'b0;
	assign HIGH = 1'b1;
	assign NOP = 32'h00000000;
	assign MINUS = 5'b00001;
	assign notClock = ~clock;

	//// CORE LOGIC
	
	// @BEX -> A = $30, B = $0
	wire is_BEX;
	equals5bit isBEX(is_BEX, IR_in[31:27], 5'b10110);

	// @jr -> A = $rd, B = $0
	wire is_JR;
	equals5bit isJR(is_JR, IR_in[31:27], 5'b00100);
	
	// @bne, blt -> A = $rd, B = $rs
	wire is_BNE, is_BLT;
	equals5bit isBNE(is_BNE, IR_in[31:27], 5'b00010);
	equals5bit isBLT(is_BLT, IR_in[31:27], 5'b00110);
	
	// @sw -> A = $rs, B = $rd
	wire is_SW;
	equals5bit isSW(is_SW, IR_in[31:27], 5'b00111);
	
	// switch $rd / $rs / $rt appropriately
	assign ctrl_readRegA = is_BEX  ? 5'd30 : 
								  (is_JR | is_BNE | is_BLT) ? IR_in[26:22] : IR_in[21:17];
	assign ctrl_readRegB = (is_BEX | is_JR) ? 5'd0 : 
								  (is_BNE | is_BLT) ? IR_in[21:17] : 
								  is_SW ? IR_in[26:22] : IR_in[16:12];
	
	register FD_PC(
		.d(PC_in),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(PC_out)
	);
	register FD_A(
		.d(data_readRegA),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(A_out)
	);	
	register FD_B(
		.d(data_readRegB),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(B_out)
	);	
	register FD_IR(
		.d((branch_ctrl | needs_stall) ? NOP : IR_in),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(IR_out)
	);	

endmodule 