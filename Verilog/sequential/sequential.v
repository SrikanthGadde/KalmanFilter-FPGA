module sequential (output reg [31:0] out, input [31:0] a, input [31:0] b, input [31:0] c, input [31:0] d, input clk, input rst);

reg [31:0] w,e,t,y;

wire [31:0] q, r;

reg [3:0] s, ns; //state, next state

add u1 (q, w,e); //o,i,i

mult u2 (r, t,y); //o,i,i

reg [31:0] u,i,o,p;

always@(posedge clk)
begin
    if (rst) begin
        w = 0;
		  e = 0;
		  t =0;
		  y = 0;
		  
		  u = 0;
		  i = 0;
        s <= 2'b00;
        //ns <= 2'b00;
    end
    else begin
        s <= ns;
    end
end

always@(*)
begin
case(s)
	2'b00:	begin
				ns <= 2'b01;
				end
    2'b01:  begin
            t = a;
            y = b;
            
            ns = 2'b10;
            end
    2'b10:  begin
				u = r;
				
            t = u;
            y = c;
            #1
				//i = r;

            w = d;
            e = i;
            #1
			out = q;
            ns <= 2'b00;
            end

endcase
end
endmodule

module add(output [31:0] out, input [31:0] in1, input [31:0] in2);
		assign out = in1 + in2;
endmodule

module mult(output [31:0] out, input [31:0] in1, input [31:0] in2);
	assign out = in1 * in2;
endmodule