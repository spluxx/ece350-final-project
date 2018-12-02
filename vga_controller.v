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
	fire
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

initial begin
	state = 0;
end

always @(posedge iVGA_CLK) begin
	if(~up) state = 1;
	if(~down) state = 0;
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
	.rgb(game_rgb)
);



/////////////////////////////////////////////////
// Background
wire[7:0] background_data;
wire[7:0] background_r, background_g, background_b;

bgr_data	bgr_data_inst (
	.address (y*512+x),
	.clock ( iVGA_CLK ),
	.q (background_data)
);

assign background_b = (background_data & 8'b00000011) << 5;
assign background_g = (background_data & 8'b00011100) << 3;
assign background_r = (background_data & 8'b11100000);

/////////////////
// RGB OUTPUT

wire is_bgr;
wire[23:0] final_rgb;

assign final_rgb = state == 0 ? 24'd0 : game_rgb;
assign is_bgr = final_rgb == 24'd0;

assign b_data = is_bgr ? background_b : final_rgb[23:16];
assign g_data = is_bgr ? background_g : final_rgb[15:8];
assign r_data = is_bgr ? background_r : final_rgb[7:0];

endmodule
 	















