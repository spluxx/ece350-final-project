module bullet_module(
	clock,
	reset,
	start,
	ship_x, ship_y,
	x, y,
	collided,
	fire,
	bullet_pos,
	rgb
);

parameter BULLET_NUM = 20;

input clock, start;
input reset;
input [18:0] ship_x, ship_y, x, y;
input fire;
input[BULLET_NUM-1:0] collided;

output [20*BULLET_NUM-1:0] bullet_pos;
output [23:0] rgb;

wire [23:0] rgb_res[BULLET_NUM:0];
wire hit[BULLET_NUM:0];

reg state;
reg[4:0] index;
reg[BULLET_NUM:0] fire_bullet;
reg[31:0] fire_delay;

initial begin
	index <= 5'd0;
	fire_bullet <= 30'd0;
	fire_delay <= 32'd0;
	state = 0;
end

always @(posedge clock) begin
	if(state == 0 && start) begin
		if(fire_delay == 5000000) begin
			state = 1;
			fire_delay = 0;
		end
		fire_delay = fire_delay+1;
	end
	
	if(state == 1 && fire) begin
		if(fire_delay < 100) begin
			fire_bullet = 20'd0; // make sure it's unplugged
		end
		
		if(fire_delay == 5000000) begin
			fire_bullet[index] = 1;
			index = index + 1;
			if(index == BULLET_NUM) index = 0;
			
			fire_delay = 0;
		end
		fire_delay = fire_delay + 1;
	end
	
	if(~start) begin
		fire_delay = 0;
		state = 0;
	end
end

genvar i;
generate 
	for(i = 0 ; i < BULLET_NUM ; i = i + 1) begin: bullet_loop
		bullet bullet_inst(
			.clock(clock),
			.reset(reset),
			.x(x), .y(y),
			.fire(fire_bullet[i]),
			.new_x(ship_x+13),
			.new_y(ship_y-10),
			.new_vx(0),
			.new_vy(-2),
			.collided(collided[i]),
			.bullet_pos(bullet_pos[20*i+19 : 20*i]),
			.rgb(rgb_res[i]),
			.hit(hit[i])
		);
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
	hit[19] ? rgb_res[19] : 24'h000000;
	
	

endmodule 