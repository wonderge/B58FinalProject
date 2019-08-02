module game_control(clock, clock_30, start, player_x, player_y, direction, show_door, colour, x_out, y_out, stop, reset);
	input clock;
	input clock_30;
	input start;
	input [7:0] player_x;
	input [6:0] player_y;
	input [3:0] direction;
	input show_door;
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
	initial current_state = S_LOAD_3;
	reg play;
	wire [4:0] row;
	wire [4:0] column;
	
	reg [5:0] data [0:31][0:23];
	reg [1:0] stage;
	initial stage = 2'b11;
	
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
							
							//Row 1
							data[5][1] <= TRAP;
							data[6][1] <= WALL;
							data[7][1] <= WALL;
							data[8][1] <= WALL;
							goal_x <= 8;
							goal_y <= 1;
							data[9][1] <= WALL;
							data[10][1] <= WALL;
							data[11][1] <= WALL;
							data[12][1] <= WALL;
							data[13][1] <= WALL;
							data[14][1] <= WALL;
							data[15][1] <= WALL;
							data[16][1] <= WALL;
							data[17][1] <= WALL;
							data[18][1] <= WALL;
							data[19][1] <= WALL;
							data[20][1] <= WALL;
							data[21][1] <= WALL;
							data[22][1] <= WALL;
							data[23][1] <= WALL;
							data[24][1] <= WALL;
							data[25][1] <= WALL;
							data[26][1] <= WALL;
							data[27][1] <= WALL;
							data[28][1] <= WALL;
							data[29][1] <= WALL;
							data[30][1] <= WALL;
							//Row 2
							data[7][2] <= WALL;
							data[11][2] <= WALL;
							data[16][2] <= L_WALL;
							data[20][2] <= WALL;
							data[24][2] <= WALL;
							data[30][2] <= TRAP;
							//Row 3
							data[1][3] <= WALL;
							data[2][3] <= WALL;
							data[3][3] <= WALL;
							data[4][3] <= WALL;
							data[5][3] <= WALL;
							data[7][3] <= WALL;
							data[11][3] <= WALL;
							data[16][3] <= WALL;
							data[20][3] <= WALL;
							data[24][3] <= WALL;
							//Row 4
							data[1][4] <= TRAP;
							data[2][4] <= TRAP;
							data[3][4] <= TRAP;
							data[4][4] <= TRAP;
							data[5][4] <= WALL;
							data[7][4] <= WALL;
							data[11][4] <= WALL;
							data[16][4] <= WALL;
							data[20][4] <= WALL;
							data[24][4] <= WALL;
							//Row 5
							data[1][5] <= TRAP;
							data[4][5] <= TRAP;
							data[5][5] <= WALL;
							data[7][5] <= WALL;
							data[11][5] <= WALL;
							data[16][5] <= WALL;
							data[20][5] <= WALL;
							data[24][5] <= WALL;
							//Row 6
							data[1][6] <= TRAP;
							data[4][6] <= TRAP;
							data[5][6] <= WALL;
							data[7][6] <= WALL;
							data[11][6] <= WALL;
							data[15][6] <= WALL;
							data[16][6] <= WALL;
							data[20][6] <= WALL;
							data[24][6] <= WALL;
							//Row 7
							data[5][7] <= L_WALL;
							data[7][7] <= WALL;
							data[16][7] <= R_WALL;
							data[20][7] <= WALL;
							data[24][7] <= WALL;
							data[25][7] <= WALL;
							//Row 8
							data[4][8] <= TRAP;
							data[5][8] <= WALL;
							data[6][8] <= WALL;
							data[7][8] <= WALL;
							data[8][8] <= WALL;
							data[9][8] <= WALL;
							data[10][8] <= WALL;
							data[11][8] <= WALL;
							data[12][8] <= WALL;
							data[13][8] <= WALL;
							data[14][8] <= WALL;
							data[15][8] <= U_WALL;
							data[16][8] <= WALL;
							data[17][8] <= U_WALL;
							data[22][8] <= WALL;
							data[27][8] <= WALL;
							//Row 9
							data[4][9] <= TRAP;
							data[5][9] <= WALL;
							data[6][9] <= TRAP;
							data[13][9] <= WALL;
							data[16][9] <= WALL;
							data[18][9] <= WALL;
							data[19][9] <= WALL;
							data[20][9] <= WALL;
							data[21][9] <= WALL;
							data[22][9] <= WALL;
							data[23][9] <= WALL;
							data[24][9] <= WALL;
							data[25][9] <= WALL;
							data[26][9] <= WALL;
							data[27][9] <= WALL;
							data[28][9] <= WALL;
							data[29][9] <= WALL;
							data[30][9] <= D_WALL;
							//Row 10
							data[4][10] <= TRAP;
							data[5][10] <= WALL;
							data[6][10] <= TRAP;
							data[8][10] <= WALL;
							data[13][10] <= WALL;
							data[16][10] <= WALL;
							data[23][10] <= WALL;
							//Row 11
							data[4][11] <= TRAP;
							data[5][11] <= WALL;
							data[6][11] <= TRAP;
							data[8][11] <= WALL;
							data[13][11] <= WALL;
							data[16][11] <= WALL;
							data[23][11] <= WALL;
							//Row 12
							data[4][12] <= TRAP;
							data[5][12] <= WALL;
							data[6][12] <= TRAP;
							data[8][12] <= WALL;
							data[13][12] <= WALL;
							data[16][12] <= WALL;
							data[23][12] <= WALL;
							//Row 13
							data[4][13] <= TRAP;
							data[5][13] <= WALL;
							data[6][13] <= TRAP;
							data[8][13] <= WALL;
							data[13][13] <= WALL;
							data[16][13] <= WALL;
							data[23][13] <= WALL;
							//Row 14
							data[5][14] <= R_WALL;
							data[8][14] <= WALL;
							data[16][14] <= WALL;
							//Row 15
							data[1][15] <= WALL;
							data[2][15] <= WALL;
							data[3][15] <= WALL;
							data[4][15] <= WALL;
							data[5][15] <= WALL;
							data[6][15] <= WALL;
							data[7][15] <= WALL;
							data[8][15] <= WALL;
							data[9][15] <= WALL;
							data[10][15] <= WALL;
							data[11][15] <= WALL;
							data[12][15] <= WALL;
							data[13][15] <= WALL;
							data[14][15] <= WALL;
							data[15][15] <= WALL;
							data[16][15] <= WALL;
							data[17][15] <= TRAP;
							data[18][15] <= TRAP;
							data[19][15] <= TRAP;
							data[20][15] <= TRAP;
							data[21][15] <= TRAP;
							data[22][15] <= TRAP;
							data[23][15] <= TRAP;
							data[24][15] <= WALL;
							data[25][15] <= TRAP;
							data[26][15] <= TRAP;
							data[27][15] <= TRAP;
							data[28][15] <= TRAP;
							data[29][15] <= TRAP;
							//Row 16
							data[11][16] <= R_WALL;
							//Row 17
							data[3][17] <= WALL;
							data[4][17] <= WALL;
							data[5][17] <= WALL;
							data[6][17] <= WALL;
							data[7][17] <= WALL;
							data[8][17] <= WALL;
							data[9][17] <= WALL;
							data[10][17] <= WALL;
							data[11][17] <= WALL;
							data[13][17] <= WALL;
							data[14][17] <= WALL;
							data[15][17] <= WALL;
							data[16][17] <= WALL;
							data[17][17] <= WALL;
							data[18][17] <= WALL;
							data[19][17] <= WALL;
							data[20][17] <= WALL;
							data[21][17] <= WALL;
							data[22][17] <= WALL;
							data[23][17] <= WALL;
							data[25][17] <= WALL;
							data[26][17] <= WALL;
							data[27][17] <= WALL;
							data[28][17] <= WALL;
							data[29][17] <= WALL;
							data[30][17] <= WALL;
							//Row 18
							data[8][18] <= WALL;
							data[26][18] <= WALL;
							//Row 19
							data[1][19] <= WALL;
							data[17][19] <= WALL;
							//Row 20
							data[1][20] <= WALL;
							data[2][20] <= WALL;
							data[3][20] <= WALL;
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
							data[17][20] <= WALL;
							data[18][20] <= WALL;
							data[19][20] <= WALL;
							data[20][20] <= WALL;
							data[21][20] <= WALL;
							data[22][20] <= WALL;
							data[23][20] <= WALL;
							data[24][20] <= WALL;
							data[25][20] <= WALL;
							data[26][20] <= WALL;
							data[27][20] <= WALL;
							data[28][20] <= WALL;
							data[29][20] <= WALL;
							//Row 21
							data[29][21] <= WALL;
							//Row 22
							data[29][22] <= WALL;
							data[30][22] <= KEY;
							key_x <= 30;
							key_y <= 22;
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
								
							//Row 1
							data[13][1] = WALL;
							data[19][1] = WALL;
							goal_x = 20;
							goal_y = 1;
							data[21][1] = TRAP;
							data[22][1] = WALL;
							data[23][1] = TRAP;
							data[24][1] = TRAP;
							data[25][1] = TRAP;
							data[26][1] = WALL;
							data[27][1] = TRAP;
							data[28][1] = TRAP;
							data[29][1] = TRAP;
							data[30][1] = WALL;
							//Row 2
							data[1][2] = WALL;
							data[2][2] = WALL;
							data[3][2] = WALL;
							data[4][2] = WALL;
							data[5][2] = WALL;
							data[6][2] = WALL;
							data[7][2] = WALL;
							data[8][2] = WALL;
							data[9][2] = WALL;
							data[10][2] = WALL;
							data[11][2] = WALL;
							data[13][2] = WALL;
							data[16][2] = WALL;
							data[19][2] = WALL;
							data[22][2] = WALL;
							data[26][2] = WALL;
							data[30][2] = WALL;
							//Row 3
							data[14][3] = WALL;
							data[19][3] = WALL;
							data[22][3] = WALL;
							data[26][3] = WALL;
							data[30][3] = WALL;
							//Row 4
							data[2][4] = WALL;
							data[3][4] = WALL;
							data[4][4] = WALL;
							data[5][4] = WALL;
							data[6][4] = WALL;
							data[7][4] = WALL;
							data[8][4] = WALL;
							data[9][4] = WALL;
							data[10][4] = WALL;
							data[11][4] = WALL;
							data[19][4] = WALL;
							data[22][4] = WALL;
							data[26][4] = WALL;
							data[30][4] = WALL;
							//Row 5
							data[3][5] = R_WALL;
							data[7][5] = R_WALL;
							data[12][5] = WALL;
							data[18][5] = TRAP;
							data[21][5] = U_WALL;
							data[22][5] = WALL;
							data[26][5] = WALL;
							data[30][5] = WALL;
							//Row 6
							data[1][6] = WALL;
							data[2][6] = WALL;
							data[3][6] = WALL;
							data[4][6] = D_WALL;
							data[5][6] = WALL;
							data[7][6] = WALL;
							data[9][6] = WALL;
							data[10][6] = WALL;
							data[12][6] = WALL;
							data[13][6] = WALL;
							data[14][6] = WALL;
							data[15][6] = WALL;
							data[16][6] = WALL;
							data[17][6] = WALL;
							data[18][6] = WALL;
							data[22][6] = WALL;
							data[26][6] = WALL;
							data[29][6] = WALL;
							data[30][6] = WALL;
							//Row 7
							key_x = 1;
							key_y = 7;
							data[1][7] = KEY;
							data[2][7] = WALL;
							data[3][7] = TRAP;
							data[5][7] = WALL;
							data[9][7] = WALL;
							data[10][7] = WALL;
							data[12][7] = TRAP;
							data[13][7] = TRAP;
							data[14][7] = TRAP;
							data[15][7] = TRAP;
							data[16][7] = TRAP;
							data[17][7] = TRAP;
							data[18][7] = WALL;
							data[22][7] = WALL;
							data[30][7] = WALL;
							//Row 8
							data[2][8] = WALL;
							data[3][8] = TRAP;
							data[5][8] = WALL;
							data[6][8] = WALL;
							data[8][8] = WALL;
							data[9][8] = WALL;
							data[10][8] = WALL;
							data[18][8] = WALL;
							data[22][8] = WALL;
							data[26][8] = WALL;
							data[30][8] = WALL;
							//Row 9
							data[2][9] = WALL;
							data[3][9] = TRAP;
							data[6][9] = TRAP;
							data[10][9] = WALL;
							data[18][9] = WALL;
							data[22][9] = WALL;
							data[26][9] = WALL;
							data[30][9] = WALL;
							//Row 10
							data[2][10] = WALL;
							data[3][10] = TRAP;
							data[6][10] = TRAP;
							data[10][10] = WALL;
							data[16][10] = WALL;
							data[18][10] = WALL;
							data[22][10] = WALL;
							data[25][10] = WALL;
							data[26][10] = WALL;
							data[30][10] = WALL;
							//Row 11
							data[2][11] = WALL;
							data[3][11] = WALL;
							data[10][11] = WALL;
							data[12][11] = WALL;
							data[18][11] = WALL;
							data[22][11] = L_WALL;
							data[26][11] = WALL;
							data[30][11] = WALL;
							//Row 12
							data[3][12] = WALL;
							data[10][12] = WALL;
							data[11][12] = D_WALL;
							data[18][12] = WALL;
							data[22][12] = WALL;
							data[26][12] = WALL;
							data[30][12] = WALL;
							//Row 13
							data[3][13] = WALL;
							data[10][13] = WALL;
							data[13][13] = WALL;
							data[18][13] = WALL;
							data[22][13] = WALL;
							data[26][13] = WALL;
							data[30][13] = WALL;
							//Row 14
							data[3][14] = WALL;
							data[10][14] = WALL;
							data[18][14] = WALL;
							data[19][14] = TRAP;
							data[20][14] = TRAP;
							data[21][14] = TRAP;
							data[22][14] = WALL;
							data[26][14] = WALL;
							data[30][14] = WALL;
							//Row 15
							data[10][15] = WALL;
							data[18][15] = WALL;
							data[19][15] = TRAP;
							data[20][15] = TRAP;
							data[21][15] = TRAP;
							data[22][15] = WALL;
							data[26][15] = WALL;
							data[30][15] = WALL;
							//Row 16
							data[6][16] = R_WALL;
							data[10][16] = WALL;
							data[18][16] = WALL;
							data[19][16] = WALL;
							data[20][16] = WALL;
							data[21][16] = WALL;
							data[22][16] = WALL;
							data[26][16] = WALL;
							data[30][16] = WALL;
							//Row 17
							data[2][17] = WALL;
							data[3][17] = WALL;
							data[4][17] = WALL;
							data[5][17] = U_WALL;
							data[10][17] = WALL;
							data[17][17] = WALL;
							data[18][17] = WALL;
							data[22][17] = R_WALL;
							data[26][17] = R_WALL;
							data[30][17] = WALL;
							//Row 18
							data[2][18] = TRAP;
							data[6][18] = WALL;
							data[10][18] = WALL;
							data[11][18] = WALL;
							data[13][18] = WALL;
							data[14][18] = WALL;
							data[15][18] = WALL;
							data[16][18] = WALL;
							data[17][18] = WALL;
							data[18][18] = WALL;
							data[22][18] = WALL;
							data[26][18] = WALL;
							data[30][18] = WALL;
							//Row 19
							data[2][19] = TRAP;
							data[6][19] = WALL;
							data[10][19] = WALL;
							data[16][19] = TRAP;
							data[17][19] = TRAP;
							data[18][19] = WALL;
							data[21][19] = WALL;
							data[22][19] = WALL;
							data[26][19] = WALL;
							data[29][19] = WALL;
							data[30][19] = WALL;
							//Row 20
							data[2][20] = TRAP;
							data[6][20] = WALL;
							data[10][20] = WALL;
							data[18][20] = WALL;
							data[19][20] = WALL;
							data[21][20] = WALL;
							data[22][20] = WALL;
							data[23][20] = WALL;
							data[24][20] = WALL;
							data[25][20] = WALL;
							data[26][20] = WALL;
							data[27][20] = WALL;
							data[29][20] = WALL;
							data[30][20] = WALL;
							//Row 21
							data[2][21] = TRAP;
							data[6][21] = WALL;
							data[10][21] = WALL;
							data[11][21] = WALL;
							data[16][21] = WALL;
							data[18][21] = WALL;
							data[19][21] = WALL;
							data[23][21] = WALL;
							data[27][21] = WALL;
							//Row 22
							data[6][22] = WALL;
							data[10][22] = WALL;
							data[16][22] = WALL;
							data[21][22] = R_WALL;
							data[25][22] = R_WALL;
							data[29][22] = R_WALL;
							
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
									counter_x <= 1'b0;
									counter_y <= 1'b0;
									current_state <= S_DRAW;
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
								//If player gets key
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
									counter_x <= 1'b0;
									counter_y <= 1'b0;
									current_state <= S_DRAW;
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
									counter_x <= 1'b0;
									counter_y <= 1'b0;
									current_state <= S_DRAW;
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
									counter_x <= 1'b0;
									counter_y <= 1'b0;
									current_state <= S_DRAW;
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
							counter_x <= 1'b0;
							counter_y <= 1'b0;
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