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
	wire [5:0] colour;
	wire [7:0] x;
	wire [6:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
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
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
	wire [7:0] x0;
	wire [6:0] y0;
	wire [7:0] x_in;
	wire [6:0] y_in;
	wire clock_rate;
	wire clock_30;
	wire undraw;
	wire stop;
	wire reset;
	//wire play;
	//wire draw;
	//wire [3:0] game_state;
	//wire [4:0] row;
	//wire [4:0] column;
	wire [3:0] state;
	wire [5:0] color_in;
	
	rate_divider my_rate_div(
						.clock(CLOCK_50),
						.out(clock_rate)
						);
						
	rate_divider30 my_rate_div_30(
							.clock(CLOCK_50), 
							.out(clock_30)
							);
						
	game_control my_game(
						.clock(CLOCK_50),
						.clock_30(clock_30),
						.start(1'b1),
						.player_x(x0),
						.player_y(y0),
						.direction(state),
						.colour(color_in),
						.x_out(x_in),
						.y_out(y_in),
						.stop(stop),
						.reset(reset)
						);
	
	draw_control my_control(
						.reset_n(reset),
						.clock(CLOCK_50),
						.clock_rate(clock_rate),
						.up(SW[3]),
						.down(SW[2]),
						.left(SW[1]),
						.right(SW[0]),
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
					.undraw(undraw),
					.color_in(color_in),
					.color_out(colour),
					.x_out(x),
					.y_out(y)
					);
					
	hex_display my_hex4(
					.IN(y_in[3:0]),
					.OUT(HEX6[6:0])
					);
	
	hex_display my_hex5(
					.IN(y_in[6:4]),
					.OUT(HEX7[6:0])
					);

	hex_display my_hex6(
					.IN(x_in[3:0]),
					.OUT(HEX4[6:0])
					);
					
	hex_display my_hex7(
					.IN(x_in[7:4]),
					.OUT(HEX5[6:0])
					);
	
	//assign LEDR[3:0] = state;
	//assign LEDR[7:4] = game_state;
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