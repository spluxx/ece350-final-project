module ship(
	clock, 
	start,
	x, y, 
	left, right, up, down,
	ship_x, ship_y,
	rgb
);
	input clock;
	input start;
	input [18:0] x, y;
	input left, right, up, down;
	output [18:0] ship_x, ship_y;
	output [24:0] rgb;

	reg signed[18:0] ship_x, ship_y;
	wire[18:0] ship_dx, ship_dy;
	reg[31:0] ctrl_counter;

	initial begin
		ship_x <= 19'd320;
		ship_y <= 19'd400;
		ctrl_counter <= 32'd0;
	end

	assign ship_dx = (x-ship_x+512)&511;
	assign ship_dy = y-ship_y;

	always @(negedge clock) begin 
		if(ctrl_counter >= 32'd100000) begin
			if(!left) begin
				ship_x = ship_x - 1;
			end
			if(!right) begin
				ship_x = ship_x + 1;
			end
			if(!up) begin
				ship_y = ship_y - 1;
			end
			if(!down) begin
				ship_y = ship_y + 1;
			end
			
			if(ship_x == 512) ship_x = 0;
			if(ship_x < 0) ship_x = 511; 
			ctrl_counter = 32'd0;
		end
		ctrl_counter = ctrl_counter + 1;
	end
	
	wire hit;
	assign hit = 19'd0 <= ship_dx && ship_dx < 19'd30 && 
					 19'd0 <= ship_dy && ship_dy < 19'd40;
					 
	
	wire[23:0] img_rgb;
	img_ship img_ship_inst (
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (img_rgb)
	);
	
	assign rgb = (start && hit) ? img_rgb : 24'h000000;
endmodule 