module my_qj38(Ai,Bi,E,Si,Co);
  input [3:0] Ai;
  input [3:0] Bi;
  input [2:0] E;
 
 
  wire [3:0] Ci;
  
  output [3:0] Si;
  output Co;
  
  
  decoder_3to8 u1 (
                   .A({Ai[0],Bi[0],1'b0}),
						 .E1(E[2]),
						 .E2_low(E[1]),
						 .E3_low(E[0]),
						 .Y_low(),
						 .Si(Si[0]),
						 .Ci(Ci[0])
                   );
						 
  decoder_3to8 u2 (
                   .A({Ai[1],Bi[1],Ci[0]}),
						 .E1(E[2]),
						 .E2_low(E[1]),
						 .E3_low(E[0]),
						 .Y_low(),
						 .Si(Si[1]),
						 .Ci(Ci[1])
                   );
  
  decoder_3to8 u3 (
                   .A({Ai[2],Bi[2],Ci[1]}),
						 .E1(E[2]),
						 .E2_low(E[1]),
						 .E3_low(E[0]),
						 .Y_low(),
						 .Si(Si[2]),
						 .Ci(Ci[2])
                   );
						 
  decoder_3to8 u4 (
                   .A({Ai[3],Bi[3],Ci[2]}),
						 .E1(E[2]),
						 .E2_low(E[1]),
						 .E3_low(E[0]),
						 .Y_low(),
						 .Si(Si[3]),
						 .Ci(Co)
                   );
  
endmodule