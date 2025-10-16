`timescale 1us / 1ns
module random_num(
    input 				clk   ,
    input 				rst  	,
    input 				en_RESTARTdown  		,//使能端en
	 input            en_direction, 
    output reg	  [2:0] 	ran_num
);

reg				[2:0]	   ran_num_reg;


always @(posedge clk or posedge rst)
	if(rst)	
        ran_num_reg 	<=3'd1			;
    else if(ran_num_reg >=4)			
        ran_num_reg 	<=3'd1			;
    else if(ran_num_reg ==0)			
        ran_num_reg 	<=3'd1			;		
	else 
        ran_num_reg <= ran_num_reg + 1	;
		
	
always @(posedge clk or posedge rst)
begin
	if(rst)	
        ran_num =2'd0				;
   else if(en_RESTARTdown) 
        ran_num =ran_num_reg 		;	
	else if(en_direction)
	    begin
			#20 //延时20us
			ran_num =ran_num_reg;
		 end 
end
endmodule