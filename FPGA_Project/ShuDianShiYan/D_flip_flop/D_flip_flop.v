module D_flip_flop(clk,set_n,rst_n,D,q,q_n);
   input clk;
   input set_n;  // 同步置1信号（置位）
   input rst_n;  // 同步置0信号（复位）
   
   input D;
  
   output reg q;
	output reg q_n;
  
  
always @ (posedge clk)
begin

	if(!rst_n) begin  // 同步置0 （复位）
     q <= 1'b0;
	  q_n <= 1'b1; 
   end 
	
	else if(!set_n) begin  // 同步置1 （置位）
     q <= 1'b1;
	  q_n <= 1'b0; 
   end 
	
   else begin       // D触发器功能
     q <= D;
	  q_n <= ~D;
   end
	
end  
  
endmodule