module My_74HC595(DS,MR,SHCP,STCP,OE,out_led,out_q);

	input DS;     // 输入的数据
	input MR;     // 主复位引脚，为0时复位移位寄存器
	input SHCP;   // 移位寄存器时钟输入，上升沿时DS上的数据会移入移位寄存器
	input STCP;	  // 存储寄存器时钟输入，上升沿时移位寄存器的数据传输到存储寄存器 
	input OE;     // 输出使能，为0时，存储器中的数据并行输出到Q0-Q7引脚；为1时，输出为高阻态

	output [7:0] out_led;  // 移位寄存器中数据  
	output [7:0] out_q;    // 锁存器中数据  
	
	
	reg [7:0] Q;      // 移位寄存器中的数据
	reg [7:0] R;      // 锁存器中的数据
	
	
	
	
	// 初始化
	initial begin  
		Q = 0;
		R = 0;

	end
	
	// 数据存入到移位寄存器
	always @ (posedge SHCP or negedge MR) 
	begin
		if(~MR)   // 复位清零
		begin
			Q <= 8'b0000_0000;
		end
		
		else      // SHCP上升沿 数据移入移位寄存器
		begin
			Q[0] <= DS;
			Q[7:1] <= Q[6:0];
		end
		
	end
	
	// 数据存入到锁存器
	always @ (posedge STCP) // STCP上升沿 移位寄存器的数据传输到存储寄存器
	begin
		R <= Q;
	end
	
	// 数据的输出
	assign out_led = Q;   
	assign out_q = OE ? 8'bzzzz_zzzz : R;   // OE信号控制使能端
	
endmodule