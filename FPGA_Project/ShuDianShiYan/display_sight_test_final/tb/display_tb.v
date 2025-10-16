`timescale 1ns / 1ps
module display_tb();
reg   clk;             //模拟系统时钟
reg   rst;             //模拟复位信号
wire [7:0] col_pin;    //列引脚输出 （高电平有效）
wire [7:0] row_pin;    //行引脚输出 （低电平有效）

wire [7:0] seg_sel;    //数码管片选
wire [7:0] seg_led;    //数码管段选

reg Key_RESTART;
reg Left;    //左键
reg Right;   //右键
reg Down;    //下键
reg Up;      //上键

//生成一个时钟信号,周期为1us,频率为1MHz
parameter CLK_PERIOD = 1000 ;  
always # (CLK_PERIOD/2)  clk = ~ clk;	


	initial
	begin
		clk = 0 ;
		rst = 1 ;
		Key_RESTART = 0;
		Left = 0;
		Right = 0;
		Down = 0;
		Up = 0;
		#1000
		rst = 0;  //复位信号为0，解除复位状态
	
		#2000
		Key_RESTART = 1;//启动键按下显示0.8视标方向
		#2000
		Key_RESTART = 0;
	
		#50000
		Up = 1;
		#1000
		Up = 0;   //错误 到0.6视标
	
		
	
		#100000
		Up = 1;
		#1000
		Up = 0;   //错误 到0.4视标
		
		#100000
		Up = 1;
		#1000
		Up = 0;   //错误 到0.2视标
		
		#100000
		Up = 1;
		#1000
		Up = 0;   //错误 到0.1视标
		
		#100000
		Up = 1;
		#1000
		Up = 0;   //错误 到X视标
		
		#100000
		Up = 1;
		#1000
		Up = 0;   //错误 到X视标
		
		#1000000
		
		rst = 1 ;
		#1000
		rst = 0;
		#10000
		Key_RESTART = 1; // 重置
		#2000
		Key_RESTART = 0;
	
		
		#10000000
		Down = 1;
		#2000
		Down = 0;
		
	   #100000
		Down = 1;
		#2000
		Down = 0;
		
		#100000
		Right = 1;
		#1000
		Right = 0;
		
		#1000000
		rst = 1;  //复位信号为1，复位状态
		#5000
		$stop;
end
display dipl_tb (
           .sys_clk(clk),
			  .sys_rst(rst),
           .col_pin(col_pin),
           .row_pin(row_pin),
           .seg_sel(seg_sel),
			  .seg_led(seg_led),
			  .KeyRESTART(Key_RESTART),
			  .KeyLeft(Left),
			  .KeyRight(Right),
			  .KeyDown(Down),
			  .Keyup(Up)
);
endmodule