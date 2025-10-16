module display(
    input           sys_clk         ,  //系统时钟(选择10MHz)
    input           sys_rst         ,  //系统复位（高电平有效）
    input           KeyRESTART      , //重启键输入
    input           KeyLeft         , //左键输入
    input           KeyRight        , //右键输入
    input           KeyUp           , //上键输入
    input           KeyDown         , //下键输入
	 
	 output        [7:0]   col_pin   ,//列引脚输出 （高电平有效）
    output        [7:0]   row_pin   ,//行引脚输出 （低电平有效）
	 output        [7:0]   seg_sel	,// 数码管位选 
    output        [7:0]   seg_led    // 数码管段选
);

	wire    RESTARTdown      ;	//重启键按下标志
	wire    LeftDown         ;	//左键按下标志
	wire    RightDown        ;	//右键按下标志
	wire    upDown           ;	//上键按下标志
	wire    DownDown         ;	//下键按下标志
	wire    [7:0]    bcd     ;	//定义数码管要显示的数值
	wire    X_signal; 
        
// 显示状态模块实例化
display_state display_state_inst
(
            .clk                (sys_clk     ),//系统时钟
            .rst                (sys_rst     ),//系统复位
            .col_pin            (col_pin     ),//列引脚输出
            .row_pin            (row_pin     ),//行引脚输出
				.bcd                (bcd         ),//bcd码
            .RESTARTdown        (RESTARTdown ),//重启键按下标志
            .LeftDown           (LeftDown    ),//左键按下标志
				.X_signal           (X_signal    ),
            .RightDown          (RightDown   ),//右键按下标志
            .UpDown             (upDown      ),//上键按下标志
            .DownDown           (DownDown    ) //下键按下标志
);

//调用数码管显示视力标模块
seg_led seg_led_inst(
              .clk(sys_clk       ),
				  .rst_n(sys_rst     ),
				  .bcd(bcd           ),
				  .X_signal(X_signal ),
	           .seg_sel(seg_sel   ),
				  .seg_led(seg_led	)
);

// 重启键消抖模块
key_debounce key_debounce_restart(
            .clk        (sys_clk    ),//系统时钟
            .rst        (sys_rst    ),//系统复位
            .key        (KeyRESTART ),//重启键输入
            .key_pulse  (RESTARTdown) //重启键按下标志输出
);

// 左键消抖模块
key_debounce key_debounce_u1(            
            .clk        (sys_clk    ),//系统时钟
            .rst        (sys_rst    ),//系统复位
            .key        (KeyLeft    ),//左键输入
            .key_pulse  (LeftDown   ) //左键按下标志输出
);

// 右键消抖模块
key_debounce key_debounce_u2(            
            .clk        (sys_clk    ),//系统时钟
            .rst        (sys_rst    ),//系统复位           
            .key        (KeyRight   ),//右键输入
            .key_pulse  (RightDown  ) //右键按下标志输出
);

// 上键消抖模块
key_debounce key_debounce_u3(            
            .clk        (sys_clk    ),//系统时钟
            .rst        (sys_rst    ),//系统复位            
            .key        (KeyUp      ),//上键输入
            .key_pulse  (upDown     ) //上键按下标志输出
);

// 下键消抖模块
key_debounce key_debounce_u4(            
            .clk        (sys_clk    ),//系统时钟
            .rst        (sys_rst    ),//系统复位            
            .key        (KeyDown    ),//下键输入
            .key_pulse  (DownDown   ) //下键按下标志输出
);

endmodule
