module datapath(clock, x0, y0, undraw, color_in, color_out, x_out, y_out);
	input clock;
	input [7:0] x0;
	input [6:0] y0;
	input [5:0] color_in;
	input undraw;
	output [5:0] color_out;
	output [7:0] x_out;
	output [6:0] y_out;
		
	wire [3:0] x;
	wire [3:0] y;
	
	draw my_draw(
				.clock(clock),
				.x(x),
				.y(y)
				);
		
	assign x_out = x0 + x;
	assign y_out = y0 + y;
	assign color_out = undraw ? 3'b000000 : color_in;
endmodule 