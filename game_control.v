module game_control(clock, clock_30, start, player_x, player_y, direction, colour, x_out, y_out, stop, reset);
	input clock;
	input clock_30;
	input start;
	input [7:0] player_x;
	input [6:0] player_y;
	input [3:0] direction;
	output [5:0] colour;
	output [7:0] x_out;
	output [6:0] y_out;
	output reg stop;
	output reg reset;
	//output [3:0] state;
	
	localparam S_LOAD_1 = 4'b0001, S_LOAD_2 = 4'b0010, S_LOAD_3 = 4'b0111 , 
	           S_DRAW = 4'b0011, S_PLAY = 4'b1011, S_KEY = 4'b1100, S_CLEAR = 4'b0110;
	
	localparam UP = 4'b1000, DOWN = 4'b0100, LEFT = 4'b0010, RIGHT = 4'b0001;

	localparam BLANK = 6'b000000, TRAP = 6'b110000, GOAL = 6'b001100, WALL = 6'b111111, KEY = 6'b111100,
			   PLAYER = 6'b000011, R_WALL = 6'b101010, L_WALL = 6'b001111, U_WALL = 6'b110011, D_WALL = 6'b111000;
	
	/* Black: Blank space
	 * Red: Trap
	 * Green: Goal
	 * White: Wall
	 * Yellow: Key
	 * Blue: Player
	 * Cyan: Left Wall
	 * Magenta: Up Wall
	 * Orange: Down Wall
	 * Grey: Right Wall
	 */
	
	reg [4:0] counter_x;
	reg [4:0] counter_y;
	reg [3:0] current_state;
	initial current_state = S_LOAD_1;
	reg play;
	wire [4:0] row;
	wire [4:0] column;
	
	reg [5:0] data [0:31][0:23];
	reg [1:0] stage;
	
	//Used when level needs a key
	reg [4:0] key_x;
	reg [4:0] key_y;
	reg [4:0] goal_x;
	reg [4:0] goal_y;
	wire [4:0] key_x_pos;
	wire [4:0] key_y_pos;
	wire [4:0] goal_x_pos;
	wire [4:0] goal_y_pos;
	
	assign key_x_pos = key_x;
	assign key_y_pos = key_y;
	assign goal_x_pos = goal_x;
	assign goal_y_pos = goal_y;
	
	integer i;
	integer j;
	
	always @(posedge clock)
		begin
			case(current_state)
				S_CLEAR:    begin
							for(i = 0; i < 32; i = i + 1)
								begin
								for(j = 0; j < 24; j = j + 1)
									begin
									data[i][j] <= BLANK;
									end
								end
							case(stage)
								2'b01:	current_state <= S_LOAD_2;
								2'b10:	current_state <= S_LOAD_3;
								2'b11:	current_state <= S_LOAD_1;
							endcase
							end
							
				S_LOAD_1:	begin
							play <= 1'b0;
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= WALL;
								data[i][23] <= WALL;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= WALL;
								data[31][j] <= WALL;
								end
							//Row 1	
							data[9][1] <= TRAP;
							data[10][1] <= TRAP;
							data[11][1] <= TRAP;
							data[12][1] <= L_WALL;
							data[19][1] <= WALL;
							//Row 2
							data[8][2] <= WALL;
							data[9][2] <= WALL;
							data[10][2] <= WALL;
							goal_x <= 11;
							goal_y <= 2;
							data[19][2] <= WALL;
							//Row 3
							data[1][3] <= WALL;
							data[2][3] <= WALL;
							data[3][3] <= WALL;
							data[4][3] <= WALL;
							data[5][3] <= WALL;
							data[6][3] <= WALL;
							data[11][3] <= WALL;
							data[19][3] <= WALL;
							//Row 4
							data[1][4] <= WALL;
							data[2][4] <= TRAP;
							data[3][4] <= TRAP;
							data[4][4] <= TRAP;
							data[5][4] <= TRAP;
							data[11][4] <= WALL;
							data[19][4] <= WALL;
							//Row 5
							data[7][5] <= D_WALL;
							data[11][5] <= WALL;
							data[19][5] <= WALL;
							//Row 6
							data[8][6] <= WALL;
							data[11][6] <= WALL;
							data[19][6] <= WALL;
							//Row 7
							data[1][7] <= WALL;
							data[8][7] <= WALL;
							data[11][7] <= WALL;
							data[19][7] <= WALL;
							//Row 8
							data[1][8] <= WALL;
							data[2][8] <= WALL;
							data[3][8] <= WALL;
							data[4][8] <= WALL;
							data[5][8] <= WALL;
							data[6][8] <= WALL;
							data[7][8] <= WALL;
							data[8][8] <= WALL;
							data[11][8] <= WALL;
							data[19][8] <= WALL;
							//Row 9
							data[1][9] <= WALL;
							data[11][9] <= R_WALL;
							data[19][9] <= WALL;
							//Row 10
							data[1][10] <= WALL;
							data[4][10] <= WALL;
							data[5][10] <= WALL;
							data[6][10] <= WALL;
							data[7][10] <= WALL;
							data[8][10] <= WALL;
							data[9][10] <= WALL;
							data[10][10] <= WALL;
							data[11][10] <= WALL;
							data[12][10] <= WALL;
							data[13][10] <= WALL;
							data[14][10] <= WALL;
							data[15][10] <= WALL;
							data[16][10] <= WALL;
							data[17][10] <= WALL;
							data[18][10] <= WALL;
							data[19][10] <= WALL;
							//Row 11
							data[1][11] <= WALL;
							data[18][11] <= TRAP;
							data[19][11] <= WALL;
							//Row 12
							data[1][12] <= WALL;
							data[19][12] <= WALL;
							//Row 13
							data[1][13] <= WALL;
							data[2][13] <= WALL;
							data[3][13] <= WALL;
							data[4][13] <= WALL;
							data[5][13] <= WALL;
							data[6][13] <= WALL;
							data[7][13] <= WALL;
							data[8][13] <= WALL;
							data[9][13] <= WALL;
							data[10][13] <= WALL;
							data[11][13] <= WALL;
							data[12][13] <= WALL;
							data[13][13] <= WALL;
							data[14][13] <= WALL;
							data[15][13] <= WALL;
							data[16][13] <= WALL;
							data[19][13] <= WALL;
							//Row 14
							data[1][14] <= TRAP;
							data[13][14] <= R_WALL;
							data[16][14] <= WALL;
							data[19][14] <= WALL;
							//Row 15
							data[1][15] <= WALL;
							data[16][15] <= WALL;
							data[19][15] <= WALL;
							//Row 16
							data[1][16] <= TRAP;
							data[4][16] <= WALL;
							data[5][16] <= WALL;
							data[6][16] <= WALL;
							data[7][16] <= WALL;
							data[8][16] <= WALL;
							data[9][16] <= WALL;
							data[10][16] <= WALL;
							data[11][16] <= WALL;
							data[12][16] <= WALL;
							data[13][16] <= WALL;
							data[14][16] <= WALL;
							data[16][16] <= WALL;
							data[19][16] <= WALL;
							//Row 17
							data[1][17] <= TRAP;
							data[4][17] <= WALL;
							data[12][17] <= KEY;
							key_x = 12;
							key_y = 17;
							data[13][17] <= WALL;
							data[16][17] <= WALL;
							data[19][17] <= WALL;				
							//Row 18
							data[1][18] <= TRAP;
							data[4][18] <= WALL;
							data[16][18] <= WALL;
							data[19][18] <= WALL;	
							//Row 19
							data[1][19] <= TRAP;
							data[4][19] <= WALL;
							data[16][19] <= WALL;
							data[19][19] <= WALL;
							//Row 20
							data[1][20] <= TRAP;
							data[4][20] <= WALL;
							data[5][20] <= WALL;
							data[6][20] <= WALL;
							data[7][20] <= WALL;
							data[8][20] <= WALL;
							data[9][20] <= WALL;
							data[10][20] <= WALL;
							data[11][20] <= WALL;
							data[12][20] <= WALL;
							data[13][20] <= WALL;
							data[14][20] <= WALL;
							data[15][20] <= WALL;
							data[16][20] <= WALL;
							data[18][20] <= D_WALL;
							data[19][20] <= WALL;							
							//Row 21
							data[1][21] <= TRAP;
							data[8][21] <= WALL;
							data[19][21] <= WALL;							
							//Row 22
							data[1][22] <= TRAP;
							data[2][22] <= WALL;
							data[12][22] <= WALL;
							data[13][22] <= WALL;
							data[14][22] <= WALL;
							data[15][22] <= WALL;
							data[16][22] <= WALL;
							data[19][22] <= WALL;	
							
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 1'b1;
							current_state <= S_DRAW;
							end
				
				S_LOAD_2:	begin
							play <= 1'b0;
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= WALL;
								data[i][23] <= WALL;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= WALL;
								data[31][j] <= WALL;
								end
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 2'b10;
							current_state <= S_DRAW;
							end
							
				S_LOAD_3:	begin
							play <= 1'b0;
							for (i = 0; i < 32; i = i + 1)
								begin
								data[i][0] <= WALL;
								data[i][23] <= WALL;
								end
							
							for (j = 0; j < 24; j = j + 1)
								begin
								data[0][j] <= WALL;
								data[31][j] <= WALL;
								end
							counter_x <= 1'b0;
							counter_y <= 1'b0;
							stage <= 2'b11;
							current_state <= S_DRAW;
							end
							
				S_DRAW:		begin
							play <= 1'b0;
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
							if (direction == UP)
								begin
								//If player touches wall
								if (data[player_x / 5][(player_y - 1) / 5] == WALL |
									data[player_x / 5][(player_y - 1) / 5] == L_WALL |
									data[player_x / 5][(player_y - 1) / 5] == R_WALL |
									data[player_x / 5][(player_y - 1) / 5] == D_WALL)
									begin
									stop <= 1'b1;
									counter_x = 1'b0;
									counter_y = 1'b0;
									current_state = S_DRAW;
									end
								//If player touches trap	
								else if (data[player_x / 5][(player_y - 1) / 5] == TRAP)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								//If player touches goal
								else if (data[player_x / 5][(player_y - 1) / 5] == GOAL)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_CLEAR;
									end
								else if (data[player_x / 5][(player_y - 1) / 5] == KEY)
									begin
									current_state <= S_KEY;
									end
								end
								
							else if (direction == DOWN)
								begin
								if (data[player_x / 5][(player_y + 5) / 5] == WALL |
								    data[player_x / 5][(player_y + 5) / 5] == U_WALL |
									data[player_x / 5][(player_y + 5) / 5] == L_WALL |
									data[player_x / 5][(player_y + 5) / 5] == R_WALL)
									begin
									stop <= 1'b1;
									counter_x = 1'b0;
									counter_y = 1'b0;
									current_state = S_DRAW;
									end
									
								else if (data[player_x / 5][(player_y + 5) / 5] == TRAP)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[player_x / 5][(player_y + 5) / 5] == GOAL)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_CLEAR;
									end
								else if (data[player_x / 5][(player_y + 5) / 5] == KEY)
									begin
									current_state <= S_KEY;
									end
								end
							
							else if (direction == LEFT)
								begin
								if (data[(player_x - 1) / 5][player_y / 5] == WALL |
								    data[(player_x - 1) / 5][player_y / 5] == U_WALL |
									data[(player_x - 1) / 5][player_y / 5] == D_WALL |
									data[(player_x - 1) / 5][player_y / 5] == R_WALL)
									begin
									stop <= 1'b1;
									counter_x = 1'b0;
									counter_y = 1'b0;
									current_state = S_DRAW;
									end
									
								else if (data[(player_x - 1) / 5][player_y / 5] == TRAP)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[(player_x - 1) / 5][player_y / 5] == GOAL)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_CLEAR;
									end
								else if (data[(player_x - 1) / 5][player_y / 5] == KEY)
									begin
									current_state <= S_KEY;
									end
								end
							
							else if (direction == RIGHT)
								begin
								if (data[(player_x + 5) / 5][player_y / 5] == WALL | 
								    data[(player_x + 5) / 5][player_y / 5] == D_WALL |
									data[(player_x + 5) / 5][player_y / 5] == U_WALL |
									data[(player_x + 5) / 5][player_y / 5] == L_WALL)
									begin
									stop <= 1'b1;
									counter_x = 1'b0;
									counter_y = 1'b0;
									current_state = S_DRAW;
									end
									
								else if (data[(player_x + 5) / 5][player_y / 5] == TRAP)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									case(stage)
										2'b01:	current_state <= S_LOAD_1;
										2'b10:	current_state <= S_LOAD_2;
										2'b11:	current_state <= S_LOAD_3;
									endcase
									end
								else if (data[(player_x + 5) / 5][player_y / 5] == GOAL)
									begin
									stop <= 1'b1;
									reset <= 1'b1;
									current_state <= S_CLEAR;
									end
								else if (data[(player_x + 5) / 5][player_y / 5] == KEY)
									begin
									current_state <= S_KEY;
									end
								end
							else
								stop <= 1'b0;
							end
				S_KEY:      begin
							data[key_x_pos][key_y_pos] <= BLANK;
							data[goal_x_pos][goal_y_pos] <= GOAL;
							counter_x = 1'b0;
							counter_y = 1'b0;
							current_state = S_DRAW;
				            end
			endcase
		end
	assign row = counter_x;
	assign column = counter_y;
	assign colour = play ? PLAYER : data[row][column];
	assign x_out = play ? player_x : row * 5;
	assign y_out = play ? player_y : column * 5;
endmodule 