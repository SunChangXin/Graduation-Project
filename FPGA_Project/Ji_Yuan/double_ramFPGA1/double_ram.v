module double_ram(
       clock,
		 data,
		 rdaddress,
		 wraddress,
		 wren,
		 q
		 );
   input clock;
	input [3:0]data;
	input [2:0]rdaddress;
	input [2:0]wraddress;
	input wren;
	output [3:0]q;
	
	wire [3:0]n_rdaddress = {1'b0,rdaddress};
	wire [3:0]n_wraddress = {1'b0,wraddress};
	
ram2 ram2
(
	.clock(clock),
	.data(data),
	.rdaddress(n_rdaddress),
	.wraddress(n_wraddress),
	.wren(wren),
	.q(q)
);
endmodule