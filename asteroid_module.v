module asteroid_module(
	clock,
	x, y,
	rgb
);

input clock;
input[18:0] x, y;
output[23:0] rgb;

reg[31:0] counter;
reg[4:0] index;
reg go;

reg [30:0] prbs; // pseudo-random bit sequence

initial begin
	index = 0;
	go = 0;
	counter = 0;
	prbs <= 31'd91964901;
end

always @(posedge clock) begin
	prbs <= { prbs[29:0], (prbs[30] ^ prbs[27]) };
end

always @(posedge clock) begin
	if(counter < 100) begin
		go = 0;
	end
		
	if(counter == 10000000) begin
		go = 1;
		index = index + 1;
		if(index == 10) index = 0;
		counter = 0;
	end
	counter = counter + 1;
end

wire[23:0] rgb_res[9:0];
wire[9:0] hit;

genvar i;
generate
	for(i = 0 ; i < 10 ; i = i + 1) begin: asteroid_loop
		asteroid asteroid_inst(
			.clock(clock),
			.x(x), .y(y),
			.go(index == i && go),
			.new_x(prbs & 511),
			.new_y(prbs[0] ? 0 : 480),
			.new_vx(prbs[4:2]-4),
			.new_vy(prbs[0] ? prbs[2:1]+1 : -prbs[2:1]-1),
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
	hit[9] ? rgb_res[9] : 24'd0;

endmodule 