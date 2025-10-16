module Down_Counter(clk,rst,stop,seg_led_1,seg_led_2);
	input clk;
	input rst;
	input stop;
	
	output [8:0] seg_led_1;
	output [8:0] seg_led_2;	
	
	
	
	reg [4:0] count = 24;
	reg access = 1;
	reg [8:0] seg [9:0];
	reg [3:0] seg_data_1 = 1'd0;
	reg [3:0] seg_data_2 = 1'd0;
	
	wire stop_d;
	wire clk_1Hz;
	
	
	
	initial begin         // seg 为 g ~ a 对应赋值 
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
	
	
	// 调用按键消抖 
	debounce#(.N(1))u1 (                                           
                       .clk (clk),
                       .rst (rst),
                       .key ({stop}),
                       .key_pulse ({stop_d})
                       ); 
	
	//分频器模块，产生一个1Hz时钟信号		
   divide #(.WIDTH(32),.N(12000000)) c1 ( 
			.clk(clk),
			.rst_n(rst),                        //例化的端口信号都连接到定义好的信号
			.clkout(clk_1Hz)
			);	
	
	// 计数模块
	always @ (posedge clk_1Hz or negedge rst)
	begin
		if(!rst)
		begin
			count <= 24;
		end
		else begin
			if(access)	 
			begin
				if(count != 0)
					count <= count - 1;
				else
					count <= 24;
			end
		end
	end
	
	
	// 暂停模块
	always @ (posedge clk)
	begin
		if(stop_d)
			access <= ~access;
	end
	
	
	// 显示模块  （16进制转10进制）
	always @ (*)
	begin
		seg_data_1 <= count / 10;     // seg1显示count的十位部分 seg2显示个位部分 
		if(count % 10 == 0)
			seg_data_2 <= 0;
		else
			seg_data_2 <= count - 10*seg_data_1;
	end

	assign seg_led_1 = seg[seg_data_1];
	assign seg_led_2 = seg[seg_data_2];
	
endmodule