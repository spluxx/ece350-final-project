module bullet(
	clock, 
	reset,
	x, y,
	fire,
	new_x, new_y,
	new_vx, new_vy,
	collided,
	bullet_pos,
	rgb,
	hit
);

parameter WIDTH_MASK = 19'd511;

input clock, reset;
input fire;
input [18:0] x, y, new_x, new_y, new_vx, new_vy;
input collided;

output [19:0] bullet_pos;
output [23:0] rgb;
output hit;

reg state; // 0 not "out there" // 1 "out there"
reg signed [18:0] bullet_x, bullet_y, bullet_vx, bullet_vy;
reg [31:0] counter;

assign bullet_pos[19:10] = bullet_x[9:0];
assign bullet_pos[9:0] = bullet_y[9:0];

initial begin
	state <= 1'b0;
end

always @(negedge clock) begin
	if(state == 0 && fire) begin
		bullet_x = new_x;
		bullet_y = new_y;
		bullet_vx = new_vx;
		bullet_vy = new_vy;
		counter = 32'd0;
		state = 1;
	end
	
	if(state == 1) begin
		if(counter == 100000) begin
			bullet_x = (bullet_x + bullet_vx + 512) & WIDTH_MASK;
			bullet_y = bullet_y + bullet_vy;
			if(bullet_y < 0 || bullet_y > 480) begin
				bullet_x = 0;
				bullet_y = 0;
				state = 0;
			end
			counter = 0;
		end
		counter = counter + 1;
	end
	
	if(collided || reset) begin
		bullet_x = 0;
		bullet_y = 0;
		state = 0;
	end
end

wire signed [18:0] bullet_dx, bullet_dy;

assign bullet_dx = (x - bullet_x + 512) & WIDTH_MASK;
assign bullet_dy = y-bullet_y;

wire hit;
assign hit = (19'd0 < bullet_dx) && (bullet_dx <= 19'd5) && 
				 (19'd0 < bullet_dy) && (bullet_dy < 19'd10);
				 

wire[23:0] img_rgb;
img_bullet img_bullet_inst (
	.address (19'd5*bullet_dy+bullet_dx),
	.clock(clock),
	.q (img_rgb)
);

assign rgb = (state == 1 && hit) ? img_rgb : 24'h000000;

	
endmodule 