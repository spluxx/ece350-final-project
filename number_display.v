module number_display(
	clock,
	x, y, 
	pos_x, pos_y,
	score, first, second, third, fourth, fifth,
	rgb
);

	input clock;
	input[18:0] x, y;
	input[9:0] pos_x, pos_y;
	input[31:0] score, first, second, third, fourth, fifth;
	output reg[23:0] rgb;
	
	wire[23:0] rgbs[9:0];
	reg[3:0] index;
	wire[10:0] address;

	assign address = 
		(526 < x && x < 556 && 100 < y && y < 140) ? (x-526)+(y-100)*30 :
		(561 < x && x < 591 && 100 < y && y < 140) ? (x-561)+(y-100)*30 :
		(596 < x && x < 626 && 100 < y && y < 140) ? (x-596)+(y-100)*30 :
		
		(526 < x && x < 556 && 250 < y && y < 290) ? (x-526)+(y-250)*30 :
		(561 < x && x < 591 && 250 < y && y < 290) ? (x-561)+(y-250)*30 :
		(596 < x && x < 626 && 250 < y && y < 290) ? (x-596)+(y-250)*30 :
		
		(526 < x && x < 556 && 290 < y && y < 330) ? (x-526)+(y-290)*30 :
		(561 < x && x < 591 && 290 < y && y < 330) ? (x-561)+(y-290)*30 :
		(596 < x && x < 626 && 290 < y && y < 330) ? (x-596)+(y-290)*30 :
		
		(526 < x && x < 556 && 330 < y && y < 370) ? (x-526)+(y-330)*30 :
		(561 < x && x < 591 && 330 < y && y < 370) ? (x-561)+(y-330)*30 :
		(596 < x && x < 626 && 330 < y && y < 370) ? (x-596)+(y-330)*30 :
		
		(526 < x && x < 556 && 370 < y && y < 410) ? (x-526)+(y-370)*30 :
		(561 < x && x < 591 && 370 < y && y < 410) ? (x-561)+(y-370)*30 :
		(596 < x && x < 626 && 370 < y && y < 410) ? (x-596)+(y-370)*30 :
		
		(526 < x && x < 556 && 410 < y && y < 450) ? (x-526)+(y-410)*30 :
		(561 < x && x < 591 && 410 < y && y < 450) ? (x-561)+(y-410)*30 :
		(596 < x && x < 626 && 410 < y && y < 450) ? (x-596)+(y-410)*30 : 11'd0; // don't care
	
		
	always @(posedge clock) begin
		if(526 < x && x < 556 && 100 < y && y < 140) begin
			index = (score/100)%10;
		end
		if(561 < x && x < 591 && 100 < y && y < 140) begin
			index = (score/10)%10;
		end
		if(596 < x && x < 626 && 100 < y && y < 140) begin 
			index = (score)%10;
		end
			
		if(526 < x && x < 556 && 250 < y && y < 290) begin 	
			index = (first/100)%10;
		end
		if(561 < x && x < 591 && 250 < y && y < 290) begin
			index = (first/10)%10;
		end
		if(596 < x && x < 626 && 250 < y && y < 290) begin 
			index = (first)%10;
		end
			
		if(526 < x && x < 556 && 290 < y && y < 330) begin 
			index = (second/100)%10;
		end
		if(561 < x && x < 591 && 290 < y && y < 330) begin 
			index = (second/10)%10;
		end
		if(596 < x && x < 626 && 290 < y && y < 330) begin 
			index = (second)%10;
		end
			
		if(526 < x && x < 556 && 330 < y && y < 370) begin 
			index = (third/100)%10;
		end
		if(561 < x && x < 591 && 330 < y && y < 370) begin 
			index = (third/10)%10;
		end
		if(596 < x && x < 626 && 330 < y && y < 370) begin 
			index = (third)%10;
		end
			
		if(526 < x && x < 556 && 370 < y && y < 410) begin 
			index = (fourth/100)%10;
		end
		if(561 < x && x < 591 && 370 < y && y < 410) begin 
			index = (fourth/10)%10;
		end
		if(596 < x && x < 626 && 370 < y && y < 410) begin 
			index = (fourth)%10;
		end
			
		if(526 < x && x < 556 && 410 < y && y < 450) begin
			index = (fifth/100)%10;
		end
		if(561 < x && x < 591 && 410 < y && y < 450) begin 
			index = (fifth/10)%10;
		end
		if(596 < x && x < 626 && 410 < y && y < 450) begin 
			index = (fifth)%10;
		end
		
		rgb = rgbs[index];
	end
	
	zero zero_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[0])
	);
	one one_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[1])
	);
	two two_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[2])
	);
	three three_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[3])
	);
	four four_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[4])
	);
	five five_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[5])
	);
	six six_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[6])
	);
	seven seven_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[7])
	);
	eight eight_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[8])
	);
	nine nine_inst(
		.address(address),
		.clock(clock),
		.q(rgbs[9])
	);
endmodule 