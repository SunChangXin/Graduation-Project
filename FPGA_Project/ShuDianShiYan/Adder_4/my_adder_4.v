module my_adder_4(a,b,Cout,Sum);
  input [3:0] a;
  input [3:0] b;
  
  output [3:0] Cout;
  output [3:0] Sum;
  
    adder_1 u1 (
	               .a(a[0]),
						.b(b[0]),
						.Cin(0),
						.Cout(Cout[0]),
						.Sum(Sum[0])
	            );
	 adder_1 u2 (
	               .a(a[1]),
						.b(b[1]),
						.Cin(Cout[0]),
						.Cout(Cout[1]),
						.Sum(Sum[1])
	            );
	 adder_1 u3 (
	               .a(a[2]),
						.b(b[2]),
						.Cin(Cout[1]),
						.Cout(Cout[2]),
						.Sum(Sum[2])
	            );
	 adder_1 u4 (
	               .a(a[3]),
						.b(b[3]),
						.Cin(Cout[2]),
						.Cout(Cout[3]),
						.Sum(Sum[3])
	            );
  
  
endmodule