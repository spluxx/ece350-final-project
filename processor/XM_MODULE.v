module XM_MODULE(
	// CLOCK, RESET
	clock,
	reset,
	
	// DX MODULE PORTS
	O_in,
	B_in,
	IR_in,
	
	// DMEM
	address_dmem,                   // O: The address of the data to get or put from/to dmem
	data,                           // O: The data to write to dmem
	wren,                           // O: Write enable for dmem
	q_dmem,                         // I: The data from dmem
	
	// WM bypassing
	ctrl_writeEnable,
	ctrl_writeReg,
	data_writeReg,
	
	// XM REGISTER OUTPUT
	O_out,
	D_out,
	IR_out
);

	input clock, reset;
	
	input [31:0] O_in, B_in, IR_in;
	
	output [11:0] address_dmem;
	output [31:0] data;
	output wren;
	input [31:0] q_dmem;
	
	input ctrl_writeEnable;
	input [4:0] ctrl_writeReg;
	input [31:0] data_writeReg;
	
	output [31:0] O_out, D_out, IR_out;
	
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

	
	//---------- OPCODE IDENTIFICATION -----------//
	
	wire is_SW, is_LW;
	
	equals5bit isSW(is_SW, IR_in[31:27], 5'b00111);
	equals5bit isLW(is_LW, IR_in[31:27], 5'b01000);
	
	// -------------- WM BYPASSING ----------- //
	// does data argument of IR_in use the register?
	wire W_to_B;
	wire [31:0] effective_B_in;
	
	assign W_to_B = (ctrl_writeReg != 5'b00000) & ctrl_writeEnable & (
						((IR_in[31:27] == 5'b00111) & (IR_in[26:22] == ctrl_writeReg))); // SW data
	assign effective_B_in = W_to_B ? data_writeReg : B_in;					
	
	// -------------------SW/LW----------------------//
	
	assign wren = is_SW;
	assign data = effective_B_in;
	assign address_dmem = O_in[11:0];
	
	// ------------------register-----------------//
	
	register XM_O(
		.d(O_in),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(O_out)
	);
	
	register XM_D(
		.d(q_dmem),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(D_out)
	);	
	
	register XM_IR(
		.d(IR_in),
		.clk(notClock),
		.clr(reset),
		.en(HIGH),
		.q(IR_out)
	);	
endmodule 