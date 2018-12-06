module shiftMux32(in, sel, out);
	input [31:0] in;
	input [7:0] sel;
	output [31:0] out;
	
	wire [31:0] p00, p01, p02, p03, p04, p05, p06, p07;
	wire [31:0] p08, p09, p10, p11, p12, p13, p14, p15;
	wire [31:0] p16, p17, p18, p19, p20, p21, p22, p23;
	wire [31:0] p24, p25, p26, p27, p28, p29, p30, p31;
	
	assign p00 = in << 5'b00000;
	assign p01 = in << 5'b00001;
	assign p02 = in << 5'b00010;
	assign p03 = in << 5'b00011;
	assign p04 = in << 5'b00100;
	assign p05 = in << 5'b00101;
	assign p06 = in << 5'b00110;
	assign p07 = in << 5'b00111;
	
	assign p08 = in << 5'b01000;
	assign p09 = in << 5'b01001;
	assign p10 = in << 5'b01010;
	assign p11 = in << 5'b01011;
	assign p12 = in << 5'b01100;
	assign p13 = in << 5'b01101;
	assign p14 = in << 5'b01110;
	assign p15 = in << 5'b01111;
	
	assign p16 = in << 5'b10000;
	assign p17 = in << 5'b10001;
	assign p18 = in << 5'b10010;
	assign p19 = in << 5'b10011;
	assign p20 = in << 5'b10100;
	assign p21 = in << 5'b10101;
	assign p22 = in << 5'b10110;
	assign p23 = in << 5'b10111;

	assign p24 = in << 5'b11000;
	assign p25 = in << 5'b11001;
	assign p26 = in << 5'b11010;
	assign p27 = in << 5'b11011;
	assign p28 = in << 5'b11100;
	assign p29 = in << 5'b11101;
	assign p30 = in << 5'b11110;
	assign p31 = in << 5'b11111;
	
	assign out = ~(sel[4] ? 
						(sel[3] ? 
							(sel[2] ? 
								(sel[1] ? 
									(sel[0] ? p31 : p30) :
									(sel[0] ? p29 : p28)) :
								(sel[1] ?
									(sel[0] ? p27 : p26) :
									(sel[0] ? p25 : p24))) : 
							(sel[2] ? 
								(sel[1] ? 
									(sel[0] ? p23 : p22) :
									(sel[0] ? p21 : p20)) :
								(sel[1] ?
									(sel[0] ? p19 : p18) :
									(sel[0] ? p17 : p16)))) : 
						(sel[3] ? 
							(sel[2] ? 
								(sel[1] ? 
									(sel[0] ? p15 : p14) :
									(sel[0] ? p13 : p12)) :
								(sel[1] ?
									(sel[0] ? p11 : p10) :
									(sel[0] ? p09 : p08))) : 
							(sel[2] ? 
								(sel[1] ? 
									(sel[0] ? p07 : p06) :
									(sel[0] ? p05 : p04)) :
								(sel[1] ?
									(sel[0] ? p03 : p02) :
									(sel[0] ? p01 : p00)))));
endmodule 