module led_display(                              //数码管扫描
     input                   clk       ,  
     input                   rst_n     ,         // 复位信号
     input         [7:0]     vision_bcd,         // 2位数码管要显示的数值
	  input                   ctr_signal,
     output        [7:0]     seg_sel   ,         // 数码管位选 
     output        [7:0]     seg_led             // 数码管段选
);
   
	reg [2:0] sel_r         ; 			//数码管位选
	reg [7:0] seg_led_r = 0 ;  
	reg [3:0] data_tmp      ;		   //数据缓存 
	
	wire      clkout        ;	
	
	display_divider #(.WIDTH(32),.N(10)) u10(//分频10MHz
											.clk(clk),
											.rst_n(rst_n),
											.clkout(clkout)
	);
	
	//3位循环移位寄存器
	always @ (posedge clkout or posedge rst_n)
	begin
		if(rst_n)
		begin
			sel_r <= 3'b001;
		end
	
		else if(sel_r == 3'b100)
			sel_r <= 3'b001;
	
		else
			sel_r <=  sel_r << 1;
	 
	end

	
	always@(*)
	begin
		case(sel_r)
			3'b001:data_tmp  =  vision_bcd[7   :  4];  // 个位
			3'b010:data_tmp  =  vision_bcd[3   :  0];  // 十位
			3'b100:data_tmp  =  4'b1111             ;  // 特殊符号
			default:data_tmp =  4'b0000             ;
		endcase
	end
	
   //控制数码管段选信号，显示字符 
   always @ (*) 
	begin
	     if(data_tmp==vision_bcd[7   :  4]&&sel_r==3'b001) begin
			case (data_tmp)
            4'd0 : seg_led_r <= 8'h3f; //显示数字 0
            4'd1 : seg_led_r <= 8'h06; //显示数字 1
            4'd2 : seg_led_r <= 8'h5b; //显示数字 2
            4'd3 : seg_led_r <= 8'h4f; //显示数字 3
            4'd4 : seg_led_r <= 8'h66; //显示数字 4
            4'd5 : seg_led_r <= 8'h6d; //显示数字 5
            4'd6 : seg_led_r <= 8'h7d; //显示数字 6
            4'd7 : seg_led_r <= 8'h07; //显示数字 7
            4'd8 : seg_led_r <= 8'h7f; //显示数字 8
            4'd9 : seg_led_r <= 8'h6f; //显示数字 9
            4'hf : seg_led_r <= 8'b00000000; //f时 不显示任何字符
            default: 
                   seg_led_r <= 8'b00000000;
			endcase
		  end
		  
		  if(data_tmp==vision_bcd[3   :  0]&&sel_r==3'b010) begin
			case (data_tmp)
            4'd0 : seg_led_r <= 8'hbf; //显示数字 0.
            4'd1 : seg_led_r <= 8'h86; //显示数字 1.
            4'hf : seg_led_r <= 8'b00000000; //f时 不显示任何字符
            default: 
                   seg_led_r <= 8'b00000000;
        endcase	
		 end
		 if((data_tmp==4'b1111)&&sel_r==3'b100) begin
		 if(ctr_signal==1)
		   seg_led_r <= 8'b01000000;     //显示"-"
		 else
			seg_led_r <= 8'b00000000;
		  end   
		  
   end

		assign seg_sel = ~sel_r;     //低电平点亮
		assign seg_led = seg_led_r;  //高电平点亮
		
		

endmodule