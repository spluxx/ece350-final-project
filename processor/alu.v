module alu(
	data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, 
	data_result, isNotEqual, isLessThan, overflow
);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

   output [31:0] data_result;
   output isNotEqual, isLessThan, overflow;

	wire [31:0] notB, effective_B, sumRes, orRes, andRes, shiftRes; 
	wire ctrl_sub;
	wire [4:0] nopcode;
	
	genvar i;
	generate
		for(i = 0 ; i < 5 ; i = i + 1) begin: loop
			not no(nopcode[i], ctrl_ALUopcode[i]);
		end
		for(i = 0 ; i < 32 ; i = i + 1) begin: loop1
			not notb(notB[i], data_operandB[i]);
		end
	endgenerate
	
	and subc(ctrl_sub, nopcode[2], nopcode[1], ctrl_ALUopcode[0]); // sub
	
	assign effective_B = ctrl_sub ? notB : data_operandB;
	
	adder32bit adder(.a(data_operandA), .b(effective_B), .ctrl_sub(ctrl_sub), 
							.s(sumRes), .p(orRes), .g(andRes), 
							.isOvf(overflow), .isNotEqual(isNotEqual), .isLessThan(isLessThan));
							
	shifter shift(data_operandA, ctrl_shiftamt, ctrl_ALUopcode[0], nopcode[0], shiftRes);
	
	mux3 res(sumRes, sumRes, andRes, orRes, shiftRes, shiftRes, 32'b0, 32'b0,
				ctrl_ALUopcode[2], ctrl_ALUopcode[1], ctrl_ALUopcode[0], data_result);
endmodule