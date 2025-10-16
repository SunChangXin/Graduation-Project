module lattice(clk1,clk2,rst,row,col);
	input clk1;
	input clk2;
	input rst;
	
	
	output reg [7:0] row;
	output reg [7:0] col;
	
	
	reg [1:0] temp1;  // 模值为4
	reg [2:0] temp2;  // 模值为8
 	
	
	initial begin
		temp1 <= 0;
		temp2 <= 0;
	end
	
	always @ (posedge clk1 or posedge rst)
	begin
		if(rst)
			temp1 <= 0;
		else
			temp1 <= temp1 + 1;
	end
	
	always @ (posedge clk2 or posedge rst)
	begin
		if(rst)
			temp2 <= 0;
		else
			temp2 <= temp2 + 1;
	end	
	
	always @ (*) begin
		if(temp1 == 0)
		begin 
			case(temp2)
				3'b000: {row,col} <= 16'b0111_1111_0000_0000;
				3'b001: {row,col} <= 16'b1011_1111_0000_0000;
				3'b010: {row,col} <= 16'b1101_1111_0011_1100;
				3'b011: {row,col} <= 16'b1110_1111_0010_0000;
				3'b100: {row,col} <= 16'b1111_0111_0010_0000;
				3'b101: {row,col} <= 16'b1111_1011_0011_1100;
				3'b110: {row,col} <= 16'b1111_1101_0000_0000;
				3'b111: {row,col} <= 16'b1111_1110_0000_0000;
				default:{row,col} <= 16'b1111_1111_0000_0000;
			endcase
		end
		
		if(temp1 == 1)
		begin 
			case(temp2)
				3'b000: {row,col} <= 16'b0111_1111_0000_0000;
				3'b001: {row,col} <= 16'b1011_1111_0000_0000;
				3'b010: {row,col} <= 16'b1101_1111_0010_0100;
				3'b011: {row,col} <= 16'b1110_1111_0010_0100;
				3'b100: {row,col} <= 16'b1111_0111_0010_0100;
				3'b101: {row,col} <= 16'b1111_1011_0011_1100;
				3'b110: {row,col} <= 16'b1111_1101_0000_0000;
				3'b111: {row,col} <= 16'b1111_1110_0000_0000;
				default:{row,col} <= 16'b1111_1111_0000_0000;
			endcase		
		end
		
		if(temp1 == 2)
		begin 
			case(temp2)
				3'b000: {row,col} <= 16'b0111_1111_0000_0000;
				3'b001: {row,col} <= 16'b1011_1111_0000_0000;
				3'b010: {row,col} <= 16'b1101_1111_0011_1100;
				3'b011: {row,col} <= 16'b1110_1111_0000_0100;
				3'b100: {row,col} <= 16'b1111_0111_0000_0100;
				3'b101: {row,col} <= 16'b1111_1011_0011_1100;
				3'b110: {row,col} <= 16'b1111_1101_0000_0000;
				3'b111: {row,col} <= 16'b1111_1110_0000_0000;
				default:{row,col} <= 16'b1111_1111_0000_0000;
			endcase		
		end
		
		if(temp1 == 3)
		begin 
			case(temp2)
				3'b000: {row,col} <= 16'b0111_1111_0000_0000;
				3'b001: {row,col} <= 16'b1011_1111_0000_0000;
				3'b010: {row,col} <= 16'b1101_1111_0011_1100;
				3'b011: {row,col} <= 16'b1110_1111_0010_0100;
				3'b100: {row,col} <= 16'b1111_0111_0010_0100;
				3'b101: {row,col} <= 16'b1111_1011_0010_0100;
				3'b110: {row,col} <= 16'b1111_1101_0000_0000;
				3'b111: {row,col} <= 16'b1111_1110_0000_0000;
				default:{row,col} <= 16'b1111_1111_0000_0000;
			endcase			
		end
	
	end
	
	
	
	
	
	
	
	
endmodule