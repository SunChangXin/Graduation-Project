module my_JK4(clk,rst,set,q);
	input clk;
	input rst;
	input set;
	input [3:0] q;

	
	JK_ff FF0 (
					.clk(clk),
					.set_n(set),
					.rst_n(rst),
					.j(1),
					.k(1),
					.q(q[0])
					);
	
	JK_ff FF1 (
					.clk(q[0]),
					.set_n(set),
					.rst_n(rst),
					.j(~q[3]),
					.k(~q[3]),
					.q(q[1])
					);
	
	JK_ff FF2 (
					.clk(q[1]),
					.set_n(set),
					.rst_n(rst),
					.j(1),
					.k(1),
					.q(q[2])
					);	
	
	JK_ff FF3 (
					.clk(q[0]),
					.set_n(set),
					.rst_n(rst),
					.j(q[1]&q[2]),
					.k(q[3]),
					.q(q[3])
					);	
					
	assign out = {q[3],q[2],q[1],q[0]};

	
endmodule