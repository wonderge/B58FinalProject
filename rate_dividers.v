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