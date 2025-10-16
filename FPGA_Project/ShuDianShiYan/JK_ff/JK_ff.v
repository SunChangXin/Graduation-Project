module JK_ff(clk,set_n,rst_n,j,k,q);
	input clk;   // 时钟信号
	input set_n; // 异步置1（置位）
	input rst_n; // 异步置0（复位）
	input j;     // 输入j
	input k;     // 输入k
	
	
	output reg q; // 输出信号q
	
always @ (negedge clk or negedge set_n or negedge rst_n)
begin
	if(!rst_n)         //异步置0 （复位）
		begin
			q <= 1'b0;
      end
   else if(!set_n)    //异步置1 （置位）
      begin
         q <= 1'b1;
      end
   else
      begin
         case({j,k})   // jk触发器
				2'b00 : q <= q; 
            2'b01 : q <= 1'b0;
            2'b10 : q <= 1'b1;
            2'b11 : q <= ~q;
				default : q <= 1'b0;
         endcase
      end


end


endmodule