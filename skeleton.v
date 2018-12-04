module skeleton(
	resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	VGA SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50,														// 50 MHz clock
	left,
	right,
	up,
	down,
//	fire,
	
	// audio ports
	AUD_ADCLRCK,
	AUD_ADCDAT,
	AUD_DACLRCK,
	AUD_DACDAT,
	AUD_XCK,
	AUD_BCLK,
	
	I2C_SDAT,
	I2C_SCLK
);  													
		
	////////////////////////	VGA	////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	//////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	////////////////////////   Ship control /////////////////////////////
	input left, right, up, down;
//	fire;
	
	/////////////////////////////////////////////////////////////////////
	
	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire	[7:0]	 ps2_out;	
	
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	// your processor
	processor myprocessor(clock, ~resetn, /*ps2_key_pressed, ps2_out, lcd_write_en, lcd_write_data,*/ debug_data_in, debug_addr);
	
	// keyboard controller
	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, ps2_out, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(ps2_out[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(ps2_out[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
		
	// VGA
	wire AUD_CTRL_CLK;
	
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	
	vga_controller vga_ins(
		.CLOCK_50(CLOCK_50),
		.iRST_n(DLY_RST),
		.iVGA_CLK(VGA_CLK),
		.oBLANK_n(VGA_BLANK),
		.oHS(VGA_HS),
		.oVS(VGA_VS),
		.b_data(VGA_B),
		.g_data(VGA_G),
		.r_data(VGA_R),
		.left(left),
		.right(right),
		.up(up),
		.down(down),
		.fire(fire),
		.leds()
	);
	
	/////////////// AUDIO ////////////////////
	input				AUD_ADCDAT;
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;
		
	inout				I2C_SDAT;
	output			I2C_SCLK;
	
	// Outputs
	output			AUD_XCK;
	
	output			AUD_DACDAT;
	
	wire				audio_in_available;
	wire signed[31:0]	left_channel_audio_in;
	wire signed[31:0]	right_channel_audio_in;
	wire				read_audio_in;
	
	wire				audio_out_allowed;
	wire[31:0]		left_channel_audio_out;
	wire[31:0]		right_channel_audio_out;
	wire				write_audio_out;	

	
	reg [31:0] counter;
	reg signed [63:0] sum;
	reg [63:0] res;

	initial begin
		sum = 64'd0;
		counter = 0;
		res = 64'd0;
	end

	always @(negedge AUD_XCK) begin
		sum = sum + left_channel_audio_in;
		counter = counter + 1;
		if(counter >= 1000000) begin
			res = sum / counter;
			counter = 0;
		end
	end
	
	assign read_audio_in			= audio_in_available & audio_out_allowed;

	wire [31:0] left_in, right_in, left_out, right_out;
	assign left_in = left_channel_audio_in;
	assign right_in = right_channel_audio_in;

	assign left_out = left_in;
	assign right_out = right_in;

	assign fire = | res[31:26];
	assign leds = res[31:24];

	assign left_channel_audio_out	= left_out;
	assign right_channel_audio_out	= right_out;
	assign write_audio_out			= audio_in_available & audio_out_allowed;
	
	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(1'b0),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT),

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.I2C_SCLK					(I2C_SCLK),
		.I2C_SDAT					(I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(1'b0),
		.key1							(1'b1),
		.key2							(1'b1)
	);

	
endmodule
