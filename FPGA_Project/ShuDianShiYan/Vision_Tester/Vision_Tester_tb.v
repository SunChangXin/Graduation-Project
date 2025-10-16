`timescale 1us / 1ns
module Vision_Tester_tb();
	
reg   clk;
reg   BTN0;


wire  [7:0]  row_out;
wire  [7:0]  col_out;

parameter CLK_PERIOD = 0.1;  //信号的定义，产生一个时钟信号j
always # (CLK_PERIOD/2)  clk = ~ clk;







initial begin
	clk = 0;
	#1 BTN0 = 1;
	#1 BTN0 = 0;
	#8000000;
	$stop;
	
	
	
end











Vision_Tester  u3 (
    .clk(    clk    ),
    .rst(   BTN0    ),
    .upper(       ),
    .lower(    ),
    .left(    ),
	 .right(      ),
	 .confirm(),
	 .row(row_out),
	 .R_col(col_out)
);




endmodule