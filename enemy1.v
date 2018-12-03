module enemy1(
	clock, 
	initial_x, initial_y, initial_hp, initialize,
	x, y, 
	collided,
	enemy_pos,
	enemy_dead,
	rgb
);

parameter WIDTH_MASK = 19'd511;

input clock;
input [9:0] initial_x, initial_y;
input [9:0] initial_hp; 
input initialize;
input [18:0] x, y;
input collided;
output [19:0] enemy_pos;
output enemy_dead;
output [24:0] rgb;


reg [1:0] state; //0-> uninitialized // 1-> moving right // 2 -> moving left
reg[9:0] enemy_x, enemy_y;
wire[18:0] enemy_dx, enemy_dy;
reg[31:0] ctrl_counter, collision_counter;
reg[4:0] move_counter;
reg[9:0] hp;

reg [30:0] prbs; // pseudo-random bit sequence

assign enemy_pos[19:10] = enemy_x[9:0];
assign enemy_pos[9:0] = enemy_y[9:0];

initial begin
	state <= 2'd0;
	ctrl_counter <= 32'd0;
	collision_counter <= 32'd0;
	move_counter <= 5'd0;
end

always @(posedge clock) begin // when initialize bit is asserted
	if(state == 0) begin
		prbs = initial_x*100+initial_y;
	end
	
	if(state >= 1) begin
		prbs <= { prbs[29:0], (prbs[30] ^ prbs[27]) };
	end
end

always @(negedge clock) begin
	if(state == 0) begin
		if(initialize) begin
			enemy_x = initial_x;
			enemy_y = initial_y;
			hp = initial_hp;
			state = 1;
		end
	end	
	
	if(state == 1 || state == 2) begin
		if(ctrl_counter >= 32'd2000000) begin
			move_counter = move_counter + 1;
			enemy_x = (enemy_x + (state == 1 ? 5 : 507) + (prbs[0] == 1 ? 2 : 510))&511;
			
			if(move_counter == 31) begin
				state = state == 1 ? 2 : 1;
				enemy_y = enemy_y + 5;
				move_counter = 0;
			end
	
			ctrl_counter = 0;
		end
		
		if(collided) begin
			hp = hp - 1;
			if(hp == 0) begin
				enemy_x = 600;
				state = 3;
				ctrl_counter = 0;
			end
		end		
		
		ctrl_counter = ctrl_counter + 1;
		collision_counter = collision_counter + 1;
	end
	
	if(~initialize) begin
		state = 0;
	end
end

assign enemy_dead = state == 3;

assign enemy_dx = (x-enemy_x) & WIDTH_MASK;
assign enemy_dy = y-enemy_y;

wire hit;
assign hit = (19'd0 < enemy_dx) && (enemy_dx < 19'd30) && 
				 (19'd0 < enemy_dy) && (enemy_dy < 19'd40);
				 

wire[23:0] img_rgb;
img_enemy1 img_enemy_inst (
	.address (19'd30*enemy_dy+enemy_dx),
	.clock(clock),
	.q (img_rgb)
);

assign rgb = (~(state == 0 || state == 3) && hit) ? img_rgb : 24'h000000;

endmodule 