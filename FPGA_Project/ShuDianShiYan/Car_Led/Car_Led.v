module Car_Led(sw,clk,rst,led,seg_led_1,seg_led_2);
	input [3:0] sw; // 开关控制汽车状态
	input clk; 
	input rst; 
	output reg [5:0] led; // 两个三色灯
	output reg [8:0] seg_led_1;
	output reg [8:0] seg_led_2;
	
	
	wire clk_1Hz;
	
	//分频器模块，产生一个1Hz时钟信号		
   divide #(.WIDTH(32),.N(12000000)) c1 ( 
			.clk(clk),
			.rst_n(rst),                        //例化的端口信号都连接到定义好的信号
			.clkout(clk_1Hz)
			);	
	
	
	parameter [3:0] START = 4'b0000; // 起始状态
	parameter [3:0] S1 = 4'b0110;    // 直行
	parameter [3:0] S2 = 4'b1000;    // 左转
	parameter [3:0] S3 = 4'b0001;    // 右转
	parameter [3:0] S4 = 4'b1111;    // 临时停车或故障
	
	
	reg [3:0] current_state;
	reg [3:0] next_state;
	
	
	initial begin
		current_state <= START;
		next_state <= START;
	end
	
	
	// 第一个always块，描述在时钟驱动下,次态迁移到现态
	always @ (posedge clk_1Hz or negedge rst)
	begin
		if(!rst)
			current_state <= START;
		else
			current_state <= next_state;
	end
	
	// 第二个always块，描述状态的转移关系
	always @ (current_state or sw)
	begin
	// 相当于让状态变量重复的从起始状态变化到当前状态
	// 从而实现“闪烁”的功能
		case(current_state)
			START:case(sw)
					S1: next_state = S1;
					S2: next_state = S2;
					S3: next_state = S3;
					S4: next_state = S4;
					default: next_state = START;
					endcase	
			S1: next_state = START;
			S2: next_state = START;
			S3: next_state = START;
			S4: next_state = START;
			default: next_state = START;
		endcase
	end
	
	// 第三个alwavs块，描述每个状态对应的输出
	always @ (current_state)
	begin 
		case(current_state)
			START: led = 6'b111111;
			S1: led = 6'b111111;     // 不亮
			S2: led = 6'b100111;     // 左黄灯
			S3: led = 6'b111100;     // 右黄灯
			S4: led = 6'b110110;     // 双红灯
			default: led = 6'b111111;
		endcase
		
		// 控制7段数码管显示图像 
		// 应当强调，这里的控制电路应至少记忆两个时钟的状态并赋值，才能正常实现功能
		if(current_state == START)
		begin
			if(next_state == S1)       	// 直行
			begin
				seg_led_1 <= 9'b000100111; 
				seg_led_2 <= 9'b000110011; 
			end
			if(next_state == S2)       	// 左转
			begin
				seg_led_1 <= 9'b001000000;
				seg_led_2 <= 9'b001001111;
			end
			if(next_state == S3) 			// 右转
			begin
				seg_led_1 <= 9'b001111001;
				seg_led_2 <= 9'b001000000;
			end
			if(next_state == S4) 			// 临时停车或故障
			begin
				seg_led_1 <= 9'b001110000;
				seg_led_2 <= 9'b001000110;
			end
			if(next_state == START)
			begin
				seg_led_1 <= 0;
				seg_led_2 <= 0;
			end
		end
		if(current_state == S1)				
		begin
			seg_led_1 <= 9'b000100111;
			seg_led_2 <= 9'b000110011;
		end
		if(current_state == S2 )
		begin
			seg_led_1 <= 9'b001000000;
			seg_led_2 <= 9'b001001111;
		end
		if(current_state == S3)
		begin
			seg_led_1 <= 9'b001111001;
			seg_led_2 <= 9'b001000000;
		end
		if(current_state == S4)
		begin
			seg_led_1 <= 9'b001110000;
			seg_led_2 <= 9'b001000110;
		end
	end
	
	
endmodule