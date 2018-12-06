module spit(
	clock,
	reset,
	x, y,
	fire,
	new_x, new_y,
	new_vx, new_vy,
	collided,
	spit_pos,
	rgb,
	hit
);

parameter WIDTH_MASK = 19'd511;

input clock, reset;
input fire;
input signed[18:0] x, y, new_x, new_y, new_vx, new_vy;
input collided;

output [19:0] spit_pos;
output [23:0] rgb;
output hit;

reg state; // 0 not "out there" // 1 "out there"
reg signed [18:0] spit_x, spit_y, spit_vx, spit_vy;
reg [31:0] counter;

assign spit_pos[19:10] = spit_x[9:0];
assign spit_pos[9:0] = spit_y[9:0];

initial begin
	state <= 1'b0;
end

always @(negedge clock) begin
	if(state == 0 && fire) begin
		spit_x = new_x;
		spit_y = new_y;
		spit_vx = new_vx;
		spit_vy = new_vy;
		counter = 32'd0;
		state = 1;
	end
	
	if(state == 1) begin
		if(counter == 100000) begin
			spit_x = (spit_x + spit_vx + 512) & WIDTH_MASK;
			spit_y = spit_y + spit_vy;
			if(spit_y < 0 || spit_y > 480) begin
				spit_x = 0;
				spit_y = 0;
				state = 0;
			end
			counter = 0;
		end
		counter = counter + 1;
	end
	
	if(collided || reset) begin
		spit_x = 0;
		spit_y = 0;
		state = 0;
	end
end

wire signed [18:0] spit_dx, spit_dy;

assign spit_dx = (x - spit_x + 512) & WIDTH_MASK;
assign spit_dy = y-spit_y;

wire hit;
assign hit = (19'd0 < spit_dx) && (spit_dx <= 19'd5) && 
				 (19'd0 < spit_dy) && (spit_dy < 19'd10);
				 
assign rgb = (state == 1 && hit) ? 24'h33ff33 : 24'h000000;

	
endmodule 