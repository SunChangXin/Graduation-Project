module Coffer(
input clk,
input [3:0] SwitchInput,
input rst_n,             // key[1]
input confirm,           // key[2] 输入完密码的确认键
input ge_wei,            // key[3] 个位确认
input shi_wei,           // key[4] 十位确认
output reg [7:0] led,
output reg [8:0] seg_led1,  // 数码管1数字显示
output reg [8:0] seg_led2   // 数码管2数字显示
);

parameter M = 4'd2;  
parameter N = 4'd2;  //初始密码22


key_debounce #(.N(3))u1  //调用消抖模块
( 
.clk(clk),
.rst(rst_n),
.key({confirm, ge_wei, shi_wei}),
.key_pulse({confirm_d,ge_wei_d,shi_wei_d})
);


// 按键消抖输出值，若对应按键按下则返回1：

wire confirm_d;     // key[2] 输入完密码的确认键
wire ge_wei_d;      // key[3] 个位确认
wire shi_wei_d;     // key[4] 十位确认


reg [1:0] error_cnt; // 错误次数计数器
reg [3:0] code_gw;   // 对应获取4位开关的输入，作为个位密码的输入
reg [3:0] code_sw;   // 对应获取4位开关的输入，作为十位密码的输入

reg [3:0] M_new;     // 用于修改密码
reg [3:0] N_new;

reg flag;            // 是否进行密码修改的标志 


always@(*)           // 数码管显示
begin
 case(code_gw)
 4'd0: seg_led1 = 9'b00_0111111;
 4'd1: seg_led1 = 9'b00_0000110;
 4'd2: seg_led1 = 9'b00_1011011;
 4'd3: seg_led1 = 9'b00_1001111;
 4'd4: seg_led1 = 9'b00_1100110;
 4'd5: seg_led1 = 9'b00_1101101;
 4'd6: seg_led1 = 9'b00_1111101;
 4'd7: seg_led1 = 9'b00_0000111;
 4'd8: seg_led1 = 9'b00_1111111;
 4'd9: seg_led1 = 9'b00_1101111;
 default: seg_led1 = 9'b00_0111111;
 endcase
 
 case(code_sw)
 4'd0: seg_led2 = 9'b00_0111111;
 4'd1: seg_led2 = 9'b00_0000110;
 4'd2: seg_led2 = 9'b00_1011011;
 4'd3: seg_led2 = 9'b00_1001111;
 4'd4: seg_led2 = 9'b00_1100110;
 4'd5: seg_led2 = 9'b00_1101101;
 4'd6: seg_led2 = 9'b00_1111101;
 4'd7: seg_led2 = 9'b00_0000111;
 4'd8: seg_led2 = 9'b00_1111111;
 4'd9: seg_led2 = 9'b00_1101111;
 default: seg_led2 = 9'b00_0111111;
 endcase

end



always @(posedge clk)  // 密码比较与结果显示
begin

if(!rst_n)             // 重置按键
begin
  error_cnt <= 2'b00;
  code_gw <= 4'b0000;
  code_sw <= 4'b0000;
  led <= 8'b11111111;
end

else if(ge_wei_d)      // 按下个位密码输入确认按键
begin
  code_gw <= SwitchInput;
end
else if(shi_wei_d)     // 按下十位密码输入确认按键
begin
  code_sw <= SwitchInput;
end

else if(confirm_d)     // 按下了输入完密码的确认按键
begin

 if(error_cnt != 2'd3)   // 判断错误次数 若错误次数小于3
 begin
   if((code_gw==N && code_sw==M) || (code_gw==N_new && code_sw==M_new))  
   begin
     led <= 8'b01111111;    // led[0]点亮
     error_cnt <= 2'd0;     
   end
 
   else
   begin
     led <= 8'b10111111;    // led[1]点亮
     error_cnt <= error_cnt + 1;
   end
 end
 
 else                // 判断错误次数 若错误次数大于3
 begin
   led<=8'b00000000;        // led全点亮 
 end
 
end
 
 
 
end
 
 
always@(posedge clk)     //修改密码
begin

if(!rst_n) flag <= 0;      // 按下重置按键 禁止修改密码

else if(led<=8'b01111111) flag <= 1;   // 说明led[0]点亮 密码正确 允许修改密码

if(flag==1 && shi_wei_d)
begin
  M_new <= SwitchInput;
end

else if(flag==1 && ge_wei_d)
begin
  N_new <= SwitchInput;
end

end
endmodule
 
 
 
 
