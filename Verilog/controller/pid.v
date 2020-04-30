/*
//Pipelined
module add(output [31:0] out, input [31:0] in1, input [31:0] in2);
		assign out = in1 + in2;
endmodule


module mult(output [31:0] out, input [31:0] in1, input [31:0] in2);
	assign out = in1 * in2;
endmodule


module pid(out, error, clk, reset);
input [31:0] error;
input clk,reset;
output reg [31:0] out;

parameter kp=1, ki=0;

reg [31:0] a, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10;
wire [31:0]  out1, out2, out3, out4, out5;

mult u1(out1,ki,in2);
mult u2(out3,kp,in6);

add u3(out2,in3,in4);
add u4(out4, in7,in8);
add u5(out5, in9,in10);

always@(negedge clk)
begin
	if(reset)
	begin
		a <= 0;
		in1 <= 0;
		in2 <= 0;
		in3 <= 0;
		in4 <= 0;
		in5 <= 0;
		in6 <= 0;
		in7 <= 0;
		in8 <= 0;
		in9 <= 0;
		in10 <= 0;
	end
	else
	begin
		//u3
		//in3 <= -in;
		//in4 <= ref;

		//u1
		//in1 <= ki;
		in2 <= error;

		//u2
		//in5 <= kp;
		in6 <= error;
		a <= out3;

		//u4
		in7 <= out1;
		in8 <= out4;

		//u5
		in9 <= out4;
		in10 <= a;
		out <= out5;
	end
end
endmodule
*/


//Parallel
/*
module add(output [31:0] out, input [31:0] in1, input [31:0] in2);
		assign out = in1 + in2;
endmodule


module mult(output [31:0] out, input [31:0] in1, input [31:0] in2);
	assign out = in1 * in2;
endmodule


module pid(error, out, clk, reset);
input [31:0] error;
input clk,reset;
output wire [31:0] out;

parameter kp = 0, ki = 1;

//reg [7:0] a, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10;
wire [31:0]  out1, out3, out4;

reg [31:0] a, out2;

//add u3(out2,-in,ref);

mult u1(out1,ki,out2);
mult u2(out3,kp,out2);

add u4(out4, out1,a);
add u5(out, out4,out3);
always@(negedge clk)
if (reset == 1) begin
	a <= 0;
	out2 <= 0;
	end
else begin
	a <= out4;
	out2 <= error;
	end
endmodule
*/


//
module pid #(parameter Ki=32'sb0001_0000_0000_0000_0000_0000_0000_0000, Kp=32'sb0001_0000_0000_0000_0000_0000_0000_0000,
Vmin = 32'sb0000_0000_0001_0000_0000_0000_0000_0000, Vmax = 32'sb0100_0000_0000_0000_0000_0000_0000_0000) 
(output reg signed [31:0] vc, input signed [31:0] xref, input signed [31:0] xf, input rst, input clk);

reg Kclamp;
wire signed [31:0] cont, i, p;
reg signed [31:0] epi, vint, vcont;

mult u1 (Ki,Kclamp,cont);
qmult u2 (cont,epi,i);
qmult u3 (Kp,epi,p);

always@(posedge clk)
	if (rst)begin
		vint = 32'sd0;
		Kclamp = 1'b1;
		epi = 32'sd0;
	end
	
	else begin
	epi = xref - xf;

    vint = vint + i;
    
    vcont = vint + p;
    
    if(vcont>=Vmax)
        vc = Vmax;
    else if (vcont <= Vmin)
        vc = Vmin;
    else
        vc = vcont;
        
    if ((vc < Vmax) && (vc > Vmin))
        Kclamp = 1'b1;
    else
        Kclamp = 1'b0;
	end
   
endmodule


//xf 0000_0000_1000_0000_0000_0000_0000_0000
//xref 0000_0001_0000_0000_0000_0000_0000_0000

module mult(input signed [31:0] a, input b, output reg signed [31:0] c);
always@(a, b) begin
	c <= a*b;
	end
endmodule

module qmult #(
	//Parameterized values
	parameter Q = 28,
	parameter N = 32
	)
	(
	 input			[N-1:0]	i_multiplicand,
	 input			[N-1:0]	i_multiplier,
	 output			[N-1:0]	o_result
	 );
	 
	reg ovr;
  reg [N-1:0] multiplicand, multiplier, RetVal;
  
	 //	The underlying assumption, here, is that both fixed-point values are of the same length (N,Q)
	 //		Because of this, the results will be of length N+N = 2N bits....
	 //		This also simplifies the hand-back of results, as the binimal point 
	 //		will always be in the same location...
	
	reg [2*N-1:0]	r_result;		//	Multiplication by 2 values of N bits requires a 
											//		register that is N+N = 2N deep...
	reg [N-1:0]		r_RetVal;
	
//--------------------------------------------------------------------------------
	assign o_result = r_RetVal;	//	Only handing back the same number of bits as we received...
											//		with fixed point in same location...
	
//---------------------------------------------------------------------------------
	always @(i_multiplicand, i_multiplier)	begin						//	Do the multiply any time the inputs change
      
      ///////////////////////////////////////////////
      if (i_multiplicand[N-1] == 1) begin
        multiplicand = ~i_multiplicand + 1;
        multiplicand[N-1] = 1;
      end
      else
        multiplicand = i_multiplicand;
      
      if (i_multiplier[N-1] == 1) begin
        multiplier = ~i_multiplier + 1;
        multiplier[N-1] = 1;
      end
      else
        multiplier = i_multiplier;
      ////////////////////////////////////////////////
      	 
      r_result = multiplicand[N-2:0] * multiplier[N-2:0];	//	Removing the sign bits from the multiply - that 
																					//		would introduce *big* errors	
		ovr = 1'b0;															//	reset overflow flag to zero
		end
	
		//	This always block will throw a warning, as it uses a & b, but only acts on changes in result...
	always @(r_result) begin													//	Any time the result changes, we need to recompute the sign bit,
		RetVal[N-1] = multiplicand[N-1] ^ multiplier[N-1];	//		which is the XOR of the input sign bits...  (you do the truth table...)
		RetVal[N-2:0] = r_result[N-2+Q:Q];								//	And we also need to push the proper N bits of result up to 
																						//		the calling entity...
     
      if (RetVal[N-1] == 1) begin
        RetVal[N-1] = 0;
        r_RetVal = ~RetVal +1;
      end
      else
        r_RetVal = RetVal;
      
      if (r_result[2*N-2:N-1+Q] > 0)										// And finally, we need to check for an overflow
			ovr <= 1'b1;
		end

endmodule

