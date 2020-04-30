
/*
1/sqrt(3) = 0000_1001_0011_1100_1101_0011_1010_0010

sqrt(3)/2 = 0000_1101_1101_1011_0011_1101_0111_0100‬

-1/sqrt(3) = 1111_0110_1100_0011_0010_1100_0101_1110

-sqrt(3)/2 = 1111_0010_0010_0100_1100_0010_1000_1100

1/3 = 55555;
2/3 = aaaaa;
*/

module mem (output [31:0] sin, output [31:0] cos, input clock, input [31:0] theta);

wire [7:0] address_a, address_b;

assign address_a = theta*0.708;
assign address_b = address_a + 8'h40;

//Add LUT
lut	lut_inst (
	address_a,
	address_b,
	clock,
	sin,
	cos);

endmodule



module park (output [31:0] d, output [31:0] q, input [31:0] alpha, input [31:0] beta, input [31:0] sin, input [31:0] cos);
wire [31:0] alpha_sin, alpha_cos, beta_sin, beta_cos;

qmult u1 (alpha, cos, alpha_cos);
qmult u2 (alpha, sin, alpha_sin);

qmult u3 (beta, cos, beta_cos);
qmult u4 (beta, sin, beta_sin);

assign d = alpha_cos + beta_sin;
assign q = -alpha_sin + beta_cos;
endmodule


module clarke (output [31:0] alpha, output [31:0] beta, input [31:0] a, input [31:0] b, input [31:0] c);
wire [31:0] alpha_a,alpha_b,alpha_c;
wire [31:0] beta_b,beta_c;

qmult u1 (a,32'h0aaaaaaa,alpha_a);		//a*2/3
qmult u2 (-b,32'b0000_1001_0011_1100_1101_0011_1010_0010,alpha_b);		//b*-1/3
qmult u3 (-c,32'b0000_1001_0011_1100_1101_0011_1010_0010,alpha_c);		//c*-1/3

assign alpha = alpha_a + alpha_b + alpha_c;

qmult u4 (b,32'b0000_1001_0011_1100_1101_0011_1010_0010,beta_b);		//b*1/sqrt(3)
qmult u5 (-c,32'b0000_1001_0011_1100_1101_0011_1010_0010,beta_c);		//c*-1/sqrt(3)

assign beta = beta_b + beta_c;
endmodule


module parkClarkeInverse(output [31:0] a, output [31:0] b, output [31:0] c, input [31:0] d, input [31:0] q, input [31:0] sin, input [31:0] cos);
wire [31:0] d_sin, q_sin, d_cos, q_cos;

qmult	u1 (d, sin, d_sin);
qmult u2 (d, cos, d_cos);
qmult u3 (q, sin, q_sin);
qmult u4 (q, cos, q_cos);

wire [31:0] z;

wire [31:0] alpha, beta_2;

assign a = d_cos - q_sin;

assign alpha = d_sin + q_cos;

assign beta_2 = a>>1;

qmult u5 (alpha,32'b0000_1101_1101_1011_0011_1101_0111_0100,z);

assign b = z - beta_2;
assign c = -(z+beta_2);
endmodule


module ccct(output [31:0] x, output [31:0] y, output [31:0] z, input [31:0] a, input [31:0] b, input [31:0] c, input [31:0] sin, input [31:0] cos);
wire [31:0] alpha, beta, d, q;

//TODO: Add LUT

//Clarke
clarke u1 (alpha, beta, a, b, c);

//Park
park u2 (d, q, alpha, beta, sin, cos);

//TODO: PI speed controller

// Park and Clarke Inverse
parkClarkeInverse u3 (x, y, z, d, q, sin, cos);
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////

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
