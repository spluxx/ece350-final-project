module ship(
	clock, 
	start,
	x, y, 
	initial_hp,
	left, right, up, down,
	ship_x, ship_y,
	collided,
	ship_dead,
	rgb
);
	input clock;
	input start;
	input [18:0] x, y;
	input left, right, up, down;
	input collided;
	input[9:0] initial_hp;
	output [18:0] ship_x, ship_y;
	output [24:0] rgb;
	output ship_dead;

	reg[1:0] state;
	reg signed[18:0] ship_x, ship_y;
	wire[18:0] ship_dx, ship_dy;
	reg[31:0] ctrl_counter;
	reg[31:0] anim_counter;
	reg[31:0] flick_counter;
	reg[9:0] hp;
	reg ship_dead;
	
	initial begin
		state <= 0;
		anim_counter <= 32'd0;
	end

	assign ship_dx = (x-ship_x+512)&511;
	assign ship_dy = y-ship_y;

	always @(negedge clock) begin 
		if(state == 1 || state == 3) begin // state = 1 normal // state = 3 invincible, flicking
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
			anim_counter = anim_counter + 1;
			if(anim_counter >= 32'd1000000) begin
				anim_counter = 32'd0;
			end
					
			if(state == 3) begin
				if(flick_counter >= 25000000) begin
					state = 1; // can be hit again
				end
				flick_counter = flick_counter + 1;
			end
					
			if(collided && state == 1) begin
				hp = hp - 1;
				state = 3;
				flick_counter = 0;
				
				if(hp == 0) begin
					state = 2;
					ctrl_counter = 0;
				end
			end	
		end
		
		if(state == 0 && start) begin
			ship_x = 19'd320;
			ship_y = 19'd400;
			ctrl_counter = 32'd0;
			hp = initial_hp;
			state = 1;
			ship_dead = 0;
		end
		
		
		if(state == 2) begin
			if(ctrl_counter > 100000000) begin // go back to menu // register high score here
				ship_dead = 1;
			end
			ctrl_counter = ctrl_counter + 1;
		end
		
		if(~start) begin
			state = 0;
		end
	end
	
	wire hit;
	assign hit = 19'd0 < ship_dx && ship_dx <= 19'd30 && 
					 19'd0 < ship_dy && ship_dy < 19'd40;
					 
	
	wire[23:0] img_rgb[2:0];
	wire[23:0] exp_img_rgb[3:0];
	
	img_ship1 img_ship1_inst (
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (img_rgb[0])
	);
	img_ship2 img_ship2_inst (
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (img_rgb[1])
	);
	img_ship3 img_ship3_inst (
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (img_rgb[2])
	);
	
	ship_exp1 ship_exp1_inst(
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (exp_img_rgb[0])
	);
	ship_exp2 ship_exp2_inst(
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (exp_img_rgb[1])
	);
	ship_exp3 ship_exp3_inst(
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (exp_img_rgb[2])
	);
	ship_exp4 ship_exp4_inst(
		.address (19'd30*ship_dy+ship_dx),
		.clock(clock),
		.q (exp_img_rgb[3])
	);
	
	assign rgb = ((state == 1 || (state == 3 && (flick_counter & 2097151) >= 1048576)) && hit) ? 
						((anim_counter < 32'd333333) ? img_rgb[0] :
						 (anim_counter < 32'd666666) ? img_rgb[1] : img_rgb[2]) :
					 (state == 2 && hit) ? 
										(ctrl_counter < 10000000 ? exp_img_rgb[0] :
										 ctrl_counter < 20000000 ? exp_img_rgb[1] :
										 ctrl_counter < 30000000 ? exp_img_rgb[2] :
										 ctrl_counter < 40000000 ? exp_img_rgb[3] : 24'h000000) : 24'h000000;
endmodule 