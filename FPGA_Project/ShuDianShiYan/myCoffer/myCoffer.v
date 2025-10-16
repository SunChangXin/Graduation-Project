module myCoffer (SwitchInput,clk,open,reset,red,pswd_set,green,seg_led_1,seg_led_2);
 
	    input [3:0] SwitchInput;               // 开发板4位开关的输入						
	    input clk;                           
	    input open;                            // 验证按键
       input reset;                           // 重置按键
       input pswd_set;                        // 重置密码确认按键

	
   	  output red;                            // 三色灯，对应低电平点亮
    	  output green;                          
    	  output [8:0] seg_led_1;                // 7段数码管输出，显示输入的密码
        output reg [8:0] seg_led_2;            // 7段数码管输出，显示剩余试错次数
        
		  
        reg [8:0] seg [15:0];       // 定义一个9*16的存储器（每个9位，能存储16个），初始化点亮数码管输出
		  reg change_pswd;            // 是否允许修改密码变量
		  reg access_reg;             // 绿灯开关
		  reg alert_reg;              // 红灯开关
		  reg lock;                   // 控制密码箱上锁变量
		  reg [2:0] count;            // 试错次数
		  
		  reg [3:0] pswd_input;  
		  reg [3:0] password = 4'b0111;  // 密码
		  
		  localparam ALLOWED = 3'd4;     // 允许试错次数
		  
		  wire open_d;                   // 验证按键
		  wire pswd_set_d;               // 重置密码确认按键
		  
 
 
        initial                                                        
                                                                        
 begin                                     // 用开关输入密码
         seg[0] = 9'h3f;                                          
	      seg[1] = 9'h06;                                         
	      seg[2] = 9'h5b;                                           
	      seg[3] = 9'h4f;                                          
	      seg[4] = 9'h66;                                          
	      seg[5] = 9'h6d;                                          
	      seg[6] = 9'h7d;                                           
	      seg[7] = 9'h07;                                          
	      seg[8] = 9'h7f;                                           
	      seg[9] = 9'h6f;                                           
			seg[10] = 9'h77;                                          
	      seg[11] = 9'h7c;                                           
	      seg[12] = 9'h39;                                           
	      seg[13] = 9'h5e;                                         
	      seg[14] = 9'h79;                                           
	      seg[15] = 9'h71;                                           
 end  
        assign seg_led_1 = seg[SwitchInput];   // 显示输入的密码
		  
		 
		debounce#(.N(2))u1 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (reset),
                       .key ({open,pswd_set}),
                       .key_pulse ({open_d,pswd_set_d})
                       ); 
							  
							  
		  
		  always @ (posedge clk)
begin
          pswd_input <= SwitchInput;         // 获取开关输入的密码
			 seg_led_2 <= seg[ALLOWED - count]; // 实时显示剩余试错次数
			 
          if(~reset)	   
			   begin
			     access_reg <= 1'b1;  // 灯熄灭
			     alert_reg <= 1'b1;
				  count <= 3'b000;     // 重置试错次数
				  lock <= 1'b0;        // 重置上锁变量
				  change_pswd <= 1'b0; // 重置允许修改密码变量
				  seg_led_2 <= seg[ALLOWED]; 
			   end
			 
		    else
			 begin
			   if(open_d)            // 按下验证按键
			   begin
				
			     if(~lock)
				  begin
			       if(pswd_input == password)   
				    begin
		            access_reg <= 1'b0; // 绿灯亮
			  	      alert_reg <= 1'b1;
				      count <= 3'b000;
				  	   change_pswd <= 1'b1; // 允许修改密码
			       end
				  
				    if(pswd_input != password)	
			       begin
			         access_reg <= 1'b1; // 红灯亮
			         alert_reg <= 1'b0;
						count <= count + 1;  // 试错次数加1
			       end
					 
			     end
		
			   end
				
				if(count == ALLOWED)  lock <= 1'b1; 
				
				if(pswd_set_d && change_pswd)  password <= pswd_input;    // 按下了重置密码确认按键
				
			 end	
							
end

        assign red = (alert_reg && ~lock); 
		  assign green = (access_reg && ~lock); 

endmodule
