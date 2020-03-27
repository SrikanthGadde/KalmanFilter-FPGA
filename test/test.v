module test(num, clk, rst ,sqrt);
	input clk, rst;
	output reg [15:0] sqrt;
	 input [31:0] num;  //declare input
    //intermediate signals.
    reg [31:0] a;
    reg [15:0] q;
    reg [17:0] left,right,r;    
    reg [4:0] i;
	always@(posedge clk)
	begin
	if(rst ==  1'b1)
	begin
    a <= num;
    q = 0;
    i <= 0;
    left <= 0;   //input to adder/sub
    right <= 0;  //input to adder/sub
    r <= 0;  //remainder
    //run the calculations for 16 iterations.
	 i <= 'b0;
	  end
	  else
	  begin
	 casez (i)
		5'b0????: begin 
        right = {q,r[17],1'b1};
        left = {r[15:0],a[31:30]};
        a = {a[29:0],2'b00};    //left shift by 2 bits.
        if (r[17] == 1) //add if r is negative
            r = left + right;
        else    //subtract if r is positive
            r = left - right;
        q = {q[14:0],!r[17]};   
		  i = i + 'b1;
		  end
		  
	endcase	
		end
    sqrt = q;   //final assignment of output.
	 end
endmodule
