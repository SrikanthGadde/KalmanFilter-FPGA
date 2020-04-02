module top(A,B,clk,reset,Out);

//input [7:0] A1, A2, A3, B1, B2, B3;
input clk, reset;
output wire [7:0] Out;

integer i;

reg [7:0] a,b,c,d;
input [7:0] A,B;
reg S;

function [15:0] sop;
	input [7:0] A;
	input [7:0] B;
	input [1:0] S;
	
	reg [7:0] out;
begin
case(S)
0:	begin
	b = a+b;
	a = A*B;
	end
1: out = b;
endcase
sop = {out};
end
endfunction

assign {Out} = sop(A,B,S);

always@(negedge clk)
begin
if(reset == 1) begin
	S <= 0;
	i<= 0;
	end
else 
	i <= i+1;
	if(i==1)
		S <= S + 1;	
	
	//Out = ((A1*B1)+(A2*B2))+(A3*B3);

end
endmodule
