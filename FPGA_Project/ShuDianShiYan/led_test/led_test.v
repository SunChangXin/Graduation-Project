module led_test(a,b,key_in,led_out);

  input a; //输入端口a
  input b; //输入端口b

  input key_in;
  
  output led_out;

  assign led_out = (key_in == 0) ? a : b;

endmodule



