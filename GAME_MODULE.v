module GAME_MODULE(
	clock,
	start,
	x, y,
	up, left, right, down, fire,
	ship_dead,
	rgb,
	leds,
	score,
	hp, 
	reset,
);

parameter NUM_ENEMY1 = 6;

input clock;
input start;
input [18:0] x, y;
output[23:0] rgb;
output ship_dead;
output[7:0] leds;
output [31:0] score;
output[9:0] hp;

output reg reset; // resets the level, preserving hp/score

////////////////////////////////////////////////
// Ship - Fixed width 30 height 40
input left, right, up, down, fire;
wire [18:0] ship_x, ship_y;
wire [23:0] ship_rgb;
wire [19:0] ship_pos;
assign ship_pos[19:10] = ship_x[9:0];
assign ship_pos[9:0] = ship_y[9:0];
wire collided_ship;

ship ship_inst(
	.clock(clock),
	.reset(reset),
	.start(start),
	.initial_hp(5),
	.x(x), .y(y),
	.left(~start | left), 
	.right(~start | right), 
	.up(~start | up), 
	.down(~start | down),
	.ship_x(ship_x), .ship_y(ship_y),
	.collided(collided_ship),
	.ship_dead(ship_dead),
	.rgb(ship_rgb),
	.hp(hp)
);

////////////////////////////////////////////////////
// Self-moving entities (bullets/enemies)
// BULLETS & ENEMIES

wire [23:0] rgb_bullet;
wire [23:0] enemy_rgb[NUM_ENEMY1-1:0];
wire [23:0] rgb_spit;

wire [20*30-1:0] bullet_pos; // 32*30
wire [20*NUM_ENEMY1-1:0] enemy_pos;
wire [20*30-1:0] spit_pos;

wire [29:0] collided_bullets;
wire [NUM_ENEMY1-1:0] collided_enemy;
wire [29:0] collided_spit;

wire [NUM_ENEMY1-1:0] enemy_dead;

reg[1:0] state;
reg[9:0] level;
reg [NUM_ENEMY1-1:0] counted_enemy_dead;
reg [31:0] score;
integer idx;

genvar i;
generate
	for(i = 0 ; i < NUM_ENEMY1 ; i = i + 1) begin: enemy1gen
		enemy1 enemy1_inst(
			.clock(clock),
			.reset(reset),
			.level(level),
			.initial_x(60*(i & 7) + 10),
			.initial_y(100*(i >> 3) + 10),
			.initial_hp(5),
			.initialize(start),
			.x(x), .y(y),
			.collided(collided_enemy[i]),
			.enemy_dead(enemy_dead[i]),
			.enemy_pos(enemy_pos[20*i+19 : 20*i]),
			.rgb(enemy_rgb[i])
		);
	end
endgenerate

initial begin
	state = 0;
end

assign leds[5:0] = counted_enemy_dead;
assign leds[6] = start;
assign leds[7] = reset;

always @(negedge clock) begin
	if(state == 1) begin
		for(idx = 0 ; idx < NUM_ENEMY1 ; idx = idx + 1) begin
			if(~counted_enemy_dead[idx] && enemy_dead[idx]) begin
				score = score + 37;
				counted_enemy_dead[idx] = 1;
			end
		end
	end
	
	if(state == 0 && start) begin // starting at level 1
		counted_enemy_dead = 0;
		score = 0;
		level = 1;
		state = 1;
	end
		
	if(state == 2 && (left | right | up | down)) begin
		state = 1;
		reset = 0;
	end	
	
	if(& counted_enemy_dead) begin // everything dead
		counted_enemy_dead = 0;
		state = 2;
		reset = 1;
		level = level + 1;
	end

	if(~start) begin
		state = 0;
		level = 1;
	end
end

bullet_module bullet_module_inst (
	.clock(clock),
	.reset(reset),
	.start(start),
	.ship_x(ship_x), 
	.ship_y(ship_y),
	.x(x), .y(y),
	.collided(collided_bullets),
	.fire(fire),
	.bullet_pos(bullet_pos),
	.rgb(rgb_bullet)
);

collision_module #(
	.objectA_cnt(NUM_ENEMY1),
	.objectA_width(30), // 30
	.objectA_height(40),
	.objectB_cnt(30),
	.objectB_width(10), // 5
	.objectB_height(10)
) enemy_bullet_collision_module (
	.clock(clock),
	.objectA_positions(enemy_pos),
	.objectB_positions(bullet_pos),
	.resultA(collided_enemy),
	.resultB(collided_bullets)
);

spit_module #(
	.NUM_ENEMY(NUM_ENEMY1)
)spit_module_inst (
	.clock(clock),
	.reset(reset),
	.level(level),
	.start(start),
	.enemy_pos(enemy_pos),
	.enemy_dead(enemy_dead),
	.x(x), .y(y),
	.ship_x(ship_x),
	.collided(collided_spit),
	.spit_pos(spit_pos),
	.rgb(rgb_spit)
);

collision_module #(
	.objectA_cnt(1),
	.objectA_width(30), // 30
	.objectA_height(40),
	.objectB_cnt(30),
	.objectB_width(10), // 5
	.objectB_height(10)
) ship_spit_collision_module (
	.clock(clock),
	.objectA_positions(ship_pos),
	.objectB_positions(spit_pos),
	.resultA(collided_ship),
	.resultB(collided_spit)
);

////////////////////////////////////////////////
// final decision on the pixel at (x, y)
wire [23:0] final_rgb;

assign rgb = (x==0 || x >= 512)				?  24'h000000 : // in this case, it's literally black 
					 ship_rgb != 24'h000000 		? 	ship_rgb : 
					 enemy_rgb[0] != 24'h000000 	? 	enemy_rgb[0] : 
					 enemy_rgb[1] != 24'h000000 	? 	enemy_rgb[1] : 
					 enemy_rgb[2] != 24'h000000 	? 	enemy_rgb[2] : 
					 enemy_rgb[3] != 24'h000000 	? 	enemy_rgb[3] : 
					 enemy_rgb[4] != 24'h000000 	? 	enemy_rgb[4] : 
					 enemy_rgb[5] != 24'h000000 	? 	enemy_rgb[5] :
//					 enemy_rgb[6] != 24'h000000 	? 	enemy_rgb[6] :
//					 enemy_rgb[7] != 24'h000000 	? 	enemy_rgb[7] :
//					 enemy_rgb[8] != 24'h000000 	? 	enemy_rgb[8] :
//					 enemy_rgb[9] != 24'h000000 	? 	enemy_rgb[9] :
//					 enemy_rgb[10] != 24'h000000 	? 	enemy_rgb[10] :
//					 enemy_rgb[11] != 24'h000000 	? 	enemy_rgb[11] :
//					 enemy_rgb[12] != 24'h000000 	? 	enemy_rgb[12] : 
//					 enemy_rgb[13] != 24'h000000 	? 	enemy_rgb[13] : 
//					 enemy_rgb[14] != 24'h000000 	? 	enemy_rgb[14] : 
//					 enemy_rgb[15] != 24'h000000 	? 	enemy_rgb[15] : 
//					 enemy_rgb[16] != 24'h000000 	? 	enemy_rgb[16] : 
//					 enemy_rgb[17] != 24'h000000 	? 	enemy_rgb[17] :
//					 enemy_rgb[18] != 24'h000000 	? 	enemy_rgb[18] :
//					 enemy_rgb[19] != 24'h000000 	? 	enemy_rgb[19] :
					 rgb_bullet != 24'h000000 		?  rgb_bullet : 
					 rgb_spit != 24'h000000 		?  rgb_spit : 24'h000000;


endmodule 