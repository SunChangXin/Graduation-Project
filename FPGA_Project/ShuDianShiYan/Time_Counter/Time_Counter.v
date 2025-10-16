module Time_Counter(clk,rst_n,stop_n,seg_led_1,seg_led_2);
	input clk;
	input rst_n;
	input stop_n;

	
	output [8:0] seg_led_1;
	output [8:0] seg_led_2;
	
	wire stop_d;
	
	reg [8:0] seg [9:0];
	reg [4:0] count = 2'd00;
	reg [3:0] seg_data_1 = 1'd0;
	reg [3:0] seg_data_2 = 1'd0;
	
	reg [24:0] timer_1;
	reg [24:0] timer_2;
	reg timer_access = 1'b1;
	parameter   CNT_NUM = 3464;
	

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


	debounce#(.N(1))u1 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (rst_n),
                       .key ({stop_n}),
                       .key_pulse ({stop_d})
                       ); 
							  
							  
							  
always @ (posedge clk or negedge rst_n)		
begin 
	if(!rst_n) timer_1 <= 13'd0;
	else 
	begin
		if(timer_1 >= CNT_NUM-1) timer_1 <= 1'b0;
      else timer_1 <= timer_1 + 1'b1;
   end              
	
end


					  
always @ (posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
			count <= 2'd00;
			timer_2 <= 13'd0;
	end
	
	else begin
		if(timer_access)
		begin
			if(timer_1 == CNT_NUM - 1) 
			begin
				if(timer_2 < CNT_NUM)
				begin
					timer_2 <= timer_2 + 1'b1;
				end
				else
				begin
					timer_2 <= 1'b0;
					count <= (count + 1) % 20;
				end
			end
		end
	
		if(stop_d) timer_access <= ~timer_access;
	
	end
	
end

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