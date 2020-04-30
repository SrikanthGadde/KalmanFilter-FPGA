`timescale 1ps/1ps
//`include "../18.1/quartus/eda/sim_lib/altera_mf.v"
module mult (output[31:0] c1, output[31:0] c2, output[31:0] c3, output[31:0] c4, 
    input [31:0] q, input [31:0] w, input [31:0] e, input [31:0] r, 
    input [31:0] u, input [31:0] i, input [31:0] o, input [31:0] p);
    assign c1 = q*u;
    assign c2 = w*i;
    assign c3 = e*o;
    assign c4 = r*p;
endmodule

module add (output [31:0] c, input [31:0] c1, input [31:0] c2, input [31:0] c3, input [31:0] c4);
    assign c = c1+c2+c3+c4;
endmodule

module mat_mult (output [31:0] out,
	input [31:0] a1, input [31:0] a2, input [31:0] a3, input [31:0] a4,
	input [31:0] b1, input [31:0] b2, input [31:0] b3, input [31:0] b4);
	
	wire [31:0] c1,c2,c3,c4;
	
    mult u2(c1,c2,c3,c4,a1,a2,a3,a4,b1,b2,b3,b4);
    add u3(out,c1,c2,c3,c4);
	
endmodule

module top (a, b, reset, clock);
	input reset, clock;
	output wire [31:0] a, b;
    
    reg [31:0] q, w, e, r, u, i, o, p;
    wire [31:0] c;
	 
    mat_mult u1(c, q, w, e, r, u, i, o, p);
    
    reg [5:0] address_a, address_b;
    reg [31:0] data_a, data_b;
    reg wren_a, wren_b;
    
    wire [31:0] q_a, q_b;
    
    assign a=q_a;
    assign b=q_b;
    
    ram uut(address_a, address_b, clock, data_a, data_b, wren_a, wren_b, q_a, q_b);
    
    reg [31:0] c1,c2;
    integer S,NS;
    
	always@(posedge clock)
	begin
	if(reset) begin
		S<=0;
	end
	else begin
		S<=NS;
	end
	end
	
	always@(S)
	begin
	case(S)
	0:  begin           //A11,A12 address
        address_a = 6'b000000;
        address_b = 6'b000001;
        wren_a = 1'b0;
        wren_b = 1'b0;
		
		NS = 1;
		end
	1:	begin           //A13, A14 address        
        address_a = 6'b000010;
        address_b = 6'b000011;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        NS=2;
        end
	2:	begin           //B11, B21 address
        address_a = 6'b010000;
        address_b = 6'b010100;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        q=q_a;
        w=q_b;
        
        NS=3;
        end
	3:	begin           //B31, B41 address
        address_a = 6'b011000;
        address_b = 6'b011100;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        e=q_a;
        r=q_b;
        
        NS=4;
        end
	4:	begin           //B12, B22 address
        address_a = 6'b010001;
        address_b = 6'b010101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        NS=5;
        end
   5: begin             //B32, B42 address
        address_a = 6'b011001;
        address_b = 6'b011101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
		//Calculate C11
        //#10
        //c1=c;
        
        NS=6;
        end
   6:	begin           //B13, B23 address
        address_a = 6'b010010;
        address_b = 6'b010110;
        wren_a = 1'b0;
        wren_b = 1'b0;
		
        c1=c;
        
        u=q_a;
        i=q_b;
        
        NS=7;
        end
	7:	begin           //B33, B43 address
        address_a = 6'b011010;
        address_b = 6'b011110;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        //Calculate C12
        //#10
        //c2=c;
        
        NS=8;
        end
	8:	begin           //B14, B24
        address_a = 6'b010011;
        address_b = 6'b010111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        c2=c;
        
        NS=9;
        end
	9:	begin           //B34, B44
        address_a = 6'b011011;
        address_b = 6'b011111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        NS=10;
        end
	10:	begin           //C11, C12
        address_a = 6'b100000;
        address_b = 6'b100001;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;

        u=q_a;
        i=q_b;
        
		c1=c;
        
		NS=11;
		end
	11:	begin           //A21, A22
        address_a = 6'b000100;
        address_b = 6'b000101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;		
        
        NS=12;
		end
   12:	begin           //A23, A24
        address_a = 6'b000110;
        address_b = 6'b000111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        c2 = c;
        
        NS=13;
        end
    13: begin           //C13, C14
        address_a = 6'b1000010;
        address_b = 6'b1000011;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;
        
        q=q_a;
        w=q_b;
        
        NS = 14;
        end
	14:	begin           //B11, B21 address
        address_a = 6'b010000;
        address_b = 6'b010100;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        e=q_a;
        r=q_b;
        
        NS=15;
        end
	15:	begin           //B31, B41 address
        address_a = 6'b011000;
        address_b = 6'b011100;
        wren_a = 1'b0;
        wren_b = 1'b0;

        NS=16;
        end
	16:	begin           //B12, B22 address
        address_a = 6'b010001;
        address_b = 6'b010101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        NS=17;
        end
    17: begin             //B32, B42 address
        address_a = 6'b011001;
        address_b = 6'b011101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
		//Calculate C11
        //#10
        //c1=c;
        
        NS=18;
        end
    18:	begin           //B13, B23 address
        address_a = 6'b010010;
        address_b = 6'b010110;
        wren_a = 1'b0;
        wren_b = 1'b0;
		
        c1=c;
        
        u=q_a;
        i=q_b;
        
        NS=19;
        end
	19:	begin           //B33, B43 address
        address_a = 6'b011010;
        address_b = 6'b011110;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        //Calculate C12
        //#10
        //c2=c;
        
        NS=20;
        end
	20:	begin           //B14, B24
        address_a = 6'b010011;
        address_b = 6'b010111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        c2=c;
        
        NS=21;
        end
	21:	begin           //B34, B44
        address_a = 6'b011011;
        address_b = 6'b011111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        NS=22;
        end
	22:	begin           //C21, C22
        address_a = 6'b100100;
        address_b = 6'b100101;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;

        u=q_a;
        i=q_b;
        
		c1=c;
        
		NS=23;
		end
	23:	begin           //A31, A32
        address_a = 6'b001000;
        address_b = 6'b001001;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;		
        
        NS=24;
		end
   24:	begin           //A33, A34
        address_a = 6'b001010;
        address_b = 6'b001011;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        c2 = c;
        
        NS=25;
        end
    25: begin           //C23, C24
        address_a = 6'b1000110;
        address_b = 6'b1000111;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;
        
        q=q_a;
        w=q_b;
        
        NS = 26;
        end
	26:	begin           //B11, B21 address
        address_a = 6'b010000;
        address_b = 6'b010100;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        e=q_a;
        r=q_b;
        
        NS=27;
        end
	27:	begin           //B31, B41 address
        address_a = 6'b011000;
        address_b = 6'b011100;
        wren_a = 1'b0;
        wren_b = 1'b0;

        NS=28;
        end
	28:	begin           //B12, B22 address
        address_a = 6'b010001;
        address_b = 6'b010101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        NS=29;
        end
    29: begin             //B32, B42 address
        address_a = 6'b011001;
        address_b = 6'b011101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
		//Calculate C11
        //#10
        //c1=c;
        
        NS=30;
        end
    30:	begin           //B13, B23 address
        address_a = 6'b010010;
        address_b = 6'b010110;
        wren_a = 1'b0;
        wren_b = 1'b0;
		
        c1=c;
        
        u=q_a;
        i=q_b;
        
        NS=31;
        end
	31:	begin           //B33, B43 address
        address_a = 6'b011010;
        address_b = 6'b011110;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        //Calculate C12
        //#10
        //c2=c;
        
        NS=32;
        end
	32:	begin           //B14, B24
        address_a = 6'b010011;
        address_b = 6'b010111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        c2=c;    
        
        u=q_a;
        i=q_b;
        
        NS=33;
        end
	33:	begin           //B34, B44
        address_a = 6'b011011;
        address_b = 6'b011111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        NS=34;
        end
	34:	begin           //C31, C32
        address_a = 6'b101000;
        address_b = 6'b101001;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;
        
		c1=c;
        
        u=q_a;
        i=q_b;
        
		NS=35;
		end
	35:	begin           //A41, A42
        address_a = 6'b001100;
        address_b = 6'b001101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;		
        
        NS=36;
		end
   36:	begin           //A43, A44
        address_a = 6'b001110;
        address_b = 6'b001111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        c2 = c;
        
        NS=37;
        end
    37: begin           //C33, C34
        address_a = 6'b1001010;
        address_b = 6'b1001011;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;
        
        q=q_a;
        w=q_b;
        
        NS = 38;
        end
	38:	begin           //B11, B21 address
        address_a = 6'b010000;
        address_b = 6'b010100;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        e=q_a;
        r=q_b;
        
        NS=39;
        end
	39:	begin           //B31, B41 address
        address_a = 6'b011000;
        address_b = 6'b011100;
        wren_a = 1'b0;
        wren_b = 1'b0;

        NS=40;
        end
	40:	begin           //B12, B22 address
        address_a = 6'b010001;
        address_b = 6'b010101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        NS=41;
        end
    41: begin             //B32, B42 address
        address_a = 6'b011001;
        address_b = 6'b011101;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
		//Calculate C11
        //#10
        //c1=c;
        
        NS=42;
        end
    42:	begin           //B13, B23 address
        address_a = 6'b010010;
        address_b = 6'b010110;
        wren_a = 1'b0;
        wren_b = 1'b0;
		
        c1=c;
        
        u=q_a;
        i=q_b;
        
        NS=43;
        end
	43:	begin           //B33, B43 address
        address_a = 6'b011010;
        address_b = 6'b011110;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        //Calculate C12
        //#10
        //c2=c;
        
        NS=44;
        end
	44:	begin           //B14, B24
        address_a = 6'b010011;
        address_b = 6'b010111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        u=q_a;
        i=q_b;
        
        c2=c;
        
        NS=45;
        end
	45:	begin           //B34, B44
        address_a = 6'b011011;
        address_b = 6'b011111;
        wren_a = 1'b0;
        wren_b = 1'b0;
        
        o=q_a;
        p=q_b;
        
        NS=46;
        end
	46:	begin           //C41, C42
        address_a = 6'b101100;
        address_b = 6'b101101;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;

        u=q_a;
        i=q_b;
        
		c1=c;
        
		NS=47;
		end
	47:	begin
        o=q_a;
        p=q_b;		
        
        NS=48;
		end
   48:	begin
        c2 = c;
        
        NS=49;
        end
    49: begin           //C43, C44
        address_a = 6'b1001110;
        address_b = 6'b1001111;
        data_a = c1;
        data_b = c2;
        wren_a = 1'b1;
        wren_b = 1'b1;
        end
    endcase
	end

endmodule
