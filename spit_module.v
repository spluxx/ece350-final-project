module spit_module(
	clock,
	start,
	enemy_pos,
	enemy_dead,
	x, y,
	collided,
	spit_pos,
	rgb
);

parameter NUM_ENEMY = 5;

input clock, start;
input [20*NUM_ENEMY-1:0] enemy_pos;
input [NUM_ENEMY-1:0] enemy_dead;
input [18:0] x, y;
input[29:0] collided;

output [20*30-1:0] spit_pos;
output [23:0] rgb;

wire [23:0] rgb_res[29:0];
wire hit[29:0];

wire[9:0] enemy_x[NUM_ENEMY-1:0];
wire[9:0] enemy_y[NUM_ENEMY-1:0];

reg[4:0] index;
reg[6:0] enemy_index;
reg [29:0] fire_spit;
reg[31:0] fire_delay;
reg[9:0] fire_x, fire_y;
reg [30:0] prbs; // pseudo-random bit sequence

initial begin
	index <= 5'd0;
	fire_spit <= 30'd0;
	fire_delay <= 32'd0;
	enemy_index <= 7'd0;
	prbs = 31'd9249689;
end

always @(posedge clock) begin // when initialize bit is asserted
	prbs <= { prbs[29:0], (prbs[30] ^ prbs[27]) };
end

always @(posedge clock) begin
	if(start) begin
		if(fire_delay < 100) begin
			fire_spit = 30'd0; // make sure it's unplugged
		end
		
		if(fire_delay == 100000) begin
			enemy_index = prbs[6:0] % NUM_ENEMY;
			fire_x = enemy_x[enemy_index];
			fire_y = enemy_y[enemy_index];
			fire_spit[index] = ~enemy_dead[enemy_index];
			if(index == 30) index = 0;
			fire_delay = 0;
		end
		fire_delay = fire_delay + 1;
	end
end

genvar i;
generate 
	for(i = 0 ; i < 30 ; i = i + 1) begin: spit_loop
		spit spit_inst(
			.clock(clock),
			.x(x), .y(y),
			.fire(fire_spit[i]),
			.new_x(fire_x+13),
			.new_y(fire_y+40),
			.new_vx(0),
			.new_vy(2),
			.collided(collided[i]),
			.spit_pos(spit_pos[20*i+19 : 20*i]),
			.rgb(rgb_res[i]),
			.hit(hit[i])
		);
	end
	
	for(i = 0 ; i < NUM_ENEMY ; i = i + 1) begin: enemy_pos_decode
		assign enemy_x[i] = enemy_pos[20*i+19 : 20*i+10];
		assign enemy_y[i] = enemy_pos[20*i+9 : 20*i+0];
	end
endgenerate

assign rgb = 
	hit[0] ? rgb_res[0] :
	hit[1] ? rgb_res[1] :
	hit[2] ? rgb_res[2] :
	hit[3] ? rgb_res[3] :
	hit[4] ? rgb_res[4] :
	hit[5] ? rgb_res[5] :
	hit[6] ? rgb_res[6] :
	hit[7] ? rgb_res[7] :
	hit[8] ? rgb_res[8] :
	hit[9] ? rgb_res[9] :
	hit[10] ? rgb_res[10] :
	hit[11] ? rgb_res[11] :
	hit[12] ? rgb_res[12] :
	hit[13] ? rgb_res[13] :
	hit[14] ? rgb_res[14] :
	hit[15] ? rgb_res[15] :
	hit[16] ? rgb_res[16] :
	hit[17] ? rgb_res[17] :
	hit[18] ? rgb_res[18] :
	hit[19] ? rgb_res[19] :
	hit[20] ? rgb_res[20] :
	hit[21] ? rgb_res[21] :
	hit[22] ? rgb_res[22] :
	hit[23] ? rgb_res[23] :
	hit[24] ? rgb_res[24] :
	hit[25] ? rgb_res[25] :
	hit[26] ? rgb_res[26] :
	hit[27] ? rgb_res[27] :
	hit[28] ? rgb_res[28] :
	hit[29] ? rgb_res[29] : 24'h000000;
	
	

endmodule 