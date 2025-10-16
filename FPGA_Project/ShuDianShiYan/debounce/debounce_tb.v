`timescale 1ms/1us  
module debounce_tb();
	reg key;
	reg clk;
	reg rst;
	
	wire key_pulse; 
	
	always #5 clk = ~clk; 
	
	initial begin
		clk = 0;
		rst = 0;
		#5 rst = 1;
		key = 1;
		#5 key = 0; 
		#20 key = 1;
		#5 key = 0;
		#50 key = 1;
		#100;
		$stop;

	end
	
	debounce  u1 (                               
                       .clk (clk),
                       .rst (rst),
                       .key (key),
                       .key_pulse (key_pulse)
                       );
	
	
	
	
endmodule