module Dianzhen_scan(
    input              clk         ,  // 系统时钟
    input              rst         ,  // 复位信号，高电平有效
    input      [2:0]   mode        ,  // 显示模式控制
    output reg [7:0]   row_sel     ,  // 行选择信号
    output reg [7:0]   col_sel     ,  // 列选择信号
    input      [63:0]  DianZhen_Data  // 显示数据，64位，控制8x8的数码管
);

	
	reg [2:0]    count              ; // 计数器
	
	initial begin
		count=3'b000;
	end


	always @ (posedge clk or posedge rst)
	begin
		if(rst)
			count <= 0;
		else
			count <= count + 1;
	end	
	
	
	always@(*)
	begin
		case(mode)       
			3'd1://左
				begin
				if(DianZhen_Data==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8左
			   begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
			   if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1110;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0010;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1110;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1110;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0010;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0010;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0010;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0111_1110;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1111;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1111_1111;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0001;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0001;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0001;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0001;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0001;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0001;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0011_1100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_0100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5左
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0001_1000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0000_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0001_1000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
            begin
				case(count)
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
            if(DianZhen_Data==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
            begin
				case(count)
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
		      if(DianZhen_Data==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
            begin
				case(count)
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

			3'd2://右
				begin
				if(DianZhen_Data==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8右
			   begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
			   if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1110;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1110;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1110;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0111_1110;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0111_1111;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0100_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0100_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0100_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0100_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_1111_1111;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_1000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_1000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_1000_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_1000_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_1000_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_1000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_1111_1111;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0011_1100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_1100;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0011_1000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0000_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5右
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0000_0000;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0011_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0010_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0011_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0000_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0000_0000;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
            begin
				case(count)
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
            if(DianZhen_Data==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
            begin
				case(count)
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
		      if(DianZhen_Data==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
            begin
				case(count)
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
				
			3'd3://上
				begin
				if(DianZhen_Data==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8上
			   begin
				case(count)
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
			   if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2上
            begin
				case(count)
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
				if(DianZhen_Data==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5上
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
            begin
				case(count)
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
            if(DianZhen_Data==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
            begin
				case(count)
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
		      if(DianZhen_Data==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h3C,8'h20,8'h20,8'h3C,8'h00,8'h00}))//0.8下
            begin
				case(count)
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
			   if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h7C,8'h00,8'h00}))//0.6下
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h7C,8'h40,8'h40,8'h40,8'h40,8'h7C,8'h00}))//0.4下
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h7E,8'h40,8'h40,8'h40,8'h40,8'h40,8'h7E}))//0.2下
            begin
				case(count)
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
				if(DianZhen_Data==({8'hFF,8'h80,8'h80,8'h80,8'h80,8'h80,8'h80,8'hFF}))//0.1下
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h20,8'h38,8'h00,8'h00}))//1.0下
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h38,8'h20,8'h38,8'h00,8'h00,8'h00}))//1.2下
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h00,8'h18,8'h10,8'h18,8'h00,8'h00,8'h00}))//1.5下
            begin
				case(count)
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
            if(DianZhen_Data==({8'h00,8'h18,8'h24,8'h5b,8'h5b,8'h24,8'h18,8'h00}))//圆
            begin
				case(count)
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
            if(DianZhen_Data==({8'h81,8'h42,8'h24,8'h18,8'h18,8'h24,8'h42,8'h81}))//×
            begin
				case(count)
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
            if(DianZhen_Data==({8'h00,8'h18,8'h3c,8'h7e,8'h7e,8'h3c,8'h18,8'h00}))//菱形
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h28,8'h5a,8'h00,8'h82,8'h3c,8'h00,8'h00})) // 笑脸
            begin
				case(count)
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
				if(DianZhen_Data==({8'h00,8'h3c,8'h04,8'h04,8'h3c,8'h04,8'h04,8'h3c})) // 3
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1100;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0010_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0010_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0010_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0011_1100;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h3c,8'h04,8'h04,8'h3c,8'h20,8'h20,8'h3c})) // 2
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1100;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0000_0100;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0000_0100;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0011_1100;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0010_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0010_0000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0011_1100;
				default:{row_sel,col_sel} <= 16'b1111_1111_0000_0000;
				endcase
				end
				if(DianZhen_Data==({8'h00,8'h08,8'h18,8'h08,8'h08,8'h08,8'h08,8'h3c})) // 1
            begin
				case(count)
				3'b000: {row_sel,col_sel} <= 16'b0111_1111_0000_0000;
				3'b001: {row_sel,col_sel} <= 16'b1011_1111_0011_1100;
				3'b010: {row_sel,col_sel} <= 16'b1101_1111_0001_0000;
				3'b011: {row_sel,col_sel} <= 16'b1110_1111_0001_0000;
				3'b100: {row_sel,col_sel} <= 16'b1111_0111_0001_0000;
				3'b101: {row_sel,col_sel} <= 16'b1111_1011_0001_0000;
				3'b110: {row_sel,col_sel} <= 16'b1111_1101_0001_1000;
				3'b111: {row_sel,col_sel} <= 16'b1111_1110_0001_0000;
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