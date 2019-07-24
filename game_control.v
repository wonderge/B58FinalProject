module game_control(clock, clock_30, start, player_x, player_y, direction, colour, x_out, y_out, stop, reset);
	input clock;
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
	output [3:0] state;
	
	localparam S_START = 4'b0000 , S_LOAD_1 = 4'b0001, S_LOAD_2 = 4'b0010, S_LOAD_3 = 4'b0111 , S_DRAW = 4'b0011, S_PLAY = 4'b1011, S_KEY = 3'b110;
	
	localparam UP = 4'b1000, DOWN = 4'b0100, LEFT = 4'b0010, RIGHT = 4'b0001;
	
	reg [4:0] counter_x;
	reg [4:0] counter_y;
	reg [3:0] current_state;
	initial current_state = S_START;
	reg play;
	wire [4:0] row;
	wire [4:0] column;
	
	reg [2:0] data [0:31][0:23];
	reg [1:0] stage;
	integer i;
	integer j;
	
	always @(posedge clock)
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
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= 3'b111;
								data[i][23] <= 3'b111;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= 3'b111;
								data[31][j] <= 3'b111;
								end
							data[16][1] <= 3'b000;
							data[15][1] <= 3'b111;
							data[14][1] <= 3'b100;
							data[13][1] <= 3'b010;
							data[12][1] <= 3'b000;
							data[11][1] <= 3'b000;
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 1'b1;
							current_state <= S_DRAW;
							end
				
				S_LOAD_2:	begin
							play <= 1'b0;
							draw <= 1'b0;
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= 3'b111;
								data[i][23] <= 3'b111;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= 3'b111;
								data[31][j] <= 3'b111;
								end
							data[16][1] <= 3'b100;
							data[15][1] <= 3'b111;
							data[14][1] <= 3'b000;
							data[13][1] <= 3'b100;
							data[12][1] <= 3'b010;
							data[11][1] <= 3'b000;
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 2'b10;
							current_state <= S_DRAW;
							end
							
				S_LOAD_3:	begin
							play <= 1'b0;
							draw <= 1'b0;
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= 3'b111;
								data[i][23] <= 3'b111;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= 3'b111;
								data[31][j] <= 3'b111;
								end
							data[16][1] <= 3'b000;
							data[15][1] <= 3'b111;
							data[14][1] <= 3'b000;
							data[13][1] <= 3'b100;
							data[12][1] <= 3'b000;
							data[11][1] <= 3'b010;
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 2'b11;
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
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[player_x / 5][(player_y - 1) / 5] == 3'b010)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_2;
										2'b10:	current_state <= S_LOAD_3;
										2'b11:	current_state <= S_LOAD_1;
									endcase
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
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[player_x / 5][(player_y + 5) / 5] == 3'b010)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_2;
										2'b10:	current_state <= S_LOAD_3;
										2'b11:	current_state <= S_LOAD_1;
									endcase
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
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[(player_x - 1) / 5][player_y / 5] == 3'b010)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_2;
										2'b10:	current_state <= S_LOAD_3;
										2'b11:	current_state <= S_LOAD_1;
									endcase
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
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[(player_x + 5) / 5][player_y / 5] == 3'b010)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_2;
										2'b10:	current_state <= S_LOAD_3;
										2'b11:	current_state <= S_LOAD_1;
									endcase
									end
								end
							else
								stop <= 1'b0;
							end
			endcase
		end
	assign row = counter_x;
	assign column = counter_y;
	assign colour = play ? 3'b001 : data[row][column];
	assign x_out = play ? player_x : row * 5;
	assign y_out = play ? player_y : column * 5;
endmodule 