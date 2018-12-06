module processor(clock, reset, r20, r21, r22, r23, r24, r25_en, r25_data, r26);

	input 			clock, reset;
	output[31:0] r20, r21, r22, r23, r24, r26;
	input [31:0] r25_data;
	input r25_en;
		
	wire [11:0] address_dmem;
   wire [31:0] data;
   wire wren;
   wire [31:0] q_dmem;
	// DMEM
	dmem mydmem(.address	(address_dmem),
					.clock	(clock),
					.data	   (data),    				// data you want to write
					.wren		(wren),
					.q			(q_dmem) // change where output q goes...
	);
	
	wire [11:0] address_imem;
   wire [31:0] q_imem;
	// IMEM
	imem myimem(.address 	(address_imem),
					.clken		(1'b1),
					.clock		(clock), //,
					.q				(q_imem) // change where output q goes...
	);  
	
	// REGFILE
	wire ctrl_writeEnable;
	wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	wire [31:0] data_writeReg;
	wire [31:0] data_readRegA, data_readRegB;
	regfile my_regfile(
		clock,
		ctrl_writeEnable,
		reset,
		ctrl_writeReg,
		ctrl_readRegA,
		ctrl_readRegB,
		data_writeReg,
		data_readRegA,
		data_readRegB,
		r20, r21, r22, r23, r24, r25_en, r25_data, r26
	);
 
	
	// utility
	wire LOW, HIGH, notClock;
	assign LOW = 1'b0;
	assign HIGH = 1'b1;
	assign notClock = ~clock;
	
	// branch
	wire [31:0] branch_to; 
	wire branch_ctrl;
	
	wire [31:0] PC_PC_out, PC_IR_out;
	wire [31:0] FD_PC_out, FD_A_out, FD_B_out, FD_IR_out;
	wire [31:0] DX_O_out, DX_B_out, DX_IR_out;
	wire [31:0] XM_O_out, XM_D_out, XM_IR_out;
	
	// MULTDIV
	wire [31:0] effective_FD_A_in, effective_FD_B_in;
	wire is_MULTDIV_running;
	wire md_ctrl_writeEnable;
	wire [4:0] md_ctrl_writeReg;
	wire [31:0] md_data_writeReg;
	wire override_MW;
	
	wire [31:0] mw_data_writeReg;
	wire [4:0] mw_ctrl_writeReg;
	wire mw_ctrl_writeEnable;
	
	// STALL
	
	// ---- STALL ONCE IF FD_IR_out is LW resulting -------- //
	// -------in something that next instr uses ------------ //
	
	wire is_FD_IR_LW;
	assign is_FD_IR_LW = FD_IR_out[31:27] == 5'b01000;
	wire [4:0] target;
	assign target = FD_IR_out[26:22];
	wire needs_stall;
	assign needs_stall = is_MULTDIV_running | (is_FD_IR_LW && (
								((PC_IR_out[31:27] == 5'b00000) &
									((PC_IR_out[21:17] == target) | (PC_IR_out[16:12] == target))) | // arithmetic
								((PC_IR_out[31:27] == 5'b00101) &
									(PC_IR_out[21:17] == target)) | // addi
								((PC_IR_out[31:27] == 5'b01000) &
									(PC_IR_out[21:17] == target)) | // lw
								((PC_IR_out[31:27] == 5'b00010) &
									((PC_IR_out[26:22] == target) | (PC_IR_out[21:17] == target))) | // bne
								((PC_IR_out[31:27] == 5'b00110) &
									((PC_IR_out[26:22] == target) | (PC_IR_out[21:17] == target))) | // blt
								((PC_IR_out[31:27] == 5'b00100) &
									(PC_IR_out[26:22] == target)))); // jr
									
	
	// PC
	PC_MODULE pc(
		.clock(clock),
		.reset(reset),
		.branch_to(branch_to),
		.branch_ctrl(branch_ctrl),
		.address_imem(address_imem),
		.q_imem(q_imem),
		.needs_stall(needs_stall),
		.PC_out(PC_PC_out),
		.IR_out(PC_IR_out)
	);

	// FD
	FD_MODULE fd(
		.clock(clock),
		.reset(reset),
		.branch_ctrl(branch_ctrl),
		.PC_in(PC_PC_out),
		.IR_in(PC_IR_out),
		.ctrl_readRegA(ctrl_readRegA),
		.ctrl_readRegB(ctrl_readRegB),
		.data_readRegA(data_readRegA),
		.data_readRegB(data_readRegB),
		.needs_stall(needs_stall),
		.PC_out(FD_PC_out),
		.A_out(FD_A_out),
		.B_out(FD_B_out),
		.IR_out(FD_IR_out)
	);
	
	// DX
	DX_MODULE dx(
		.clock(clock),
		.reset(reset),
		.branch_to(branch_to),
		.branch_ctrl(branch_ctrl),
		.PC_in(FD_PC_out),
		.A_in(FD_A_out),
		.B_in(FD_B_out),
		.IR_in(FD_IR_out),
		.ctrl_writeEnable(ctrl_writeEnable),
		.ctrl_writeReg(ctrl_writeReg),
		.data_writeReg(data_writeReg),
		.is_MULTDIV_running(is_MULTDIV_running),
		.effective_A_in(effective_FD_A_in),
		.effective_B_in(effective_FD_B_in),
		.O_out(DX_O_out),
		.B_out(DX_B_out),
		.IR_out(DX_IR_out)
	);
	
	// XM
	XM_MODULE xm(
		.clock(clock),
		.reset(reset),
		.O_in(DX_O_out),
		.B_in(DX_B_out),
		.IR_in(DX_IR_out),
		.address_dmem(address_dmem),
		.data(data),
		.wren(wren),
		.q_dmem(q_dmem),
		.ctrl_writeEnable(ctrl_writeEnable),
		.ctrl_writeReg(ctrl_writeReg),
		.data_writeReg(data_writeReg),
		.O_out(XM_O_out),
		.D_out(XM_D_out),
		.IR_out(XM_IR_out)
	);
	
	// MW
	MW_MODULE mw(
		.O_in(XM_O_out),
		.D_in(XM_D_out),
		.IR_in(XM_IR_out),
		.ctrl_writeEnable(mw_ctrl_writeEnable),
		.ctrl_writeReg(mw_ctrl_writeReg),
		.data_writeReg(mw_data_writeReg)
	);
	
	// MultDiv
	MD_MODULE md(
		.clock(clock),
		.reset(reset),
		
		.effective_A_in(effective_FD_A_in),
		.effective_B_in(effective_FD_B_in),
		.IR_in(FD_IR_out),
		
		.is_MULTDIV_running(is_MULTDIV_running),
		
		.override_MW(override_MW),
		.ctrl_writeEnable(md_ctrl_writeEnable),
		.ctrl_writeReg(md_ctrl_writeReg),
		.data_writeReg(md_data_writeReg)
	);
	
	assign ctrl_writeEnable = override_MW ? md_ctrl_writeEnable : mw_ctrl_writeEnable;
	assign ctrl_writeReg = override_MW ? md_ctrl_writeReg : mw_ctrl_writeReg;
	assign data_writeReg = override_MW ? md_data_writeReg : mw_data_writeReg;
endmodule
