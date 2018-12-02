module collision_module (
	clock,
	objectA_positions,
	objectB_positions,
	resultA,
	resultB
);

parameter objectA_cnt = 6;
parameter objectA_width = 30;
parameter objectA_height = 40;
parameter objectB_cnt = 30;
parameter objectB_width = 5;
parameter objectB_height = 10;

input clock;

input[20*objectA_cnt-1:0] objectA_positions;
input[20*objectB_cnt-1:0] objectB_positions;

output[objectA_cnt-1:0] resultA;
output[objectB_cnt-1:0] resultB;

wire signed[9:0] objectA_x[objectA_cnt-1:0];
wire signed[9:0] objectA_y[objectA_cnt-1:0];

wire signed[9:0] objectB_x[objectB_cnt-1:0];
wire signed[9:0] objectB_y[objectB_cnt-1:0];

wire[objectB_cnt-1:0] intersects[objectA_cnt-1:0];
wire[objectA_cnt-1:0] intersectsTr[objectB_cnt-1:0];

reg[objectA_cnt-1:0] resultA;
reg[objectB_cnt-1:0] resultB;

integer i;
always @(posedge clock) begin
	for(i = 0 ; i < objectA_cnt ; i = i + 1) begin
		resultA[i] <= | intersects[i];
	end
	
	for(i = 0 ; i < objectB_cnt ; i = i + 1) begin
		resultB[i] <= | intersectsTr[i];
	end
end

genvar idx1, idx2;
generate
	for(idx1 = 0 ; idx1 < objectA_cnt ; idx1 = idx1 + 1) begin: loopA
		assign objectA_x[idx1] = objectA_positions[20*idx1+19 : 20*idx1+10];
		assign objectA_y[idx1] = objectA_positions[20*idx1+9 : 20*idx1+0];
	end
	
	for(idx2 = 0 ; idx2 < objectB_cnt ; idx2 = idx2 + 1) begin: loopB
		assign objectB_x[idx2] = objectB_positions[20*idx2+19 : 20*idx2+10];
		assign objectB_y[idx2] = objectB_positions[20*idx2+9 : 20*idx2+0];
	end
	
	for(idx1 = 0 ; idx1 < objectA_cnt ; idx1 = idx1 + 1) begin: lpA
		for(idx2 = 0 ; idx2 < objectB_cnt ; idx2 = idx2 + 1) begin: lpB
			assign intersects[idx1][idx2] = ~((objectB_x[idx2]-objectA_x[idx1]-objectA_width >= 0) ||
														 (objectA_x[idx1]-objectB_x[idx2]-objectB_width >= 0) ||
														 (objectB_y[idx2]-objectA_y[idx1]-objectA_height >= 0) ||
														 (objectA_y[idx1]-objectB_y[idx2]-objectB_height >= 0));
			assign intersectsTr[idx2][idx1] = intersects[idx1][idx2];
		end
	end
endgenerate

endmodule 