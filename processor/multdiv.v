module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
	input [31:0] data_operandA, data_operandB;
	input ctrl_MULT, ctrl_DIV, clock;

	output [31:0] data_result;
	output data_exception, data_resultRDY;


	wire [31:0] multRes, divRes, res;
	wire resetCounter, ready, mult_exception, div_exception, ctrl_MULT_P;

	assign resetCounter = ctrl_MULT | ctrl_DIV;

	// keep control bits, to output right things
	dflipflop persistMultCtrl(.d(1'b0), .clk(clock), .clr(ctrl_DIV), .pr(ctrl_MULT), .ena(1'b0), .q(ctrl_MULT_P));
	
	// counter
	counter33 counter(.clk(clock), .reset(resetCounter), .isReady(data_resultRDY));

	// multiplier
	multiplier mult(.A(data_operandA), .B(data_operandB), 
						.clk(clock), .fetch(ctrl_MULT), 
						.res(multRes), .exception(mult_exception));

	// divider
	divider div(.A(data_operandA), .B(data_operandB),
				  .clk(clock), .fetch(ctrl_DIV),	
				  .res(divRes), .exception(div_exception));
				 
	// result
	assign data_exception = ctrl_MULT_P ? mult_exception : div_exception;
	assign data_result = ctrl_MULT_P ? multRes : divRes;
endmodule
