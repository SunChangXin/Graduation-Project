module Counter_II(clk,rst,stop,seg_led,digtal_sw,count_out);
	input clk;
	input rst;
	input stop;

	
	output [7:0] seg_led;        //输出的数码管段选信号
	output reg [7:0] digtal_sw;  //输出的数码管位选信号
	output [5:0] count_out;
	
	reg [6:0] seg [9:0];
	reg [5:0] count = 2'd00;      //计数器
	reg [3:0] seg_data_1 = 1'd0;  //计数器个位
	reg [3:0] seg_data_2 = 1'd0;  //计数器十位
	reg [6:0] timer;              //计时器，用于产生1s延迟
	reg timer_access = 1'b1;      //允许计时控制
	reg select = 1'b1;                   //选择信号
	reg [3:0] bin;                //二进制数
	
	wire stop_d;
	
	
	
//调用按键消抖 	
	Debounce_II #(.N(1))u1 (                                           
                       .clk (clk),
                       .rst (rst),
                       .key ({stop}),
                       .key_pulse ({stop_d})
                       ); 	
	
	

//设置数码管段选信号
	initial begin                                    // seg 为 g ~ a 对应赋值 
		seg[0] = 8'h3f;                                  //7段显示数字  0
		seg[1] = 8'h06;                                  //7段显示数字  1
		seg[2] = 8'h5b;                                  //7段显示数字  2
		seg[3] = 8'h4f;                                  //7段显示数字  3
		seg[4] = 8'h66;                                  //7段显示数字  4
		seg[5] = 8'h6d;                                  //7段显示数字  5
		seg[6] = 8'h7d;                                  //7段显示数字  6
		seg[7] = 8'h07;                                  //7段显示数字  7
		seg[8] = 8'h7f;                                  //7段显示数字  8
		seg[9] = 8'h6f;                                  //7段显示数字  9
	end



//计数加计时							  
	always @ (posedge clk or posedge rst) begin
		if(rst)
		begin
			count <= 0;
			timer <= 0;
		end
	
		else 
		begin
			if(timer_access)
			begin
				if(timer != 7'd100)
				begin
					timer <= timer + 1'b1;
				end
				else
				begin
					timer <= 7'd0;
					count <= (count + 1) % 20;
				end
			end
			if(stop_d) timer_access <= ~timer_access;
		end
	end

//获取当前计数的个位与十位
	always @ (*) begin
		seg_data_1 <= count / 10;     // seg1显示count的十位部分 seg2显示个位部分 
		if(count % 10 == 0)
			seg_data_2 <= 0;
		else
			seg_data_2 <= count - 10*seg_data_1;
	end
	
//数码管位置显示
   always@(posedge clk or posedge rst) begin
      if(rst == 1'b1) begin
         digtal_sw <= 8'b1111_1111;    // 数码管全熄灭
         bin <= 0;                     // 复位bin为0
      end
      else begin
         select <= ~select;            // 每次时钟上升沿时，select取反（每10ms）
         if(select == 1'b0) begin
            digtal_sw <= 8'b1111_1110; // select为0时  个位显示在第8位数码管
            bin <= seg_data_2;               // 将seg2赋给bin
         end
         else begin
            digtal_sw <= 8'b1111_1101; // 当select为1时，十位显示在第7位数码管上
            bin <= seg_data_1;               // 将seg1赋给bin
         end
      end
   end
   
	assign seg_led = seg[bin];
   assign count_out = count;


endmodule