module division(clk, clk_out);  
      
    parameter DIV_NUM = 1; 
    input clk;  
    output reg clk_out;  
    reg [19:0]count;  
      
    always@(posedge clk)  
    begin  
        if(count == DIV_NUM)  
        begin  
            clk_out <= !clk_out;  
            count <= 0;  
        end  
       else  
            count <= count + 20'b1;  
    end  
      
endmodule  

