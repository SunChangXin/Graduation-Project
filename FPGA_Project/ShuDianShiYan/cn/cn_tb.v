`timescale 1us / 1ns
module cn_tb();
	
reg   clk;
reg   BTN0;
reg   BTN7;

wire  [7:0]  seg_sel;//(片选/位选)
wire  [6:0]  seg_led;//(段选)
wire  [7:0]  cout;


parameter CLK_PERIOD = 10;  //信号的定义，产生一个时钟信号j
always # (CLK_PERIOD/2)  clk = ~ clk;	

initial begin
	clk = 0;
	BTN0=1	;
	BTN7=1	;
	#2
	BTN0 = 0 ;	
	BTN7 = 0 ;		        //BTN7 = 1 ，解除复位

	#1000   press_BTN0;    //按一下BTN0键 暂停
	
   
	
	#5000   press_BTN0;    //按一下BTN0键 开始计数
	
	#1000   BTN7 = 1 ; //按下复位 清零
	#1000   BTN7 = 0;
	
	#5000   press_BTN0;     //再按一下BTN0键 暂停

	#1000   press_BTN0;    //再按一下BTN0键 开始计数


	

	#10000000 	
	$stop;
end


cn  u3 (
    .clk                     ( clk       ),
    .bnt0                     ( BTN7      ),
    .bnt7                    ( BTN0      ),
    .cat               ( seg_sel   ),
    .seg                 ( seg_led   ),
	 .count_out               ( cout      )
);

task press_BTN0;
	begin
			
			# (1*CLK_PERIOD )  BTN0 = 0; //抖动行为
			# (2*CLK_PERIOD )  BTN0 = 1; //抖动行为	
			# (10*CLK_PERIOD)  BTN0 = 1; //长时间的有效按键
			# (1*CLK_PERIOD )  BTN0 = 0;
		   #100;
	end
endtask


endmodule