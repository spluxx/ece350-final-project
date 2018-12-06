module PC_MODULE (
	// CLOCK / RESET
	clock, 
	reset,
	
	// BRANCHING
	branch_to,
	branch_ctrl,
	
	// IMEM PORTS
	address_imem,
	q_imem,
	
	needs_stall,
	
	// PC REGISTER OUTPUT
	PC_out,
	IR_out
);
	// PORTS
	input clock, reset;
	
	input [31:0] branch_to;
	input branch_ctrl;
	
	output [11:0] address_imem;
	input [31:0] q_imem;
		
	input needs_stall;

	output [31:0] PC_out, IR_out;

	// UTILITIES
	wire LOW, HIGH, notClock;
	wire [31:0] NOP;
	wire [4:0] MINUS;
	assign LOW = 1'b0;
	assign HIGH = 1'b1;
	assign NOP = 32'h00000000;
	assign MINUS = 5'b00001;
	assign notClock = ~clock;
	
	// ------------------------------------------------------//
	
	// CORE LOGIC
	wire [31:0] next_PC, current_PC;
	register PC(
		.d(branch_ctrl ? branch_to : 
			needs_stall ? current_PC :
							  next_PC),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(current_PC)
	);
	assign address_imem = current_PC[11:0];
	adder32bit nextPC_calc(
		.a(current_PC), 
		.b(32'd1), 
		.ctrl_sub(LOW), 
		.s(next_PC), 
		.p(), .g(), .isOvf(), .isNotEqual(), .isLessThan()
	);
	
	register PC_PC(
		.d(needs_stall ? PC_out : next_PC),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(PC_out)
	);

	register PC_IR(
		.d(branch_ctrl ? NOP : 
			needs_stall ? IR_out :
							  q_imem),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(IR_out)
	);	
endmodule 