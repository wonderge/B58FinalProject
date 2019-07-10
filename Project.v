// Part 2 skeleton

module Project
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR,
		HEX6,
		HEX7
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output  [9:0]   LEDR;
	output  [6:0]   HEX6;
	output  [6:0]   HEX7;
	
	wire resetn;
	assign resetn = SW[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(3'b111),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
	wire stop;
	wire move;
	wire [1:0] direction;
	wire start;
	
	rate_divider my_rate_div(
						.clock(CLOCK_50),
						.out(start)
						);
	
	control my_control(
					.reset_n(1'b0),
					.clock(CLOCK_50),
					.up(~KEY[3]),
					.down(~KEY[2]),
					.left(~KEY[1]),
					.right(~KEY[0]),
					.stop(stop),
					.move(move),
					.dir_out(direction),
					.state(LEDR[7:4])
					);
	
	datapath my_datapath(
					.clock_50(CLOCK_50),
					.clock(start),
					.move(move),
					.direction(direction),
					.x_out(x),
					.y_out(y),
					.stop(stop)
					);
	assign LEDR[0] = stop;
	assign LEDR[2:1] = direction;
	assign LEDR[3] = start;	

	hex_display my_hex6(
					.IN(x[3:0]),
					.OUT(HEX6[6:0])
					);
					
	hex_display my_hex7(
					.IN(x[7:4]),
					.OUT(HEX7[6:0])
					);
endmodule

module control(reset_n, clock, up, down, left, right, stop, move, dir_out, state);
	input reset_n;
	input clock;
	input up;
	input down;
	input left;
	input right;
	input stop;
	output reg move;
	output reg [1:0] dir_out;
	output [3:0] state;
	
	localparam S_REST = 4'b0000, S_UP = 4'b1000, S_DOWN = 4'b0100, S_LEFT = 4'b0010, S_RIGHT = 4'b0001;
	
	reg [3:0] current_state;
	initial current_state = S_REST;
	reg [3:0] next_state;
	always @(*)
		begin
			if (up == 1'b1 && current_state == S_REST)
				next_state <= S_UP;
			else if (down == 1'b1 && current_state == S_REST)
				next_state <= S_DOWN;
			else if (left == 1'b1 && current_state == S_REST)
				next_state <= S_LEFT;
			else if (right == 1'b1 && current_state == S_REST)
				next_state <= S_RIGHT;
			else if (stop == 1'b1 && current_state != S_REST)
				next_state <= S_REST;
		end
		
	always @(posedge clock)
		begin
			current_state <= next_state;
			
			if (current_state == S_UP)
				begin
				move <= 1'b1;
				dir_out <= 2'b01;
				end
			if (current_state == S_DOWN)
				begin
				move <= 1'b1;
				dir_out <= 2'b00;
				end
			if (current_state == S_LEFT)
				begin
				move <= 1'b1;
				dir_out <= 2'b10;
				end
			if (current_state == S_RIGHT)
				begin
				move <= 1'b1;
				dir_out <= 2'b11;
				end
			else
				move <= 1'b0;
		end
	assign state = current_state;
endmodule

module datapath(clock_50, clock, move, direction, x_out, y_out, stop);
	input clock;
	input clock_50;
	input move;
	input [1:0] direction;
	output [7:0] x_out;
	output [6:0] y_out;
	output reg stop;
	
	reg [7:0] x0;
	reg [6:0] y0;	
	
	reg [3:0] x;
	reg [3:0] y;
	always @(posedge clock_50)
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

	localparam DOWN = 2'b00, UP = 2'b01, LEFT = 2'b10, RIGHT = 2'b11;
	
	always @(posedge clock)
		begin
			if (move == 1'b1)
				begin
				if (direction == UP && y0 > 1'b0)
					y0 <= y0 - 1'b1;
			
				else if (direction == DOWN && y0 < 7'b1110100)
					y0 <= y0 + 1'b1;
			
				else if (direction == LEFT && x0 > 1'b0)
					x0 <= x0 - 1'b1;
			
				else if (direction == RIGHT && x0 < 8'b10011100)
					x0 <= x0 + 1'b1;
				end
		end
	assign x_out = x0 + x;
	assign y_out = y0 + y;
	
	always @(*)
		begin
			if (x0 == 1'b0 && direction == LEFT)
				stop = 1'b1;
			else if (x0 == 8'b10011100 && direction == RIGHT)
				stop = 1'b1;
			else if (y0 == 1'b0 && direction == UP)
				stop = 1'b1;
			else if (y0 == 7'b1110100 && direction == DOWN)
				stop = 1'b1;
			else
				stop = 1'b0;
		end
endmodule

module rate_divider(clock, out);
	input clock;
	output reg out;
	
	reg [27:0] num_cycles;
	always @(posedge clock)
		begin
			if (num_cycles == 1'b0)
				begin
				num_cycles <= 28'b101111101011110000011111;
				out <= 1'b1;
				end
			else
				begin
				num_cycles <= num_cycles - 1'b1;
				out <= 1'b0;
				end
		end
endmodule 

module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [7:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			
			default: OUT = 7'b0111111;
		endcase

	end
endmodule 