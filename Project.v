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
		HEX7,
		HEX0,
		HEX1,
		HEX2,
		HEX3
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
	output  [6:0]   HEX0;
	output  [6:0]   HEX1;
	output  [6:0]   HEX2;
	output  [6:0]   HEX3;
	
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
	
	wire [7:0] x0;
	wire [6:0] y0;
	wire [7:0] x_in;
	wire [6:0] y_in;
	wire start;
	wire q;
	wire undraw;
	wire stop;
	wire reset;
	wire play;
	wire draw;
	wire [3:0] game_state;
	wire [4:0] row;
	wire [4:0] column;
	wire [3:0] state;
	wire [2:0] color_in;
	
	rate_divider my_rate_div(
						.clock(CLOCK_50),
						.out(start)
						);
						
	rate_divider30 my_rate_div_30(
							.clock(CLOCK_50), 
							.out(q)
							);
						
	game_control my_game(
						.clock_rate(CLOCK_50),
						.clock_30(q),
						.start(1'b1),
						.player_x(x0),
						.player_y(y0),
						.direction(state),
						.colour(color_in),
						.x_out(x_in),
						.y_out(y_in),
						.stop(stop),
						.reset(reset),
						.play(play),
						.row(row),
						.column(column),
						.draw(draw),
						.state(game_state)
						);
	
	draw_control my_control(
						.reset_n(reset),
						.clock(CLOCK_50),
						.draw(start),
						.up(SW[4]),
						.down(SW[3]),
						.left(SW[2]),
						.right(SW[1]),
						.stop(stop),
						.undraw(undraw),
						.x_out(x0),
						.y_out(y0),
						.state(state)
						);
	
	datapath my_datapath(
					.clock(CLOCK_50),
					.x0(x_in),
					.y0(y_in),
					.erase(erase),
					.undraw(undraw),
					.color_in(color_in),
					.color_out(colour),
					.x_out(x),
					.y_out(y)
					);
					
	hex_display my_hex4(
					.IN(y_in[3:0]),
					.OUT(HEX4[6:0])
					);
	
	hex_display my_hex5(
					.IN(y_in[6:4]),
					.OUT(HEX5[6:0])
					);

	hex_display my_hex6(
					.IN(x_in[3:0]),
					.OUT(HEX6[6:0])
					);
					
	hex_display my_hex7(
					.IN(x_in[7:4]),
					.OUT(HEX7[6:0])
					);
	
	hex_display my_hex0(
					.IN(x0[3:0]),
					.OUT(HEX0[6:0])
					);
	
	hex_display my_hex1(
					.IN(x0[7:4]),
					.OUT(HEX1[6:0])
					);
	
	hex_display my_hex2(
					.IN(y0[3:0]),
					.OUT(HEX2[6:0])
					);
	
	hex_display my_hex3(
					.IN(y0[6:4]),
					.OUT(HEX3[6:0])
					);
	
	assign LEDR[3:0] = state;
	assign LEDR[7:4] = game_state;
endmodule

module game_control(clock_rate, clock_30, start, player_x, player_y, direction, colour, x_out, y_out, stop, reset, play, row, column, draw, state);
	input clock_rate;
	input clock_30;
	input start;
	input [7:0] player_x;
	input [6:0] player_y;
	input [3:0] direction;
	output [2:0] colour;
	output [7:0] x_out;
	output [6:0] y_out;
	output reg stop;
	output reg reset;
	output reg play;
	output [4:0] row;
	output [4:0] column;
	output reg draw;
	output [3:0] state;
	
	localparam S_START = 3'b000 , S_LOAD_1 = 3'b001, S_LOAD_2 = 3'b010, S_LOAD_3 = 3'b011 , S_DRAW = 3'b100, S_PLAY = 3'b101, S_KEY = 3'b110;
	
	localparam UP = 4'b1000, DOWN = 4'b0100, LEFT = 4'b0010, RIGHT = 4'b0001;
	
	reg [4:0] counter_x;
	reg [4:0] counter_y;
	reg [1:0] current_state;
	initial current_state = S_START;
	//reg play;
	//wire [4:0] row;
	//wire [4:0] column;
	
	reg [2:0] data [0:31][0:23];
	
	always @(posedge clock_rate)
		begin
			case(current_state)
				S_START:	begin
							play <= 1'b0;
							draw <= 1'b0;
							if (start == 1'b1)
								current_state <= S_LOAD_1;
							end
							
				S_LOAD_1:	begin
							play <= 1'b0;
							draw <= 1'b0;
							data[15][0] <= 3'b111;
							data[14][0] <= 3'b100;
							data[13][0] <= 3'b110;
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							current_state <= S_DRAW;
							end
				
				S_LOAD_2:	begin
							play <= 1'b0;
							draw <= 1'b0;
							data[15][0] <= 3'b111;
							data[14][0] <= 3'b000;
							data[13][0] <= 3'b100;
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							current_state <= S_DRAW;
							end
							
				S_DRAW:		begin
							play <= 1'b0;
							draw <= 1'b1;
							if (clock_30 == 1'b1)
								if(counter_x < 5'b11111)
									counter_x <= counter_x + 1'b1;
									
								else if(counter_y < 5'b10111)
									begin
									counter_x <= 1'b0;
									counter_y <= counter_y + 1'b1;
									end
									
								else if (counter_x == 5'b11111 && counter_y == 5'b10111)
									begin
									current_state <= S_PLAY;
									reset <= 1'b0;
									end
							end
				S_PLAY:		begin
							play <= 1'b1;
							draw <= 1'b0;
							if (direction == UP)
								begin
								if (data[player_x / 5][(player_y - 1) / 5] == 3'b111)
									stop <= 1'b1;
									
								else if (data[player_x / 5][(player_y - 1) / 5] == 3'b100)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_1;
									end
								else if (data[player_x / 5][(player_y - 1) / 5] == 3'b110)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_2;
									end
								end
								
							else if (direction == DOWN)
								begin
								if (data[player_x / 5][(player_y + 5) / 5] == 3'b111)
									stop <= 1'b1;
									
								else if (data[player_x / 5][(player_y + 5) / 5] == 3'b100)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_1;
									end
								else if (data[player_x / 5][(player_y + 5) / 5] == 3'b110)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_2;
									end
								end
							
							else if (direction == LEFT)
								begin
								if (data[(player_x - 1) / 5][player_y / 5] == 3'b111)
									stop <= 1'b1;
									
								else if (data[(player_x - 1) / 5][player_y / 5] == 3'b100)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_1;
									end
								else if (data[(player_x - 1) / 5][player_y / 5] == 3'b110)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_2;
									end
								end
							
							else if (direction == RIGHT)
								begin
								if (data[(player_x + 5) / 5][player_y / 5] == 3'b111)
									stop <= 1'b1;
									
								else if (data[(player_x + 5) / 5][player_y / 5] == 3'b100)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_1;
									end
								else if (data[(player_x + 5) / 5][player_y / 5] == 3'b110)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_LOAD_2;
									end
								end
							else
								stop <= 1'b0;
							end
			endcase
		end
	assign row = counter_x;
	assign column = counter_y;
	assign colour = play ? 3'b111 : data[row][column];
	assign x_out = play ? player_x : row * 5;
	assign y_out = play ? player_y : column * 5;
	assign state = current_state;
endmodule

module draw_control(reset_n, clock, draw, undraw, up, down, left, right, stop, x_out, y_out, state);
	input reset_n;
	input clock;
	input draw;
	input up;
	input down;
	input left;
	input right;
	input stop;
	output reg undraw;
	output reg [7:0] x_out;
	output reg [6:0] y_out;
	output [3:0] state;
	
	initial undraw = 1'b0;
	
	localparam S_REST = 4'b0000, S_UP = 4'b1000, S_DOWN = 4'b0100, S_LEFT = 4'b0010, S_RIGHT = 4'b0001;
	
	reg [3:0] current_state;
	initial current_state = S_REST;
	reg [7:0] x0;
	reg [6:0] y0; 
	initial x0 = 7'd0;
	initial y0 = 7'd0;
	
	always @(posedge clock)
		begin
			if (reset_n == 1'b1)
				begin
				x0 <= 1'b0;
				y0 <= 1'b0;
				current_state <= S_REST;
				end
			
			if (draw == 1'b1)
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
						if (stop == 1'b1)
							current_state <= S_REST;
						else if (y0 > 1'b0 && undraw == 1'b1 && stop == 1'b0)
							undraw <= 1'b0;
						else if (y0 > 1'b0 && stop == 1'b0)
							begin
							y0 <= y0 - 1'b1;
							undraw <= 1'b1;
							end
						else if (y0 == 1'b0)
							current_state <= S_REST;
						end
						
				S_DOWN:	begin
						if (stop == 1'b1)
							current_state <= S_REST;
						else if (y0 < 7'b1110010 && undraw == 1'b1)
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
						if (stop == 1'b1)
							current_state <= S_REST;
						else if (x0 > 1'b0 && undraw == 1'b1)
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
						if (stop == 1'b1)
							current_state <= S_REST;
						else if (x0 < 8'b10011010 && undraw == 1'b1)
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
	
	always @(*)
		begin
			if (undraw == 1'b1)
				case(current_state)
					S_UP: 	begin
							y_out <= y0 + 1'b1;
							x_out <= x0;
							end
							
					S_DOWN: begin
							y_out <= y0 - 1'b1;
							x_out <= x0;
							end
							
					S_LEFT: begin
							x_out <= x0 + 1'b1;
							y_out <= y0;
							end
							
					S_RIGHT:begin
							x_out <= x0 - 1'b1;
							y_out <= y0;
							end
					default:begin
							x_out <= x0;
							y_out <= y0;
							end
				endcase
			else
				begin
				x_out <= x0;
				y_out <= y0;
				end
		end	
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

module datapath(clock, x0, y0, erase, undraw, color_in, color_out, x_out, y_out);
	input clock;
	input [7:0] x0;
	input [6:0] y0;
	input [2:0] color_in;
	input erase;
	input undraw;
	output [2:0] color_out;
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
				//num_cycles <= 28'b101111110111111101101111;
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
				cycles <= 5'b11101;
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