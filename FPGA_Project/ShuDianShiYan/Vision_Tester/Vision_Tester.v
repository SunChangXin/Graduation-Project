module Vision_Tester(clk,rst,upper,lower,left,right,confirm,row,R_col,G_col);
	input clk;

	input rst;    // BTN0为启动键，按下后8×8点阵显示视力为0.8的视标（方向随机），同时数码管DISP3~DISP2显示与视标对应的视力
	
	input upper;  // BTN6~BTN3分别对应视标“上”、“下”、“左”、“右”四个开口方向
	input lower;
	input left;
	input right;
	
	input confirm; // 确认键 BTN1
	
	
	
	output [7:0] row;   // 点阵 行   低电平有效
	output [7:0] R_col; // 点阵 红列 高电平有效
	output [7:0] G_col;
	
	wire clk_1Hz,clk_10MHz;
	
	assign G_col = 0;
	
	
	
	
	
	
	
	
	//按键消抖模块 
	key_debounce#(.N(5)) Debounce (                                           
                       .clk (clk),
                       .rst (rst),
                       .key ({upper,lower,left,right,confirm}),
                       .key_pulse ({upper_d,lower_d,left_d,right_d,confirm_d})
                       ); 	
							  
	//分频器模块，产生一个1Hz时钟信号,一个10MHz的时钟信号		
   frequency_divider #(.WIDTH(32),.N(1000000)) c1 ( 
			.clk(clk),
			.rst_n(rst),                        //例化的端口信号都连接到定义好的信号
			.clk_out(clk_1Hz)
			);
	
   frequency_divider #(.WIDTH(32),.N(1)) c2 (         
			.clk(clk),
			.rst_n(rst),                        //例化的端口信号都连接到定义好的信号
			.clk_out(clk_10MHz)
			);	
	
	//点阵显示模
	

	lattice u0 (
				.clk1(clk_1Hz),
				.clk2(clk_10MHz),
				.rst(rst),
				.row(row),
				.col(R_col)
	        );
	
	

	
	
	
	
	
	
	
	
	
	
	
	
endmodule