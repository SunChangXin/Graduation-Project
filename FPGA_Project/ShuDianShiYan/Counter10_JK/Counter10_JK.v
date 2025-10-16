module Counter10_JK(clk,rst,set,q,seg_led);
	input clk;
	input rst;
	input set;
	
	output [3:0] q;
	output [8:0] seg_led;
	
	reg [8:0] seg [9:0];
	
	
	
	
	
	//分频器模块，产生一个1Hz时钟信号	
	divide #(.WIDTH(32),.N(12000000)) c1 ( 
			.clk(clk),
			.rst_n(rst),                        //例化的端口信号都连接到定义好的信号
			.clkout(clk_1Hz)
			);	
			
			
	// 计数器模块
	JK_ff f0 (
					.clk(clk_1Hz),
					.set_n(set),
					.rst_n(rst),
					.j(1'b1),
					.k(1'b1),
					.q(q[0])
					);
	
	JK_ff f1 (
					.clk(q[0]),
					.set_n(set),
					.rst_n(rst),
					.j(~q[3]),
					.k(~q[3]),
					.q(q[1])
					);
	
	JK_ff f2 (
					.clk(q[1]),
					.set_n(set),
					.rst_n(rst),
					.j(1'b1),
					.k(1'b1),
					.q(q[2])
					);	
	
	JK_ff f3 (
					.clk(q[0]),
					.set_n(set),
					.rst_n(rst),
					.j(q[1]&q[2]),
					.k(q[3]),
					.q(q[3])
					);		
	
	// 数码管显示模块
	initial begin           // seg 为 g ~ a 对应赋值 
	 seg[0] = 9'h3f;                                  //7段显示数字  0
	 seg[1] = 9'h06;                                  //7段显示数字  1
	 seg[2] = 9'h5b;                                  //7段显示数字  2
	 seg[3] = 9'h4f;                                  //7段显示数字  3
	 seg[4] = 9'h66;                                  //7段显示数字  4
	 seg[5] = 9'h6d;                                  //7段显示数字  5
	 seg[6] = 9'h7d;                                  //7段显示数字  6
	 seg[7] = 9'h07;                                  //7段显示数字  7
	 seg[8] = 9'h7f;                                  //7段显示数字  8
	 seg[9] = 9'h6f;                                  //7段显示数字  9

	end
	
	assign seg_led = seg[q];
	
endmodule