module Debounce_II(clk,rst,key,key_pulse);
 
        parameter       N  =  1;                      //要消除的按键的数量
 
		  input             clk;
        input             rst;
        input 	 [N-1:0]   key;                        //输入的按键					
	     output  [N-1:0]   key_pulse;                  //按键动作产生的脉冲	
 
        reg     [N-1:0]   key_rst_pre;                //定义一个寄存器型变量存储上一个触发时的按键值
        reg     [N-1:0]   key_rst;                    //定义一个寄存器变量储存储当前时刻触发的按键值
 
        wire    [N-1:0]   key_edge;                   //检测到按键由高到低变化是产生一个高脉冲
 
        //利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
        always @(posedge clk  or  posedge rst)
          begin
             if (rst) begin
                 key_rst <= {N{1'b0}};                //初始化时给key_rst赋值全为0，{}中表示N个0
                 key_rst_pre <= {N{1'b0}};
             end
             else begin
                 key_rst <= key;                     //第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
                 key_rst_pre <= key_rst;             //非阻塞赋值。相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值
             end    
           end
 
        assign  key_edge = ~key_rst_pre & key_rst;//脉冲边沿检测。当key检测到下降沿时，key_edge产生一个时钟周期的高电平
 
        reg	[3:0]	  cnt;                       //产生延时所用的计数器，系统时钟100Hz，要延时0ms左右时间，至少需要3位计数器     
 
        //产生20ms延时，当检测到key_edge有效是计数器清零开始计数
        always @(posedge clk or posedge rst)
           begin
             if(rst)
                cnt <= 3'b0;
             else if(key_edge)
                cnt <= 3'b0;
             else
                cnt <= cnt + 1'b1;
             end  
 
        reg     [N-1:0]   key_sec_pre;                //延时后检测电平寄存器变量
        reg     [N-1:0]   key_sec;                    
 
 
        //延时后检测key，如果按键状态变低产生一个时钟的高脉冲。如果按键状态是高的话说明按键无效
        always @(posedge clk  or  posedge rst)
          begin
             if (rst) 
                 key_sec <= {N{1'b0}};                
             else if (cnt==3'b011)
                 key_sec <= key;  
          end
			 
        always @(posedge clk  or  posedge rst)
          begin
             if (rst)
                 key_sec_pre <= {N{1'b0}};
             else                   
                 key_sec_pre <= key_sec;             
          end      
        assign  key_pulse = (~key_sec_pre) & key_sec;     //key_sec 和 key_rst 原理一致 
		                                                    //key_sec 仅在cnt==3'b011 的那一个时钟周期触发 判断key是否为低电平

 
endmodule