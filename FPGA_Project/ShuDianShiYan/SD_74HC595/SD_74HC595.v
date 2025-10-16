module SD_74HC595(clk,rst,DS,OE,STCP,SHCP,led,Q);

	input clk;
	input rst;
	input DS;    // 输入的数据
	input OE;
	input STCP;
	input SHCP;
	
	output [7:0] led; // 移位寄存器对应输出到8个led
	output [8:0] Q;   // 锁存器对应输出到7段数码管
	
	
	wire [7:0] Q_reg;
	wire SHCP_state;
	wire STCP_state;
	
	
	
	
	
	debounce #(.N(2)) u1 (                     // 调用按键消抖                       
                       .clk (clk),
                       .rst (rst),
                       .key ({SHCP,STCP}),
                       .key_pulse ({SHCP_state,STCP_state})
                       ); 	
	
	My_74HC595 u2(
	              .DS(DS),
					  .MR(rst),
					  .SHCP(SHCP_state),
					  .STCP(STCP_state),
					  .OE(OE),
					  .out_led(led),
					  .out_q(Q_reg)
	              );
					  
	assign Q = {Q_reg,1'b0}; // 最低位用来控制小脚丫数码管 MSB~LSB=DIG端

	
	
	
endmodule