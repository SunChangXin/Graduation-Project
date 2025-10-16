module Rainbow_led(clk,rst,ctr1,ctr2,ctr3,SW,r,g,b);
	input clk;
	input rst;
	input ctr1,ctr2,ctr3; // 分别为三色灯1控制输入、三色灯2控制输入、双灯同步控制输入
	input [3:0] SW;
	output [1:0] r,g,b;
	
	reg [15:0] wheel_pos;
	reg [7:0] r1_buf, g1_buf, b1_buf; 
	reg [7:0] r2_buf, g2_buf, b2_buf; 
	reg [31:0] div_buffer;
	reg div_clk;
	reg confirm_1 = 1;  // 分别为三色灯1控制信号、三色灯2控制信号、双灯同步控制信号
	reg confirm_2 = 1;
	reg confirm_3 = 1; 
	
	reg [63:0] NUM; // 分频控制变量
	
	wire clk_d;
	wire clk;
	wire ctr1_d,ctr2_d,ctr3_d;
	
	parameter [3:0] f1 = 4'b1000; 
	parameter [3:0] f2 = 4'b0100; 
	parameter [3:0] f3 = 4'b0010; 
	parameter [3:0] f4 = 4'b0001; 
	
	
	
	// 按键消抖模块 
	debounce#(.N(3))u1 (                                           
                       .clk (clk),
                       .rst (rst),
                       .key ({ctr1,ctr2,ctr3}),
                       .key_pulse ({ctr1_d,ctr2_d,ctr3_d})
                       ); 
	
			
	// PWM模块
	PWM p1(
			.duty(r1_buf),
			.clk(clk),
			.out(r[0])
			);
	
	PWM p2(
			.duty(g1_buf),
			.clk(clk),
			.out(g[0])
			);	
	
	PWM p3(
			.duty(b1_buf),
			.clk(clk),
			.out(b[0])
			);	
	PWM p4(
			.duty(r2_buf),
			.clk(clk),
			.out(r[1])
			);
	
	PWM p5(
			.duty(g2_buf),
			.clk(clk),
			.out(g[1])
			);	
	
	PWM p6(
			.duty(b2_buf),
			.clk(clk),
			.out(b[1])
			);	
	
	
	// 分频模块
	always @ (posedge clk)
	begin
		if(div_buffer < NUM)
			div_buffer <= div_buffer + 1;
		else begin
			div_clk = ~div_clk;
			div_buffer <= 0;
		end
		
	end
	
	// 分频频率控制模块
	always @ (posedge clk)
	begin
	// 根据开关输入控制分频
		case(SW)
			f1: NUM = 12500;
		   f2: NUM = 25000;
			f3: NUM = 100000;
			f4: NUM = 200000;
			default: NUM = 50000;
		endcase
	end
	
	// 呼吸灯试实现模块
	always @ (posedge div_clk)
	begin
		if(wheel_pos < 765)
			wheel_pos <= wheel_pos + 1;		
		else
			wheel_pos <= 0;
		
		
		if(confirm_1) begin          // 三色灯1控制信号有效
			if(wheel_pos < 255)
			begin
				r1_buf <= 255 - wheel_pos; // 255 - 0
				g1_buf <= 0;               // 0 - 0
				b1_buf <= wheel_pos;       // 0 - 255
			end
			else if(wheel_pos < 510)
			begin
				r1_buf <= 0;
				g1_buf <= (wheel_pos - 255);
				b1_buf <= 255 - (wheel_pos - 255);
			end
			else
			begin
				r1_buf <= (wheel_pos - 510);
				g1_buf <= 255 - (wheel_pos - 510);
				b1_buf <= 0;
			end
		end
		else begin           // 三色灯1控制信号无效 输出置0
			r1_buf <= 0;
			g1_buf <= 0;
			b1_buf <= 0;
		end
		
		if(confirm_2) begin       // 三色灯1控制信号有效
			if(confirm_3) begin    // 双灯同步控制信号为高电平 实现“同步呼吸”
				if(wheel_pos < 255)
				begin
					r2_buf <= 255 - wheel_pos;
					g2_buf <= 0;
					b2_buf <= wheel_pos;
				end
				else if(wheel_pos < 510)
				begin
					r2_buf <= 0;
					g2_buf <= (wheel_pos - 255);
					b2_buf <= 255 - (wheel_pos - 255);
				end
				else
				begin
					r2_buf <= (wheel_pos - 510);
					g2_buf <= 255 - (wheel_pos - 510);
					b2_buf <= 0;
				end
			end
			else begin             // 双灯同步控制信号为低电平 实现“反向呼吸”，即颜色变化相反
				if(wheel_pos < 255)
				begin
					r2_buf <= 255 - wheel_pos;
					g2_buf <= wheel_pos;
					b2_buf <= 0;
				end
				else if(wheel_pos < 510)
				begin
					r2_buf <= 0;
					g2_buf <= 255 - (wheel_pos - 255);
					b2_buf <= (wheel_pos - 255);
				end
				else
				begin
					r2_buf <= (wheel_pos - 510);
					g2_buf <= 0;
					b2_buf <= 255 - (wheel_pos - 510);
				end
			end
		end
		else begin           // 三色灯2控制信号无效 输出置0
			r2_buf <= 0;
			g2_buf <= 0;
			b2_buf <= 0;
		end
		
	end
	
	// 单双灯/同步 控制模块
	always @ (posedge clk)
	begin
		if(ctr1_d)
			confirm_1 = ~confirm_1;
		if(ctr2_d) 
			confirm_2 = ~confirm_2;
		if(ctr3_d) 
			confirm_3 = ~confirm_3;
	end
	
endmodule