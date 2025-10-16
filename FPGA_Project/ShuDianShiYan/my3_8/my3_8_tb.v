`timescale 1ns/1ps    // 定义仿真时间单位与精度，1ns是时间单位，即在仿真中用 #10 表示延迟10ns。
                      // 1ps表示时间精度，比如你写 #3.5547968525 a <= 1;c <= 1;，那么它时间精度
							 // 也只会有1ps(即在3.555ns时赋值语句便生效）。



module my3_8_tb;      // 测试文件

  reg a;
  reg b;
  reg c;
  
  wire [7:0] out;     // 定义一个wire型的输出端口
  
  my3_8 u1(
  .a(a),
  .b(b),
  .c(c),
  .out(out)
  ); 
  
  initial begin  
	 a = 0; b = 0; c = 0;
	 #200
	 a = 0; b = 0; c = 1;
	 #200
	 a = 0; b = 1; c = 0;
	 #200
	 a = 0; b = 1; c = 1;
	 #200
	 a = 1; b = 0; c = 0;
	 #200
	 a = 1; b = 0; c = 1;
	 #200
	 a = 1; b = 1; c = 0;
	 #200
	 a = 1; b = 1; c = 1;
	 #200
	 $stop;            // 仿真器停止仿真

  end
endmodule