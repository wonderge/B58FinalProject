module draw(clock, x, y);
	input clock;
	output reg [3:0] x;
	output reg [3:0] y;
	
	always @(posedge clock)
		begin
			if (x < 4'b0100)
				x <= x + 1'b1;
			else if (y < 4'b0100)
				begin
				x <= 1'b0;
				y <= y + 1'b1;
				end
			else
				begin
				x <= 1'b0;
				y <= 1'b0;
				end
		end
endmodule 