module asteroid(
	clock,
	x, y,
	go, 
	new_x, new_y, new_vx, new_vy,
	rgb,
	hit
);

input clock;
input go;
input[18:0] x, y;
input[18:0] new_x, new_y, new_vx, new_vy;
output[23:0] rgb;
output hit;

reg state; // 0 not "out there" // 1 "out there"
reg signed [18:0] ast_x, ast_y, ast_vx, ast_vy;
reg [31:0] counter;

initial begin
	state <= 1'b0;
end

always @(negedge clock) begin
	if(state == 0 && go) begin
		ast_x = new_x;
		ast_y = new_y;
		ast_vx = new_vx;
		ast_vy = new_vy;
		counter = 32'd0;
		state = 1;
	end
	
	if(state == 1) begin
		if(counter == 500000) begin
			ast_x = (ast_x + ast_vx + 512) & 511;
			ast_y = ast_y + ast_vy;
			if(ast_y < 0 || ast_y > 480) begin
				ast_x = 0;
				ast_y = 0;
				state = 0;
			end
			counter = 0;
		end
		counter = counter + 1;
	end
end

wire signed [18:0] ast_dx, ast_dy;

assign ast_dx = (x - ast_x + 512) & 511;
assign ast_dy = y-ast_y;

wire hit;
assign hit = (19'd0 < ast_dx) && (ast_dx <= 19'd2) && 
				 (19'd0 < ast_dy) && (ast_dy < 19'd2);
				 
assign rgb = (state == 1 && hit) ? 24'h888888 : 24'h000000;

endmodule 