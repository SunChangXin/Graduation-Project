module Guess(clk,SW,rst_n,confirm,Ge_Wei,Shi_Wei,led,seg_led1,seg_led2,led11,led12,led13,led21,led22,led23);
	input clk; 
	input [3:0] SW;
	input rst_n;     // 重置按键
	input confirm;   // 确认按键
	input Ge_Wei;    // 个位确认按键
	input Shi_Wei;   // 十位确认按键
	
	output reg [7:0] led;
	output reg [8:0] seg_led1; // 数码管显示1
	output reg [8:0] seg_led2; // 数码管显示2
	output reg led11;
	output reg led12;
	output reg led13;
	output reg led21;
	output reg led22;
	output reg led23;
	
	wire rst_n_d;
	wire Ge_Wei_d;
	wire Shi_Wei_d;
	wire confirm_d;
	wire clkout;
	
	
	
	reg [1:0] A;       // 猜对数字且位置正确
	reg [1:0] B;       // 猜对数字但位置不正确
	reg [3:0] code_gw; // 输入的个位
	reg [3:0] code_sw; // 输入的十位
	reg [3:0] M_new;   // 随机数个位
	reg [3:0] N_new;   // 随机数十位
	reg [7:0] rand_num;
	
	initial begin
		code_gw <= 4'b0000;
		code_sw <= 4'b0000;
		led <= 8'b1111_1111;
		rand_num <= 8'b1111_1111;
		led11 <= 1;
		led12 <= 1;
		led13 <= 1;
		led21 <= 1;
		led22 <= 1;
		led23 <= 1;
		
	end
	
	//分频器模块，产生一个2Hz时钟信号		
   divide #(.WIDTH(32),.N(6000000)) c1 ( 
			.clk(clk),
			.rst_n(rst_n),                        //例化的端口信号都连接到定义好的信号
			.clkout(clkout)
			);	
	
	// 按键消抖模块   
	debounce#(.N(3))u1 (                                         
                       .clk (clk),
                       .rst (rst_n),
                       .key ({confirm,Ge_Wei,Shi_Wei}),
                       .key_pulse ({confirm_d,Ge_Wei_d,Shi_Wei_d})
                       ); 
	
	// 随机数模块
	always @ (posedge clkout)
	begin 
		rand_num[0] <= rand_num[7];
		rand_num[1] <= rand_num[0];
		rand_num[2] <= rand_num[1];
		rand_num[3] <= rand_num[2];
		rand_num[4] <= rand_num[3]^rand_num[7];
		rand_num[5] <= rand_num[4]^rand_num[7];
		rand_num[6] <= rand_num[5]^rand_num[7];
		rand_num[7] <= rand_num[6];
	end
	
	// 数码管显示模块
	always @ (*)
	begin
		case(code_gw)
			4'd0: seg_led1 = 9'h3f;
			4'd1: seg_led1 = 9'h06;
			4'd2: seg_led1 = 9'h5b;
			4'd3: seg_led1 = 9'h4f;
			4'd4: seg_led1 = 9'h66;
			4'd5: seg_led1 = 9'h6d;
			4'd6: seg_led1 = 9'h7d;
			4'd7: seg_led1 = 9'h07;
			4'd8: seg_led1 = 9'h7f;
			4'd9: seg_led1 = 9'h6f;
			4'd10:seg_led1 = 9'h77;
			4'd11:seg_led1 = 9'h7c;
			4'd12:seg_led1 = 9'h39;
			4'd13:seg_led1 = 9'h5e;
			4'd14:seg_led1 = 9'h79;
			4'd15:seg_led1 = 9'h71;
			default: seg_led1 = 9'h3f;
		endcase
		case(code_sw)
			4'd0: seg_led2 = 9'h3f;
			4'd1: seg_led2 = 9'h06;
			4'd2: seg_led2 = 9'h5b;
			4'd3: seg_led2 = 9'h4f;
			4'd4: seg_led2 = 9'h66;
			4'd5: seg_led2 = 9'h6d;
			4'd6: seg_led2 = 9'h7d;
			4'd7: seg_led2 = 9'h07;
			4'd8: seg_led2 = 9'h7f;
			4'd9: seg_led2 = 9'h6f;
			4'd10:seg_led2 = 9'h77;
			4'd11:seg_led2 = 9'h7c;
			4'd12:seg_led2 = 9'h39;
			4'd13:seg_led2 = 9'h5e;
			4'd14:seg_led2 = 9'h79;
			4'd15:seg_led2 = 9'h71;
			default: seg_led2 = 9'h3f;
		endcase
	end
	
	// 猜数字比较与结果显示
	always @ (posedge clk or negedge rst_n) 
	begin
		if(!rst_n)         // 重置随机数
		begin
			{N_new,M_new} <= rand_num;
			code_gw <= 4'b0000;
			code_sw <= 4'b0000;
			led <= 8'b1111_1111;
			led11 <= 1;
			led12 <= 1;
			led13 <= 1;
			led21 <= 1;
			led22 <= 1;
			led23 <= 1;
		end
		
		else if(Ge_Wei_d)  code_gw <= (SW==4'd15) ? M_new : SW; // 设置了作弊途径
		else if(Shi_Wei_d) code_sw <= (SW==4'd15) ? N_new : SW; // 只要将4位输入开关设置为1111，就一定能猜对
		
		else if(confirm_d)
			begin
				A = (code_gw==M_new) ? ((code_sw==N_new)?2:1) : ((code_sw==N_new)?1:0);
				B = ((N_new!=M_new)&(code_gw==N_new)) ? ((code_sw==M_new)?2:1) : (((N_new!=M_new)&(code_gw!=N_new)) ? ((code_sw==M_new)? 1 : 0) : 0);                                
				led22 <= A ? 0 : 1;                       // 若A存在 亮左绿灯
				led12 <= (A==2) ? 0 : 1;                  // 若A=2  亮右绿灯
				led23 <= ((!A)&&(B!=0)) ? 0 : 1;          // 若A不存在且B存在 亮左蓝灯
				led13 <= ((A&B)||(B==2)) ? 0 : 1;         // 若A=1或B=2 亮右蓝灯
				led21 <= (A||B) ? 1 : 0;                  // 若AB都不存在 亮左红灯
				led11 <= ((!(A&B))&&(A!=2)&&(B!=2)) ? 0: 1; 
				led <= (led!=8'b0) ? (led<<1) : 8'b1111_1111;
			end
		else begin
			A = 0;
			B = 0;
		end
	end

endmodule