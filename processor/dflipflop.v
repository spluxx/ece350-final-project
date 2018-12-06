module dflipflop(d, clk, clr, pr, ena, q);
    input d, clk, ena, clr, pr;
    output q;
	 
    reg q;

    initial
    begin
        q = 1'b0;
    end

    always @(posedge clk) begin
        if (clr) begin
            q <= 1'b0;
		  end else if (pr) begin
				q <= 1'b1;
        end else if (ena) begin
            q <= d;
        end
    end
endmodule
