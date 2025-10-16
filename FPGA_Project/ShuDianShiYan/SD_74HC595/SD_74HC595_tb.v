`timescale 1us / 1ns
module SD_74HC595_tb();
	
	reg clk = 0;
	reg rst;
	reg DS;
	reg OE = 1;
	reg STCP = 1;
	reg SHCP = 1;
	wire [7:0] led;
	wire [8:0] Q;
	
	
	
	parameter CLK_PERIOD = 0.042;  //信号的定义，产生一个时钟信号j
	always # (CLK_PERIOD/2)  clk = ~ clk;
	
	initial begin
	rst = 1;
	clk = 0;
	OE = 1;
	STCP = 1;
	SHCP = 1;
	
	DS = 1;
	#1 SHCP = 0;
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 1
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 2
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 3
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 4
	
	DS = 0;
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 5
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 6
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 7
	#30000 SHCP = 1;
	#30000 SHCP = 0; // 8
	
	#30000 STCP = 0;
	#30000 STCP = 1;  
	
	#30000 OE = 0;
	
	#100000 rst = 0;
	#10000;
	$stop;
	
	
	
	end
	
	 SD_74HC595 u3 (
    .clk (   clk    ),
    .rst (   rst    ),
    .DS  (   DS     ),
    .OE  (   OE     ),
    .STCP(   STCP   ),
	 .SHCP(   SHCP   ),
	 .led (   led    ),
	 .Q   (   Q      )
	);
	
	
	
endmodule