module Counter(clk,rst,btn1,btn2,seg_led_1,seg_led_2);
	input clk;
	input rst;
	input btn1; // 加1按键
	input btn2; // 减1按键
	
	output [8:0] seg_led_1;
	output [8:0] seg_led_2;
	
	wire btn1_d;
	wire btn2_d;
	
	reg [8:0] seg [9:0];
	reg [5:0] count = 2'd00;
	reg [3:0] seg_data_1 = 1'd0;
	reg [3:0] seg_data_2 = 1'd0;
	

initial begin
	 seg[0] = 9'h3f;      //对存储器中第一个数赋值9'b00_0011_1111,相当于共阴极接地，DP点变低不亮，7段显示数字  0
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


	debounce#(.N(2))u1 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (rst),
                       .key ({btn1,btn2}),
                       .key_pulse ({btn1_d,btn2_d})
                       ); 

always @ (posedge clk or negedge rst)
begin
	if(!rst)         // 复位置0
		count <= 0;
		
	else
	begin
		if(btn1_d)                    // 加一 与 减一
			count <= (count + 1) % 20;
		if(btn2_d)
			count <= (count - 1) % 20;
	
		seg_data_1 <= count / 10;     // seg1显示count的十位部分 seg2显示个位部分 
		if(count % 10 == 0)
			seg_data_2 <= 0;
		else
			seg_data_2 <= count - 10*seg_data_1;
	end
end

assign seg_led_1 = seg[seg_data_1];
assign seg_led_2 = seg[seg_data_2];


endmodule
