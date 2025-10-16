module seg_scan(
    input              clk         ,  // 系统时钟
    input              rst         ,  // 复位信号，高电平有效
    input      [2:0]   mode        ,  // 显示模式控制
    output reg [7:0]   row_sel     ,  // 行选择信号
    output reg [7:0]   col_sel     ,  // 列选择信号
    input      [63:0]  DISP_DATA      // 显示数据，64位，控制8x8的数码管
);

// 扫描频率和时钟频率的参数定义
parameter   SCAN_FREQ   = 125000                          ; // 扫描频率
parameter   CLK_FREQ    = 10000000                   ;    // 时钟频率  这两个参数很重要

// 根据扫描频率和时钟频率计算扫描计数值
parameter   SCAN_COUNT  = CLK_FREQ / (SCAN_FREQ * 8) - 1;

reg[31:0]   scan_timer                                  ; // 扫描定时器
reg[3:0]    scan_sel                                    ; // 扫描选择信号


// 扫描定时器和扫描选择信号的控制逻辑
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        scan_timer <= 32'd0;
        scan_sel <= 4'd0;
    end
    else if(scan_timer == SCAN_COUNT)//>=
    begin
        scan_timer <= 32'd0;
        if(scan_sel == 4'd7)
            scan_sel <= 4'd0;
        else
            scan_sel <= scan_sel + 4'd1;
    end
    else
        begin
            scan_timer <= scan_timer + 32'd1;
        end
end

// 根据扫描选择信号获取行选择数据
//assign row_sel_choice = DISP_DATA[(scan_sel+1)*8-1-:8];  // 切片 反向取每个行的8位
//assign row_sel_and = row_sel_choice;


// 根据扫描选择信号和显示数据控制行列信号
reg[7:0]    row_sel_reg                                 ; // 行选择寄存器
reg[7:0]    col_sel_reg                                 ; // 列选择寄存器
always@(*)//对每一行进行扫描
	begin
		case(scan_sel)
			4'd0://对第一行进行扫描
			begin
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8]; //DISP_DATA[7 -: 8] <–等价于–> DISP_DATA[7:0]				
				row_sel_reg[7:1] 		<= 	7'b1111111;						
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end
			4'd1://对第二行进行扫描
			begin		
				col_sel_reg 			<= 	DISP_DATA[(scan_sel+1)*8-1-:8];	//DISP_DATA[15 -: 8] <–等价于–> DISP_DATA[15:8]
				row_sel_reg[7:2] 		<= 	6'b111111;	
				row_sel_reg[0] 			<= 	1'b1;		
				
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end			
			4'd2://对第三行进行扫描
			begin
				col_sel_reg 			<= 	DISP_DATA[(scan_sel+1)*8-1-:8];	//DISP_DATA[23 -: 8] <–等价于–>DISP_DATA[23:16]				
				row_sel_reg[7:3] 		<= 	5'b11111;		
				row_sel_reg[1:0] 		<= 	2'b11;					
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end
			4'd3://对第四行进行扫描
			begin
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8];	//DISP_DATA[31 -: 8] <–等价于–> DISP_DATA[31:24]				
				row_sel_reg[7:4] 		<= 	4'b1111;		
				row_sel_reg[2:0] 		<= 	3'b111;		
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end
			4'd4://对第五行进行扫描
			begin
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8];	//DISP_DATA[39 -: 8] <–等价于–> DISP_DATA[39:32]		
				
				row_sel_reg[7:5] 		<= 	3'b111;		
				row_sel_reg[3:0] 		<= 	4'b1111;				
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end
			4'd5://对第六行进行扫描
			begin
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8];	//DISP_DATA[47 -: 8] <–等价于–> DISP_DATA[47:40]	
				row_sel_reg[7:6] 		<= 	2'b11;		
				row_sel_reg[4:0] 		<= 	5'b11111;					
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end
			4'd6://对第七行进行扫描                                                     //DISP_DATA[55 -: 8] <–等价于–> DISP_DATA[55:48]	
			begin
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8];
				row_sel_reg[7] 			<= 	1'b1;		
				row_sel_reg[5:0] 		<= 	6'b111111;		

				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end			
			4'd7: //对第八行进行扫描                                                    //DISP_DATA[63 -: 8] <–等价于–> DISP_DATA[63:56]
			begin	
				col_sel_reg 			<= DISP_DATA[(scan_sel+1)*8-1-:8];			
				row_sel_reg[6:0] 		<= 	7'b1111111;	
				if(DISP_DATA[(scan_sel+1)*8-1-:8]>0)
				row_sel_reg[scan_sel]	<= 0;
				else
				row_sel_reg[scan_sel]	<= 1;
			end						
			default:
			begin
				row_sel_reg <= 8'h00;
				col_sel_reg <= 8'h00;
			end
		endcase
	end
reg [2:0] count_r;//计数器

initial begin
	count_r=3'b000;
end

always @ (posedge clk or posedge rst)
	begin
		if(rst)
			count_r <= 0;
		else
			count_r <= count_r + 1;
	end
	

always@(*)
begin
		case(mode)
			3'd1://左
				begin
					row_sel=row_sel_reg;
					col_sel={ col_sel_reg[0],col_sel_reg[1],col_sel_reg[2],col_sel_reg[3],col_sel_reg[4],col_sel_reg[5],col_sel_reg[6],col_sel_reg[7]};			
				end			

			3'd2://右
				begin
					 row_sel=row_sel_reg;
					 col_sel=col_sel_reg;	//因为我们一开始的定义就是向着右边，直接赋值就好		
				end
				//左右很简单，是没有问题的，重点是看上下的变换
			3'd3://上
begin
				 /*if(col_sel_reg!=8'b00000000)begin
					row_sel=~{ col_sel_reg[0],col_sel_reg[1],col_sel_reg[2],col_sel_reg[3],col_sel_reg[4],col_sel_reg[5],col_sel_reg[6],col_sel_reg[7]};
					col_sel=~row_sel_reg;
					                          end*/             
			   if(DISP_DATA==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
			   if(DISP_DATA==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0010_0010;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0010;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1110;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0100_0010;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0010;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0111_1110;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0100_0001;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1000_0001;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_1000_0001;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_1000_0001;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_1000_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_1000_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_1000_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_1000_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				 if(DISP_DATA==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//0.1-
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0111_1110;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0111_1110;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_1000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5上
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				 if(DISP_DATA==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0101_1010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0101_1010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
             if(DISP_DATA==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1000_0001;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0100_0010;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0001_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0001_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0010;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1000_0001;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end 	
		      if(DISP_DATA==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0111_1110;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0111_1110;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end 						 
				
end
			3'd4://下
begin
				  /*if(col_sel_reg!=8'b00000000)begin
					row_sel=~col_sel_reg;
					col_sel=~{row_sel_reg[0],row_sel_reg[1],row_sel_reg[2],row_sel_reg[3],row_sel_reg[4],row_sel_reg[5],row_sel_reg[6],row_sel_reg[7]};
                                         end*/	
			 if(DISP_DATA==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
			   if(DISP_DATA==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1110;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0010;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0010;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1110;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0010;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0010;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1111;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0100_0001;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1111_1111;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_1000_0001;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_1000_0001;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_1000_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_1000_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_1000_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_1000_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1000_0001;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0011_1100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
				if(DISP_DATA==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5下
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_1000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DISP_DATA==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//0.1-
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0111_1110;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0111_1110;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
            if(DISP_DATA==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0101_1010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0101_1010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
             if(DISP_DATA==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1000_0001;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0100_0010;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0001_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0001_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0010;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1000_0001;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end 	
             if(DISP_DATA==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0001_1000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0111_1110;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0111_1110;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end 						 				 
end		
			3'd0:
begin
				  	
			 
				if(DISP_DATA==({8'h00,8'h28,8'h5a,8'h00,8'h82,8'h3c,8'h00,8'h00}))
             begin
				case(count_r)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1100;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0100_0010;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0101_1010;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0010_0100;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				 end
           
            						 				 
end	
			default:
				begin
					row_sel=8'hff;
					col_sel=8'hff;	
				end
		endcase
end
endmodule 