module MW_MODULE(
	// xm module ports
	O_in,
	D_in,
	IR_in,
	
	// register file 
	ctrl_writeEnable,
	ctrl_writeReg,
	data_writeReg
);

	input [31:0] O_in, D_in, IR_in;
	
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg;
	output [31:0] data_writeReg;
	
	// UTILITIES
	wire LOW, HIGH;
	wire [31:0] NOP;
	wire [4:0] MINUS, PLUS;
	assign LOW = 1'b0;
	assign HIGH = 1'b1;
	assign NOP = 32'h00000000;
	assign PLUS = 5'b00000;
	assign MINUS = 5'b00001;
	
	// ------------ OPCODE IDENTIFICATION ---------- //
	
	wire is_LW, is_JAL, is_SETX, is_ALU, is_ADDI;
	
	equals5bit isLW(is_LW, IR_in[31:27], 5'b01000);
	equals5bit isJAL(is_JAL, IR_in[31:27], 5'b00011);
	equals5bit isSETX(is_SETX, IR_in[31:27], 5'b10101);
	equals5bit isALU(is_ALU, IR_in[31:27], 5'b00000);
	equals5bit isADDI(is_ADDI, IR_in[31:27], 5'b00101);
	
	// ------------ CONTROL LOGIC ----------- //
	
	assign ctrl_writeEnable = is_LW | is_JAL | is_SETX | is_ALU | is_ADDI;
	
	assign ctrl_writeReg = (is_LW | is_ALU | is_ADDI) ? IR_in[26:22] : 
									is_SETX ? 5'd30 : 
									is_JAL ? 5'd31 : 5'b00000;
									
	wire [31:0] padded_T;
	assign padded_T[26:0] = IR_in[26:0];
	assign padded_T[31:27] = 5'b00000;
									
	assign data_writeReg = is_LW ? D_in : 
								  is_SETX ? padded_T :
								  O_in;		

endmodule