module cn (clk,bnt7,bnt0,seg,cat,count_out);
 
	input clk,bnt0,bnt7;						
	output reg [6:0] seg; // 输出的数码管段选信号
   output reg [7:0] cat; // 输出的数码管位选信号
	output [7:0]count_out;
        wire clk1h;                                     //定义一个中间变量，表示分频得到的时钟，用作计数器的触发   
        wire bnt7_pulse;		  
        reg control=1;
		  reg [20:0]out;
		  reg select;
		  reg [8:0]a;
		  reg [8:0]b;
		  reg  [3:0]bin;
        //例化分频器模块，产生一个1Hz时钟信号		
        divide #(.WIDTH(7),.N(100)) u2 (         //传递参数
			.clk(clk),
			.rst_n(bnt0),                   //例化的端口信号都连接到定义好的信号
			.clkout(clk1h)
			);
always@(posedge clk, posedge bnt0) begin
      if(bnt0 == 1'b1) begin
         cat <= 8'b1111_1111; // 数码管全熄灭
         bin <= 0; // 复位bin为0
      end
      else begin
         select <= ~select; // 每次时钟上升沿时，select取反（每10ms）
         if(select == 1'b0) begin
            cat <= 8'b1111_1110; // select为0时  个位显示在第8位数码管
            bin <= b; // 将b赋给bin
         end
         else begin
            cat <= 8'b1111_1101; // 当select为1时，十位显示在第7位数码管上
            bin <= a; // 将a赋给bin
         end
      end
   end
always@(bin) begin
       case(bin)
         
4'd0:seg=7'b0111111;//0
4'd1:seg=7'b0000110;//1
4'd2:seg=7'b1011011;//2
4'd3:seg=7'b1001111;//3
4'd4:seg=7'b1100110;//4
4'd5:seg=7'b1101101;//5
4'd6:seg=7'b1111101;//6
4'd7:seg=7'b0000111;//7
4'd8:seg=7'b1111111;//8
4'd9:seg=7'b1101111;//9
		default:seg = 7'b0000000;
      endcase
   end

always@(posedge bnt7_pulse or posedge bnt0 )begin
  if(bnt0 == 1'b1) begin
         control <= 1'b1; // 复位control为1
      end
      else begin
         control <= ~control; // 每次按下bnt7时，ctr取反
      end
   end
always@(posedge clk1h or posedge bnt0 ) 
  begin 
   if(bnt0)begin 
    out<=0;
     end
   else if(control==1)begin

        if(out!=19)begin
            out<=out+1'b1;
        end
        else begin 
            out<=0;
        end
 
    end
	 end
always@(*)
  begin 
   a=out/10;
	b=out%10;
  end
  assign count_out = out;
  
	 debounce #(.N(1)) u1 (                               
                       .clk (clk),
                       .rst (bnt0),
                       .key (bnt7),
                       .key_pulse (bnt7_pulse)
                       );
	
endmodule

 