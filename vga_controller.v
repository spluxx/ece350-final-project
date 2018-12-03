module vga_controller(
	CLOCK_50, // syncing with processor
	
	iRST_n,
	iVGA_CLK,
	oBLANK_n,
	oHS,
	oVS,
	b_data,
	g_data,
	r_data,

	// ship controller
	left,
	right,
	up,
	down,
	fire,
	
	leds
);

input CLOCK_50;
input iRST_n;
input iVGA_CLK;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data; 

output [7:0] leds; 

input left, right, up, down, fire; 

///////// ////                     
reg [18:0] ADDR;
wire VGA_CLK_n;
wire [23:0] bgr_data;
wire cBLANK_n,cHS,cVS,rst;
assign VGA_CLK_n = ~iVGA_CLK;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
///////////////////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+19'd1;
end

///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

///////////////////
// Basic ops
wire [18:0] x, y;
assign x = ADDR%19'd640;
assign y = ADDR/19'd640;

reg state;
reg[31:0] counter;

wire ship_dead;

initial begin
	state = 0;
	counter = 0;
end


always @(posedge iVGA_CLK) begin
	if(state == 1 && (~down || ship_dead)) begin
		state = 0;
		counter = 0;
	end
	
	if(state == 0) begin
		if(~up) state = 1;
		if(counter < 32'h07ffffff) begin
			counter = counter + 1;
		end
	end
end

//////////////////
// GAME MODULE
wire [23:0] game_rgb;

GAME_MODULE game_inst(
	.clock(iVGA_CLK),
	.start(state),
	.x(x), .y(y),
	.up(up), 
	.left(left), 
	.right(right),
	.down(down),
	.fire(fire),
	.ship_dead(ship_dead),
	.rgb(game_rgb),
	.leds(leds)
);

//////////////////
// MENU SCREEN
wire[18:0] logo_dx, logo_dy;
wire logo_hit;
assign logo_dx = x-20;
assign logo_dy = y-50;
assign logo_hit = 0 < logo_dx && logo_dx < 480 &&
						0 < logo_dy && logo_dy < 80;

wire[18:0] menu_text_dx, menu_text_dy;
wire menu_text_hit;
assign menu_text_dx = x-50;
assign menu_text_dy = y-300;
assign menu_text_hit =  0 < menu_text_dx && menu_text_dx < 400 &&
								0 < menu_text_dy && menu_text_dy < 100;

wire logo_data, menu_text_data;		
wire[23:0] logo_rgb, menu_text_rgb;						
								
img_logo img_logo_inst (
	.address (logo_dx + logo_dy * 480),
	.clock (iVGA_CLK),
	.q(logo_data)
);

img_menu_text_data img_menu_text_inst (
	.address (menu_text_dx + menu_text_dy * 400),
	.clock (iVGA_CLK),
	.q(menu_text_data)
);

wire[23:0] gradient; 
assign gradient[23:16] = counter >> 19;
assign gradient[15:8] = counter >> 19;
assign gradient[7:0] = counter >> 19;

assign logo_rgb = logo_data ? gradient : 24'd0;
assign menu_text_rgb = menu_text_data ? gradient : 24'd0;

/////////////////////////////////////////////////
// Background
wire[7:0] background_data;
wire[7:0] background_r, background_g, background_b;
wire[23:0] asteroid_rgb;

asteroid_module asteroid_module_inst(
	.clock(iVGA_CLK),
	.x(x), .y(y),
	.rgb(asteroid_rgb)
);

bgr_data	bgr_data_inst (
	.address (y*512+x),
	.clock ( iVGA_CLK ),
	.q (background_data)
);

assign background_b = asteroid_rgb != 24'd0 ? asteroid_rgb[23:16] : (background_data & 8'b00000011) << 5;
assign background_g = asteroid_rgb != 24'd0 ? asteroid_rgb[15:8] : (background_data & 8'b00011100) << 3;
assign background_r = asteroid_rgb != 24'd0 ? asteroid_rgb[7:0] : (background_data & 8'b11100000);

/////////////////
// RGB OUTPUT

wire is_bgr;
wire[23:0] final_rgb;
assign final_rgb = (state == 0 && logo_hit) 			? logo_rgb : 
						 (state == 0 && menu_text_hit) 	? menu_text_rgb :
						 (state == 1) 							? game_rgb : 24'd0;
														  
assign is_bgr = final_rgb == 24'd0;

// replace 8'd0 with sidebar[7:0]
assign b_data = x >= 512 ? 8'd0 : (is_bgr ? background_b : final_rgb[23:16]);
assign g_data = x >= 512 ? 8'd0 : (is_bgr ? background_g : final_rgb[15:8]);
assign r_data = x >= 512 ? 8'd0 : (is_bgr ? background_r : final_rgb[7:0]);

endmodule
 	















