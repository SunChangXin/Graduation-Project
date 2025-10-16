module state_display(
    input           clk             , // 系统时钟
    input           rst             , // 复位信号，高电平有效
    input           RESTARTdown     , // 重启按键信号
    input           LeftDown        , // 左按键信号
    input           RightDown       , // 右按键信号
    input           UpDown          , // 上按键信号
    input           DownDown        , // 下按键信号
	 
	 output          sss             ,
	 output  [7:0]   col_pin         , // 列引脚输出
    output  [7:0]   row_pin         , // 行引脚输出
	 output  [7:0]   vision_bcd      , // 数码管输出的视标信号值
	 output  reg     ctr_signal        
);

	reg             flag            ;
	reg             False           ; // 错误按下标志
	reg             True            ; // 正确按下标志
	reg     [2:0]   direction       ; // 方向控制
	reg     [3:0]   cnt_level       ; // 计数器，控制显示级别
	reg     [2:0]   state_current   ; // 当前状态
	reg     [2:0]   state_next      ; // 下一个状态
	reg     [7:0]   Vision_value    ; // 当前视标值
	reg     [2:0]   num_reg         ; // 随机数寄存器
	reg     [4:0]   count           ; // 移位寄存器 
	reg     [63:0]  DianZhen_Data   ; // 根据cnt_level显示不同的数据
	reg             RST_state       ;
	reg             Down_state      ;
	reg     [1:0]   temp            ; // 模值为3
	reg             display_en      ; // 倒计时使能信号
	
	wire    [2:0]   ran_num         ; // 随机数
	wire    [7:0]   col             ; // 列数据
	wire    [7:0]   row             ; // 行数据
	wire            clkout          ;
	
	assign          col_pin = col  ;  // 列引脚赋值
	assign          row_pin = row  ;  // 行引脚赋值
	assign          sss     = display_en; //仿真变量
	
	// 状态机的状态定义
	localparam  STATE_IDLE         = 3'b001   ; // 闲置状态
	localparam  STATE_DISPLAY      = 3'b010   ; // 开始显示状态
	localparam  STATE_FALSE        = 3'b100   ; // 错误状态
	
	
	initial
	begin
		ctr_signal = 0;
		count = 4'b0000;
		flag = 1;
		temp <= 0;
		display_en <= 0;
	end	
	
	always @ (posedge clkout or posedge RESTARTdown)
	begin
		if(RESTARTdown)
		begin
			temp <= 0;
			display_en <= 0;
		end
		else if(temp < 3 )
			temp <= temp + 1;
		else if(temp == 3) 
		begin
			temp <= temp;
			display_en <= 1;
		end
	end
	
	
	
	// 状态机下一个状态的逻辑
	always @(*)
		begin
			case(state_current)
				STATE_IDLE:
					if(RESTARTdown)
						state_next = STATE_DISPLAY ;
               else 
                  state_next = STATE_IDLE    ; 
            STATE_DISPLAY:
					if(cnt_level < 0 || cnt_level > 9)
                  state_next = STATE_FALSE;
               else
                  state_next = STATE_DISPLAY;
            STATE_FALSE:
               if(RESTARTdown)
						state_next = STATE_IDLE;
               else
						state_next = STATE_FALSE; 
            default:
						state_next = STATE_IDLE;
        endcase         
    end

	
	
	// 状态机当前状态的更新
	always @(posedge clk or posedge rst)
	begin
		if (rst) 
			state_current <= STATE_IDLE; 
		else 
			state_current <= state_next;
	end
	
	// 方向判断
	always @(posedge clk or posedge rst)
	begin
		if (rst) 
			begin
				False   <=  0;      
				True    <=  0;  
			end     
		else if (state_current == STATE_DISPLAY && direction == num_reg && direction != 0)
			begin
            False   <=  0;      
            True    <=  1;  
			end 
		else if (state_current == STATE_DISPLAY && direction != num_reg && direction != 0)
			begin
            False   <=  1;      
            True    <=  0;  
			end 
		else 
			begin
            False   <=  0;      
            True    <=  0;
			end 
	end
	
	// 方向按键的处理
	always @(posedge clk or posedge rst)
	begin
		if (rst) 
			direction   <=  3'd0; 
		else if (state_current == STATE_DISPLAY && LeftDown )
			direction   <=  3'd1; 
		else if (state_current == STATE_DISPLAY && RightDown )
			direction   <=  3'd2; 
		else if (state_current == STATE_DISPLAY && UpDown   )
			direction   <=  3'd3;
		else if (state_current == STATE_DISPLAY && DownDown )
			direction   <=  3'd4;       
		else 
			direction   <=  3'd0; 
	end
	
	// 计数器的处理
	always @(posedge clk or posedge rst)
	begin
		if (rst) 
			cnt_level   <=  4'b0100; 
		else if (state_current == STATE_IDLE && state_next == STATE_DISPLAY)
			cnt_level   <=  4'b0100; 
		else if (state_current == STATE_DISPLAY && False)
			cnt_level   <=  cnt_level + 4'b0001;       
		else if (state_current == STATE_DISPLAY && True)
			cnt_level   <=  cnt_level - 4'b0001;   
		else 
			cnt_level   <=  cnt_level; 
	end
	
	// 移位寄存器存储输入的判断结果
	always@(posedge clk)
	begin 
		if(RESTARTdown)
		begin
			count <= 4'b00000;
		end
		else if (True)
		begin
			count[4:1] <= count[3:0];
			count[0] <= 1;
		end
		else if (False)
		begin
			count[4:1] <= count[3:0];
			count[0] <= 0;
		end
	end


	// 显示数据的定义
	reg [63:0] DISP_1_5_right   = {8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00};
	reg [63:0] DISP_1_2_right   = {8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00};
	reg [63:0] DISP_1_0_right   = {8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00};
	reg [63:0] DISP_0_8_right   = {8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00};

	reg [63:0] DISP_0_6_right   = {8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00};
	reg [63:0] DISP_0_4_right   = {8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00};
	reg [63:0] DISP_0_2_right   = {8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E};
	reg [63:0] DISP_0_1_right   = {8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF};

	reg [63:0] DISP_high_out    = {8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}; // 实菱形
	reg [63:0] DISP_low_out     = {8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}; // 圆
	reg [63:0] DISP_error       = {8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}; // X
	reg [63:0] DISP_right       = {8'h00,8'h28,8'h5a,8'h00,8'h82,8'h3c,8'h00,8'h00}; // 笑脸
	reg [63:0] DISP_3           = {8'h00,8'h3c,8'h04,8'h04,8'h3c,8'h04,8'h04,8'h3c}; // 3
	reg [63:0] DISP_2           = {8'h00,8'h3c,8'h04,8'h04,8'h3c,8'h20,8'h20,8'h3c};	// 2
	reg [63:0] DISP_1           = {8'h00,8'h08,8'h18,8'h08,8'h08,8'h08,8'h08,8'h3c};	// 1
	
	// 图案显示模块
	always @(posedge clk or posedge rst)
	begin
			  
			  if(rst) flag = 1;
			  
			  else begin
			  if(display_en) begin
			  
				// 控制基础视图输出
				if(cnt_level==4'b0000&&count==15)           begin DianZhen_Data   =   DISP_right;      Vision_value	 =	8'd15;   ctr_signal = 0; flag=0;end
				else if(cnt_level==4'b0001&&count==7)       begin DianZhen_Data   =   DISP_1_5_right;  Vision_value	 =	8'd15;   ctr_signal = 0;end
				else if(cnt_level==4'b0010&&count==3)       begin DianZhen_Data   =   DISP_1_2_right;  Vision_value	 =	8'd12;   ctr_signal = 0;end
				else if(cnt_level==4'b0011&&count==1)       begin DianZhen_Data   =   DISP_1_0_right;  Vision_value	 =	8'd10;   ctr_signal = 0;end
				else if(cnt_level==4'b0100&&count==0)       begin DianZhen_Data   =   DISP_0_8_right;  Vision_value	 =	8'd8;    ctr_signal = 0;end
				else if(cnt_level==4'b0101&&count==0)       begin DianZhen_Data   =   DISP_0_6_right;  Vision_value	 =	8'd6;    ctr_signal = 0;end
				else if(cnt_level==4'b0110&&count==0)       begin DianZhen_Data   =   DISP_0_4_right;  Vision_value	 =	8'd4;    ctr_signal = 0;end
				else if(cnt_level==4'b0111&&count==0)       begin DianZhen_Data   =   DISP_0_2_right;  Vision_value	 =	8'd2;    ctr_signal = 0;end
				else if(cnt_level==4'b1000&&count==0)       begin DianZhen_Data   =   DISP_0_1_right;  Vision_value	 =	8'd1;    ctr_signal = 1;end
			  
				// 控制特殊图案输出
				else if(cnt_level==4'b0010&&count!=3)       begin DianZhen_Data   =   DISP_high_out;   Vision_value	 =	8'd12;   ctr_signal = 0;end
				else if(cnt_level==4'b0011&&count!=1)       begin DianZhen_Data   =   DISP_high_out;   Vision_value	 =	8'd10;   ctr_signal = 0;end
				else if(cnt_level==4'b0100&&count==2)       begin DianZhen_Data   =   DISP_low_out;    Vision_value	 =	8'd8;    ctr_signal = 0;end
				else if(cnt_level==4'b0100&&count==1)       begin DianZhen_Data   =   DISP_low_out;    Vision_value	 =	8'd6;    ctr_signal = 0;end
				else if(cnt_level==4'b0101&&count!=0)       begin DianZhen_Data   =   DISP_low_out;    Vision_value	 =	8'd4;    ctr_signal = 0;end
				else if(cnt_level==4'b0110&&count!=0)       begin DianZhen_Data   =   DISP_low_out;    Vision_value	 =	8'd2;    ctr_signal = 0;end
				else if(cnt_level==4'b0111&&count!=0)       begin DianZhen_Data   =   DISP_low_out;    Vision_value	 =	8'd1;    ctr_signal = 0;end
				else if(cnt_level==4'b1001&&count==0)       begin DianZhen_Data   =   DISP_error;      Vision_value	 =	8'd1;    ctr_signal = 1;end
			  
				// 全错 视图为X
				else begin DianZhen_Data   =   DISP_error;       Vision_value	 =	8'd1;    ctr_signal = 1;end
			  end	
			  
			  else begin
			  if(temp==0)      begin DianZhen_Data   =   DISP_3;    flag=0;  end
			  else if(temp==1) begin DianZhen_Data   =   DISP_2;    flag=0;  end
			  else if(temp==2) begin DianZhen_Data   =   DISP_1;    flag=0;  end
			  else if(temp==3) begin DianZhen_Data   =   DISP_right;    flag=1;  end
			  end
			  end
	end
	
	
	// 译码电路
	assign  vision_bcd[7:4]  =  Vision_value  % 4'd10           ;    // 对应视标小数点后一位数
	assign  vision_bcd[3:0]  =  Vision_value  / 4'd10 % 4'd10   ;    // 对应视标个位数
	
	
	// 最终结果(笑脸)的控制
	always@(posedge clk)
	begin
		if(flag == 0)
			num_reg <= 0;
		else
			num_reg <= ran_num;
	end
	
	
	
	// 随机数生成模块的消抖模块
	always @(*)
	begin
		if(rst) 
		begin
			RST_state=0;
			Down_state=0;
		end	
		if(RESTARTdown==1)
			RST_state=1;
		else
			RST_state=0;
		if(LeftDown || RightDown || UpDown || DownDown==1) 
			Down_state=1;
		else
			Down_state=0;
	end
	
	// 点阵扫描模块
	Dianzhen_scan d0(
    .clk            (   clk             ),
    .rst            (   rst             ),
    .mode           (   num_reg         ),
    .row_sel        (   row             ),      
    .col_sel        (   col             ),     
    .DianZhen_Data  (   DianZhen_Data   )
	);
	
	// 随机数生成模块
	random_num r0(
   .clk                       (   clk              ),
   .rst                       (   rst              ),
   .en_RESTARTdown  	         (   RST_state        ), 
	.en_direction              (   Down_state       ),
   .ran_num                   (   ran_num          )  // 1 2 3 4
	);
	
	display_divider #(.WIDTH(32),.N(10000000)) d10 (  //分频10MHz
											.clk(clk),
											.rst_n(rst),
											.clkout(clkout)
	);
	
	

endmodule