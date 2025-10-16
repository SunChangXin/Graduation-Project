module Adder_4(setadd_1,setadd_2,SwitchCin,rst,clk,calculate,seg_led_1,seg_led_2);
    input setadd_1;
	 input setadd_2;
	 input [3:0] SwitchCin;
	 input rst;
	 input clk;
	 input calculate;

    output reg [8:0] seg_led_1;
	 output reg [8:0] seg_led_2;
	 
	 
	 reg [8:0] seg [15:0];  
	 
	 reg [3:0] container_1, container_2; 
	 
	 wire [4:0] sum_reg;
	 
	 wire [4:0] Cout_reg;
	 
        initial                                                        
                                                                        
 begin                                    
         seg[0]  = 9'h3f;                                          
	      seg[1]  = 9'h06;                                         
	      seg[2]  = 9'h5b;                                           
	      seg[3]  = 9'h4f;                                          
	      seg[4]  = 9'h66;                                          
	      seg[5]  = 9'h6d;                                          
	      seg[6]  = 9'h7d;                                           
	      seg[7]  = 9'h07;                                          
	      seg[8]  = 9'h7f;                                           
	      seg[9]  = 9'h6f;                                           
			seg[10] = 9'h77;                                          
	      seg[11] = 9'h7c;                                           
	      seg[12] = 9'h39;                                           
	      seg[13] = 9'h5e;                                         
	      seg[14] = 9'h79;                                           
	      seg[15] = 9'h71;                                           
 end  
 
 
 
    debounce#(.N(3))u0 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (rst),
                       .key ({setadd_1,setadd_2,calculate}),
                       .key_pulse ({add_1_d,add_2_d,calculate_d})
                       ); 
   

	always @ (posedge clk or negedge rst)
	begin

		if(!rst)
		begin
		   
			container_1 <= 0;
			container_2 <= 0;
			seg_led_1 <= seg[0];
			seg_led_2 <= seg[0];
		end 
  
		else
		begin
			if(add_1_d)
			begin
				container_1 <= SwitchCin;
				seg_led_1 <= seg[SwitchCin];
			end
  
			if(add_2_d)
			begin
				container_2 <= SwitchCin;
				seg_led_2 <= seg[SwitchCin];
			end
	
			if(calculate_d)
			begin
				seg_led_1 <= seg[Cout_reg[3]];
				seg_led_2 <= seg[sum_reg];	
			end
  
		end
  
	end
  
  
	my_adder_4 u5 (
                .a(container_1),
					 .b(container_2),
					 .Cout(Cout_reg),
					 .Sum(sum_reg)
                );
			 
					 
endmodule

