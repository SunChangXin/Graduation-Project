module my3_8(a,b,c,out);     // abc对应一个二进制数；out对应输出

  input a;
  input b;
  input c;
  
  output reg [7:0] out;      // 输出类型的端口需要保存数值，则必须将其显式的声明为reg数据类型 
  
  always @ (a,b,c)begin
    case({a,b,c})
	 
	 3'b000:out = 8'b00000001;
	 3'b001:out = 8'b00000010;
	 3'b010:out = 8'b00000100;
	 3'b011:out = 8'b00001000;
	 3'b100:out = 8'b00010000;
	 3'b101:out = 8'b00100000;
	 3'b110:out = 8'b01000000;
	 3'b111:out = 8'b10000000;
	 //default: out = 8'b10000000
    
	 endcase
  end
  
endmodule