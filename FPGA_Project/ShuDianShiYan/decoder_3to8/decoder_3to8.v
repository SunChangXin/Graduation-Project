module decoder_3to8(A,E1,E2_low,E3_low,Y_low,Si,Ci);
	input  [2:0]  A;         //3位输入
	input  E1;               //高电平有效使能端
	input  E2_low;           //低电平有效使能端
	input  E3_low;           //低电平有效使能
	
	output reg[7:0]  Y_low; //8位输出，低电平有效
	output reg Si;
	output reg Ci;
   
	//在always模块中的被赋值变量均为寄存器类型！

always @ (A or E1 or E2_low or E3_low)   //行为语句模块，敏感信号
	begin
		if(E1 && ~E2_low && ~E3_low)       //使能输入有效
		 case(A)
			3'b000 : Y_low = 8'b1111_1110;
			3'b001 : Y_low = 8'b1111_1101;
			3'b010 : Y_low = 8'b1111_1011;
			3'b011 : Y_low = 8'b1111_0111;
			3'b100 : Y_low = 8'b1110_1111;
			3'b101 : Y_low = 8'b1101_1111;
			3'b110 : Y_low = 8'b1011_1111;
			3'b111 : Y_low = 8'b0111_1111;
         default: Y_low = 8'b1111_1111;
		 endcase                           //case模块结束
      else                               //使能端无效情况
         Y_low = 8'b11111111; 
      
		if(!(Y_low[1] && Y_low[2] && Y_low[4] && Y_low[7]))
		begin
		  Si = 1'b1;
		end
		
		if(Y_low[1] && Y_low[2] && Y_low[4] && Y_low[7])
		begin
		  Si = 1'b0;
		end
		
		if(!(Y_low[3] && Y_low[5] && Y_low[6] && Y_low[7]))
		begin
		  Ci = 1'b1;
		end
		
		if(Y_low[3] && Y_low[5] && Y_low[6] && Y_low[7])
		begin
		  Ci = 1'b0;
		end
			
	end                                   //if模块结束
	
	
	

       
endmodule
