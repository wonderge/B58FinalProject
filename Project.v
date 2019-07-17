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
		HEX4,
		HEX5,
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
	output  [6:0]   HEX4;
	output  [6:0]   HEX5;
	output  [6:0]   HEX6;
	output  [6:0]   HEX7;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(SW[0]),
			.clock(CLOCK_50),
			.colour(colour),
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
	
	wire [3:0] offset_x;
	wire [3:0] offset_y;
	wire [7:0] x0;
	wire [6:0] y0;
	wire erase;
	wire start;
	wire undraw;
	wire [3:0] state;
	
	rate_divider my_rate_div(
						.clock(CLOCK_50),
						.out(start)
						);
	
	control my_control(
					.reset_n(1'b0),
					.clock(CLOCK_50),
					.draw(start),
					.up(SW[4]),
					.down(SW[3]),
					.left(SW[2]),
					.right(SW[1]),
					.offset_x(offset_x),
					.offset_y(offset_y),
					.erase(erase),
					.undraw(undraw),
					.x_out(x0),
					.y_out(y0),
					.state(state)
					);
	
	datapath my_datapath(
					.clock(start),
					.x0(x0),
					.y0(y0),
					.offset_x(offset_x),
					.offset_y(offset_y),
					.erase(erase),
					.undraw(undraw),
					.color_in(3'b111),
					.color_out(colour),
					.x_out(x),
					.y_out(y)
					);
					
	hex_display my_hex4(
					.IN(y0[3:0]),
					.OUT(HEX4[6:0])
					);
	
	hex_display my_hex5(
					.IN(y0[6:4]),
					.OUT(HEX5[6:0])
					);

	hex_display my_hex6(
					.IN(x0[3:0]),
					.OUT(HEX6[6:0])
					);
					
	hex_display my_hex7(
					.IN(x0[7:4]),
					.OUT(HEX7[6:0])
					);
	
	assign LEDR[3:0] = state;
endmodule

<<<<<<< HEAD
<<<<<<< Updated upstream
module control(reset_n, clock, draw, up, down, left, right, offset_x, offset_y, erase, x_out, y_out, state);
=======
module game_control(clock_rate, clock_30, start, draw);
	input clock_rate;
	input clock_30;
	input start;
	output draw;
	output [2:0] colour;
	output [4:0] x_out;
	output [4:0] y_out;
	localparam S_START = 2'b00 , S_LOAD_1 = 2'b01 , S_DRAW_1 = 2'b10, S_PLAY_1 = 2'b11;
	
	reg [4:0] counter_x;
	reg [4:0] counter_y;
	reg [1:0] current_state;
	initial current_state = S_START;
	reg play;
	wire [4:0] row;
	wire [4:0] column;
	
	reg [2:0] data [0:31][0:23];
	
	always @(posedge clock_rate)
		begin
			case(current_state)
				S_START:	begin
							if (start == 1'b1)
								current_state <= S_LOAD_1;
							end
							
				S_LOAD_1:	begin
							draw <= 1'b1;
							data[15][0] <= 3'b111;
							counter_x = 1'b0;
							counter_y = 1'b0;
							current_state <= S_DRAW_1;
							end
				S_DRAW_1:	begin
							if (clock_30 == 1'b1)
								if(counter_x < 5'b11111)
									counter_x <= counter_x + 1'b1;
								else if(counter_y < 5'b10111)
									begin
									counter_x <= 1'b0;
									end
								else if (counter_x == 5'b11111 && counter_y == 5'b10111)
									current_state <= S_PLAY_1;
				S_PLAY_1:	
					
			endcase
		end
	assign row = counter_x;
	assign column = counter_y;
	
	assign colour = play ? 3'b111 : data[row][column];
	assign x_out = 
endmodule

module control(reset_n, clock, draw, undraw, up, down, left, right, offset_x, offset_y, erase, x_out, y_out, state);
>>>>>>> Stashed changes
=======
module control(reset_n, clock, draw, undraw, up, down, left, right, offset_x, offset_y, erase, x_out, y_out, state);
>>>>>>> 9ae9345ce5f75862b7602a29c030097c795b4d1f
	input reset_n;
	input clock;
	input draw;
	input up;
	input down;
	input left;
	input right;
	output [3:0] offset_x;
	output [3:0] offset_y;
	output erase;
	output reg undraw;
	output [7:0] x_out;
	output [6:0] y_out;
	output [3:0] state;
	
	initial undraw = 1'b0;
	
	localparam S_REST = 4'b0000, S_UP = 4'b1000, S_DOWN = 4'b0100, S_LEFT = 4'b0010, S_RIGHT = 4'b0001;
	
	reg [3:0] current_state;
	initial current_state = S_REST;
	reg [7:0] x0;
	reg [6:0] y0; 
	initial x0 = 7'd0;
	initial y0 = 7'd0;
	
<<<<<<< HEAD
<<<<<<< Updated upstream
	always @(posedge clock)
=======
	reg [2:0] data [0:32][0:24];
	
	always @(posedge draw)
>>>>>>> Stashed changes
=======
	always @(posedge draw)
>>>>>>> 9ae9345ce5f75862b7602a29c030097c795b4d1f
		begin
			case(current_state)
				S_REST:	begin
						undraw = 1'b0;
						if (up == 1'b1)
							current_state <= S_UP;
						else if (down == 1'b1)
							current_state <= S_DOWN;
						else if (left == 1'b1)
							current_state <= S_LEFT;
						else if (right == 1'b1)
							current_state <= S_RIGHT;
						end
						
				S_UP:	begin
						if(y0 > 1'b0 && undraw == 1'b1)
							undraw <= 1'b0;
						else if (y0 > 1'b0)
							begin
							y0 <= y0 - 1'b1;
							undraw <= 1'b1;
							end
						else if (y0 == 1'b0)
							current_state <= S_REST;
						end
						
				S_DOWN:	begin
						if(y0 < 7'b1110010 && undraw == 1'b1)
							undraw <= 1'b0;
						else if (y0 < 7'b1110010)
							begin
							y0 <= y0 + 1'b1;
							undraw <= 1'b1;
							end
						else if (y0 == 7'b1110010)
							current_state <= S_REST;
						end
						
				S_LEFT:	begin
						if(x0 > 1'b0 && undraw == 1'b1)
							undraw <= 1'b0;
						else if (x0 > 1'b0)
							begin
							x0 <= x0 - 1'b1;
							undraw <= 1'b1;
							end
						else if (x0 == 1'b0)
							current_state <= S_REST;
						end
						
				S_RIGHT:begin
						if(x0 < 8'b10011010 && undraw == 1'b1)
							undraw <= 1'b0;
						else if (x0 < 8'b10011010)
							begin
							x0 <= x0 + 1'b1;
							undraw <= 1'b1;
							end
						else if (x0 == 8'b10011010)
							current_state <= S_REST;
						end
				default:current_state <= S_REST;
			endcase
		end
	assign x_out = x0;
	assign y_out = y0;
	
	wire [3:0] x;
	wire [3:0] y;
	
	draw my_draw(
				.clock(clock),
				.x(x),
				.y(y)
				);
				
	assign offset_x = x;
	assign offset_y = y;
	
	assign state = current_state;
endmodule

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

module datapath(clock, x0, y0, offset_x, offset_y, erase, undraw, color_in, color_out, x_out, y_out);
	input clock;
	input [7:0] x0;
	input [6:0] y0;
	input [3:0] offset_x;
	input [3:0] offset_y;
	input [2:0] color_in;
	input erase;
	input undraw;
	output [2:0] color_out;
	output [7:0] x_out;
	output [6:0] y_out;	
	
	reg [7:0] x;
	reg [6:0] y;
	always @(posedge clock)
		begin
			x <= x0;
			y <= y0;
		end
		
	assign x_out = x + offset_x;
	assign y_out = y + offset_y;
	assign color_out = undraw ? 3'b000 : color_in;
endmodule

module rate_divider(clock, out);
	input clock;
	output reg out;
	
	reg [27:0] num_cycles;
	always @(posedge clock)
		begin
			if (num_cycles == 1'b0)
				begin
				num_cycles <= 28'b1011011100011010111;
				out <= 1'b1;
				end
			else
				begin
				num_cycles <= num_cycles - 1'b1;
				out <= 1'b0;
				end
		end
endmodule 

module rate_divider30(clock, out);
	input clock;
	output reg out;
	
	reg [4:0] cycles;
	always @(posedge clock)
		begin
			if (cycles == 1'b0)
				begin
				cycles <= 5'11101
				out <= 1'b1;
				end
			else
				begin
				cycles <= cycles - 1'b1;
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