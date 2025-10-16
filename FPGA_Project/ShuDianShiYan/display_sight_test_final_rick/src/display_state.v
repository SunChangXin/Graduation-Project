`timescale 1ns / 1ps
module display_state
(
    input           clk             , // 系统时钟
    input           rst             , // 复位信号，高电平有效
    output  [7:0]   col_pin         , // 列引脚输出
    output  [7:0]   row_pin         , // 行引脚输出
	 output  [7:0]   bcd1            , // 数码管输出的视标信号值
	 output  [7:0]   bcd2            , // 数码管输出的视标信号值
    input           RESTARTdown     , // 重启按键信号
    input           LeftDown        , // 左按键信号
	 input           ChangeDown      ,
	 output  reg     X_signal        ,
	 output  reg     ctr_control     ,
	 output  [3:0]   temp1           ,
	 output  [3:0]   temp2           ,
    input           RightDown       , // 右按键信号
    input           upDown          , // 上按键信号
    input           DownDown          // 下按键信号
	 
);



// 状态机的状态定义
localparam  STATE_IDLE         = 3'b001   ; // 空闲状态
localparam  START_DISPLAY      = 3'b010   ; // 开始显示状态
localparam  STATE_FALSE        = 3'b100   ; // 错误状态

reg     ctr                     ;
reg     [2:0]   num_reg         ;
reg     flag                    ;
reg     [2:0]   direction       ; // 方向控制
wire    [2:0]   ran_num         ; // 随机数
reg             downfalse       ; // 错误按下标志
reg             downtrue        ; // 正确按下标志
reg     [3:0]   cnt_level       ; // 计数器，控制显示级别
reg     [2:0]   state_c         ; // 当前状态
reg     [63:0] DISP_DATA;
reg     [2:0]   state_n         ; // 下一个状态
reg     [7:0]   Apparent_value_1  ; // 当前视标值
reg     [7:0]   Apparent_value_2  ; // 当前视标值

wire    [7:0]   col             ; // 列数据
wire    [7:0]   row             ; // 行数据

assign          col_pin = col  ; // 列引脚赋值
assign          row_pin = row  ; // 行引脚赋值

//reg             direction_flag  ; // 方向标志
reg     [2:0]     ran_num_reg   ; // 随机数寄存器
reg               final_error   ;


// 显示数据的定义
reg [63:0] DISP_1_5_right   = {8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00};
reg [63:0] DISP_1_2_right   = {8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00};
reg [63:0] DISP_1_0_right   = {8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00};
reg [63:0] DISP_0_8_right   = {8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00};

reg [63:0] DISP_0_6_right   = {8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00};
reg [63:0] DISP_0_4_right   = {8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00};
reg [63:0] DISP_0_2_right   = {8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E};
reg [63:0] DISP_0_1_right   = {8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF};

reg [63:0] DISP_1_5_out   = {8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00};
reg [63:0] DISP_1_2_out   = {8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00};
reg [63:0] DISP_1_0_out   = {8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00};// 小圆形

reg [63:0] DISP_0_8_out   = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00};
reg [63:0] DISP_0_6_out   = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00};
reg [63:0] DISP_0_4_out   = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00};
reg [63:0] DISP_0_2_out   = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00};
reg [63:0] DISP_0_1_out   = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00};// 实菱形

reg [63:0] DISP_error       = {8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81};// X
reg [63:0] DISP_right       = {8'h00,8'h28,8'h5a,8'h00,8'h82,8'h3c,8'h00,8'h00};// 笑脸
// 根据cnt_level显示不同的数据

initial
begin
 X_signal=0;
 final_error=0;
 flag <= 1;
 ctr <= 0;
end	
// 随机数寄存器的处理
always @(posedge clk or posedge rst)
    if (rst) 
        ran_num_reg <=  3'd0       ;   
    else  
        ran_num_reg <=  ran_num    ;

// 状态机当前状态的更新
always @(posedge clk or posedge rst)
    if (rst) 
        state_c <= STATE_IDLE; 
    else 
        state_c <= state_n;

// 状态机下一个状态的逻辑
always @(*)
    begin
        case(state_c)
            STATE_IDLE:
                if(RESTARTdown)
                    state_n <= START_DISPLAY ;
                else 
                    state_n <= STATE_IDLE    ; 
            START_DISPLAY:
				if(cnt_level < 4'b0000 || cnt_level > 4'b1001)
                    state_n <= STATE_FALSE;
                else
                    state_n <= START_DISPLAY;
            STATE_FALSE:
                if(RESTARTdown)
                    state_n <= STATE_IDLE;
                else
                    state_n <= STATE_FALSE; 
            default:
                    state_n <= STATE_IDLE;
        endcase         
    end


always@(posedge clk or posedge rst)
begin
if(rst)
	ctr <= 0;
else begin
	if(ChangeDown)
		ctr <= ~ctr;
end
end
	 
// 计数器的处理
always @(posedge clk or posedge rst)
    if (rst) 
	 begin
        cnt_level   <=  4'b0100;
		  end
	 else if(cnt_level == 0)
			cnt_level <= cnt_level;
    else if (state_c == STATE_IDLE && state_n == START_DISPLAY)
        cnt_level   <=  4'b0100; 
    else if (state_c == START_DISPLAY && downfalse)
        cnt_level   <=  cnt_level + 4'b0001;       
    else if (state_c == START_DISPLAY && downtrue)
        cnt_level   <=  cnt_level - 4'b0001;   
    else 
        cnt_level   <=  cnt_level; 
	

// 方向判断
always @(posedge clk or posedge rst)begin
    if (rst) 
        begin
            downfalse   <=  0;      
            downtrue    <=  0;  
        end    
    else if (state_c == START_DISPLAY && direction == num_reg && direction != 0)
        begin
            downfalse   <=  0;      
            downtrue    <=  1;  
        end 
    else if (state_c == START_DISPLAY && direction != num_reg && direction != 0)
        begin
            downfalse   <=  1;      
            downtrue    <=  0;  
        end 
    else 
        begin
            downfalse   <=  0;      
            downtrue    <=  0;
        end 
	 
end
// 方向按键的处理
always @(posedge clk or posedge rst)
    if (rst) 
        direction   <=  3'd0; 
    else if (state_c == START_DISPLAY && LeftDown )
        direction   <=  3'd1; 
    else if (state_c == START_DISPLAY && RightDown )
        direction   <=  3'd2; 
    else if (state_c == START_DISPLAY && upDown   )
        direction   <=  3'd3;
    else if (state_c == START_DISPLAY && DownDown )
        direction   <=  3'd4;       
    else 
        direction   <=  3'd0; 

//outcome 按下正确就认为加一 反之 加 0 
reg [4:0]count=4'b0000;
always@(posedge clk or posedge rst)
begin 
if(rst)
count<=4'b0000;


else if(RESTARTdown==1)
begin
count=count+0;
end
		
else if (downtrue)
begin
count[4:1]<=count[3:0];
count[0]<=1;
end
else if (downfalse)
begin
count[4:1]<=count[3:0];
count[0]<=0;
end
end



always @(posedge clk or posedge rst)
    begin 
			  if(rst)
				  flag = 1;
				  
			  else begin
			  
			  if(ctr==0) begin
			  
		     // 控制基础视图输出
		     if(cnt_level== 4'b0000||count==4'b1111)                      
			  begin
			  DISP_DATA   =   DISP_right;      
			  Apparent_value_1	 =	8'd15;
			  X_signal=0;
			  flag = 0;
			  end
           else if(cnt_level==4'b0001&&count==4'b0111)  begin DISP_DATA   =   DISP_1_5_right;  Apparent_value_1	 =	8'd15;X_signal=0;end
           else if(cnt_level==4'b0010&&count==4'b0011)  begin DISP_DATA   =   DISP_1_2_right;  Apparent_value_1	 =	8'd12;X_signal=0;end
           else if(cnt_level==4'b0011&&count==4'b0001)  begin DISP_DATA   =   DISP_1_0_right;  Apparent_value_1	 =	8'd10;X_signal=0;end
           else if(cnt_level==4'b0100&&count==4'b0000)  begin DISP_DATA   =   DISP_0_8_right;  Apparent_value_1	 =	8'd8; X_signal=0;end
           else if(cnt_level==4'b0101&&count==4'b0000)  begin DISP_DATA   =   DISP_0_6_right;  Apparent_value_1	 =	8'd6; X_signal=0;end
           else if(cnt_level==4'b0110&&count==4'b0000)  begin DISP_DATA   =   DISP_0_4_right;  Apparent_value_1	 =	8'd4; X_signal=0;end
           else if(cnt_level==4'b0111&&count==4'b0000)  begin DISP_DATA   =   DISP_0_2_right;  Apparent_value_1	 =	8'd2; X_signal=0;end
           else if(cnt_level==4'b1000&&count==4'b0000)  begin DISP_DATA   =   DISP_0_1_right;  Apparent_value_1	 =	8'd1; X_signal=0;end
			  
			  // 控制特殊图案输出
           else if(cnt_level==4'b0010&&count!=4'b0011)  begin DISP_DATA   =   DISP_1_2_out;  Apparent_value_1	 =	8'd12;   X_signal=0;end
           else if(cnt_level==4'b0011&&count!=4'b0001)  begin DISP_DATA   =   DISP_1_0_out;  Apparent_value_1	 =	8'd10;   X_signal=0;end
           else if(cnt_level==4'b0100&&count==4'b0010)  begin DISP_DATA   =   DISP_0_8_out;  Apparent_value_1	 =	8'd8;    X_signal=0;end
			  else if(cnt_level==4'b0100&&count==4'b0001)  begin DISP_DATA   =   DISP_0_6_out;  Apparent_value_1 =	8'd6;    X_signal=0;end
           else if(cnt_level==4'b0101&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_4_out;  Apparent_value_1	 =	8'd4;    X_signal=0;end
           else if(cnt_level==4'b0110&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_2_out;  Apparent_value_1	 =	8'd2;    X_signal=0;end
			  else if(cnt_level==4'b0111&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_1_out;  Apparent_value_1	 =	8'd1;    X_signal=0;end
           
			  else if(cnt_level==4'b1001&&count==4'b0000)  begin DISP_DATA   =   DISP_error;    Apparent_value_1	 =	8'd1;    X_signal=1;end
			  
			  // 全错 视图为X
           else   begin DISP_DATA   =   DISP_error;       Apparent_value_1	 =	8'd1;    X_signal=1;end  
			  end
			  
			  
			  else if(ctr) begin
			  // 控制基础视图输出
		     if(cnt_level== 4'b0000||count==4'b1111)                      
			  begin
			  DISP_DATA   =   DISP_right;      
			  Apparent_value_1	 =	8'd15;
			  X_signal=0;
			  flag = 0;
			  end
           else if(cnt_level==4'b0001&&count==4'b0111)  begin DISP_DATA   =   DISP_1_5_right;  Apparent_value_2	 =	8'd15;X_signal=0;end
           else if(cnt_level==4'b0010&&count==4'b0011)  begin DISP_DATA   =   DISP_1_2_right;  Apparent_value_2	 =	8'd12;X_signal=0;end
           else if(cnt_level==4'b0011&&count==4'b0001)  begin DISP_DATA   =   DISP_1_0_right;  Apparent_value_2	 =	8'd10;X_signal=0;end
           else if(cnt_level==4'b0100&&count==4'b0000)  begin DISP_DATA   =   DISP_0_8_right;  Apparent_value_2	 =	8'd8; X_signal=0;end
           else if(cnt_level==4'b0101&&count==4'b0000)  begin DISP_DATA   =   DISP_0_6_right;  Apparent_value_2	 =	8'd6; X_signal=0;end
           else if(cnt_level==4'b0110&&count==4'b0000)  begin DISP_DATA   =   DISP_0_4_right;  Apparent_value_2	 =	8'd4; X_signal=0;end
           else if(cnt_level==4'b0111&&count==4'b0000)  begin DISP_DATA   =   DISP_0_2_right;  Apparent_value_2	 =	8'd2; X_signal=0;end
           else if(cnt_level==4'b1000&&count==4'b0000)  begin DISP_DATA   =   DISP_0_1_right;  Apparent_value_2	 =	8'd1; X_signal=0;end
			  
			  // 控制特殊图案输出
           else if(cnt_level==4'b0010&&count!=4'b0011)  begin DISP_DATA   =   DISP_1_2_out;  Apparent_value_2	 =	8'd12;   X_signal=0;end
           else if(cnt_level==4'b0011&&count!=4'b0001)  begin DISP_DATA   =   DISP_1_0_out;  Apparent_value_2	 =	8'd10;   X_signal=0;end
           else if(cnt_level==4'b0100&&count==4'b0010)  begin DISP_DATA   =   DISP_0_8_out;  Apparent_value_2	 =	8'd8;    X_signal=0;end
			  else if(cnt_level==4'b0100&&count==4'b0001)  begin DISP_DATA   =   DISP_0_6_out;  Apparent_value_2 =	8'd6;    X_signal=0;end
           else if(cnt_level==4'b0101&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_4_out;  Apparent_value_2	 =	8'd4;    X_signal=0;end
           else if(cnt_level==4'b0110&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_2_out;  Apparent_value_2	 =	8'd2;    X_signal=0;end
			  else if(cnt_level==4'b0111&&count!=4'b0000)  begin DISP_DATA   =   DISP_0_1_out;  Apparent_value_2	 =	8'd1;    X_signal=0;end
           
			  else if(cnt_level==4'b1001&&count==4'b0000)  begin DISP_DATA   =   DISP_error;    Apparent_value_2	 =	8'd1;    X_signal=1;end
			  
			  // 全错 视图为X
           else   begin DISP_DATA   =   DISP_error;       Apparent_value_2	 =	8'd1;    X_signal=1;end
			  
			  end
			  end
      		  
    end
assign  bcd1[7:4]  =  Apparent_value_1  % 4'd10;               // 对应视标小数点后一位数
assign  bcd1[3:0]  =  Apparent_value_1  / 4'd10 % 4'd10   ;    // 对应视标个位数
assign  bcd2[7:4]  =  Apparent_value_2  % 4'd10;               // 对应视标小数点后一位数
assign  bcd2[3:0]  =  Apparent_value_2  / 4'd10 % 4'd10   ;    // 对应视标个位数

assign  temp1 = cnt_level;
assign  temp2 = count;
assign  ctr_control = ctr;

wire clk_20ms;//可暂用的20ms分频时钟
// 点阵扫描模块
seg_scan seg_scan_inst(
    .clk        (   clk         ),
    .rst        (   rst         ),
    .mode       (   num_reg     ),
    .row_sel    (   row         ),      
    .col_sel    (   col         ),     
    .DISP_DATA  (   DISP_DATA   )
);

always@(posedge clk)
	begin
		if(flag==0)
			num_reg <= 0;
		else
		num_reg <= 3'd4;
		
	end


 reg RESTARdown_state;
 reg Directiondown_state;
 
 always @(*)begin
 if(rst)
  RESTARdown_state=0;
  Directiondown_state=0;
 if(RESTARTdown==1)
 RESTARdown_state=1;
 else
 RESTARdown_state=0;
 if(LeftDown || RightDown || upDown || DownDown==1) 
 Directiondown_state=1;
 else
 Directiondown_state=0;
 end
// 随机数生成模块
random_num random_num_inst(
   .clk        (   clk                                     ),
   .rst                       (   rst                           ),
   .en_RESTARTdown  	         (   RESTARdown_state             ),//LeftDown || RightDown || upDown || DownDown || 
	.en_direction( Directiondown_state),
   .ran_num    (   ran_num                                 ) // 1 2 3 4
);
//可用分频模块
display_divider #(.WIDTH(32),.N(1000000)) divider_inst(
											.clk(clk),
											.rst_n(rst),
											.clkout(clk_20ms)
);
endmodule
