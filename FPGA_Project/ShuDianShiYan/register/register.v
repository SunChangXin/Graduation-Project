module register(D,OC,clk,q);
	input [7:0] D; //数据输入端
	input OC;      //三态允许控制端
	input clk;     
	
	output reg [7:0] q; //数据输出端



always @ (posedge clk) 
begin                  //时钟升沿触发
	if(OC)              //输出高阻
		q <= 8'bzzzz_zzzz;
	else
		q <= D;
end


endmodule