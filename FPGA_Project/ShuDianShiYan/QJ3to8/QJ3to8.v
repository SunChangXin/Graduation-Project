module QJ3to8(sw,clk,rst,key_confirm_1,key_confirm_2,En,led);
  input [3:0] sw;
  input clk;
  input rst;
  input key_confirm_1,key_confirm_2;
  input En;
  
  output reg [4:0] led;
  
  reg [3:0] a;
  reg [3:0] b;
  reg confirm_1,confirm_2;
  
  wire confirm_1_d;
  wire confirm_2_d;
  wire [3:0] led_temp;
  wire Co;
  
  
  
   debounce#(.N(3))u0 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (rst),
                       .key ({key_confirm_1,key_confirm_2,En}),
                       .key_pulse ({confirm_1_d,confirm_2_d,En_d})
                       ); 
  
  
initial begin  
  confirm_1 <= 1'b0;
  confirm_2 <= 1'b0;
  a = 4'b0000;
  b = 4'b0000; 
  led = 5'b11111;
end  
  
  
always @ (posedge clk or negedge rst) begin
 if(!rst)
 begin 
  confirm_1 <= 1'b0;
  confirm_2 <= 1'b0;  
  a = 4'b0000;
  b = 4'b0000; 
  led = 5'b11111;
 end 
 
 else
 begin 
 
   if(confirm_1_d)
	begin
	  a = sw;
	  confirm_1 <= 1'b1;
	  led = {1'b1,~a};
	end
	
	if(confirm_2_d)
	begin
	  b = sw;
	  confirm_2 <= 1'b1;
	  led = {1'b1,~b};
	end
	
	if(En_d)
	  led = {~Co,~led_temp};
	
 end 
 
end

  
  
	my_qj38 u5(
	           .Ai(a),
				  .Bi(b),
				  .E({~En,~confirm_1,~confirm_2}),
				  .Si(led_temp),
				  .Co(Co)
	           );
  
 

endmodule