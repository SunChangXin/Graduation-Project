module YiMa_7D(sw,clk,led);
  input [3:0] sw;
  input clk;
  
  wire [6:0] output_led;
  
  output reg [8:0] led;
  
  
  
always @ (posedge clk) begin

  led <= {3'b000,output_led};
  
end
  
  
  my_YiMa_7D u1 (
             .Ai(sw),
				 .E1(1),
				 .E2_low(0),
				 .E3_low(0),
				 .ledx(output_led)
             ); 
  
  
endmodule