`timescale 1ns / 1ps

//----------------------------- Building blocks ------------------------------
module and2_delay( //2-input AND
   input  logic a, b,
   output logic y
);
   assign y = a & b;   // No delay
endmodule

module nand2_delay( //2-input NAND
   input  logic a, b,
   output logic y
);
   assign y = ~(a & b); 
endmodule

module nand3_delay( //3-input NAND
   input  logic a, b, c,
   output logic y
);
  assign y = ~(a & b & c); 
endmodule

module nand4_delay( //4-input NAND
   input  logic a, b, c, d,
   output logic y
);
  assign y = ~(a & b & c & d); 
endmodule


module rca_Nbit_co #(parameter N = 4)( // General N-bit RCA with cout
   input  logic [N-1:0] a, b,
   input  logic cin,
   output logic [N-1:0] sum,
   output logic co
);
   logic [N:0] carry;        
   assign carry[0] = cin;


   genvar i;
   generate
       for (i = 0; i < N; i++) begin : adder_loop
           assign {carry[i+1], sum[i]} = a[i] + b[i] + carry[i];
       end
   endgenerate


   assign co = carry[N];
endmodule




//----------------------------- Task A.a -----------------------------------
// Generalized unsigned MxN multiplier
module mult_mnbit #(parameter M = 4, parameter N = 4)(
   input  logic [M-1:0] a,
   input  logic [N-1:0] b,
   output logic [M+N-1:0] product
);
   // Partial products
   logic [N-1:0][M-1:0] prod_terms;
   genvar i, j;
   generate
       for (i = 0; i < N; i++) begin : b_loop
           for (j = 0; j < M; j++) begin : a_loop
               assign prod_terms[i][j] = a[j] & b[i];
           end
       end
   endgenerate


   // Intermediate sums
   logic [M+N-1:0] sum   [N:0]; 
   assign sum[0] = {{(M){1'b0}}, prod_terms[0]}; // row 0


   generate
       for (i = 1; i < N; i++) begin : add_loop
           logic [M+N-1:0] shifted_row;
           // shift partial product row by i
           assign shifted_row = {{(M+N-M-i){1'b0}}, prod_terms[i], {i{1'b0}}};
           assign sum[i] = sum[i-1] + shifted_row;  // addition (could use rca_Nbit_co too)
       end
   endgenerate


   assign product = sum[N-1];
endmodule




//----------------------------- Task A.b -----------------------------------
// Signed multiplier: extend unsigned version to signed numbers
module mult_mnbit_signed #(parameter M = 4, parameter N = 4)(
   input  logic signed [M-1:0] a,
   input  logic signed [N-1:0] b,
 output logic signed [M+N-1:0] product // NOTE: wider than unsigned
);
   // Step 1: detect if inputs are negative
   logic sign_a, sign_b;
   assign sign_a = a[M-1];
   assign sign_b = b[N-1];


   // Step 2: get absolute values
   logic [M-1:0] abs_a;
   logic [N-1:0] abs_b;
   assign abs_a = sign_a ? (~a + 1'b1) : a; 
   assign abs_b = sign_b ? (~b + 1'b1) : b;


   // Step 3: multiply magnitudes using unsigned multiplier
   logic [M+N-1:0] unsigned_product;
   mult_mnbit #(M, N) u_mult (
       .a(abs_a),
       .b(abs_b),
       .product(unsigned_product)
   );


   // Step 4: fix the sign of the result
   always_comb begin
       if (sign_a ^ sign_b) 
           product = -unsigned_product;  // negate magnitude
       else
           product = unsigned_product;
   end
endmodule




//----------------------------- Task A.c -----------------------------------
// Multiply-Accumulate: x = a0*a1 + a2*a3 + a4*a5 + a6*a7
module mult_add #(parameter W = 4)(
   input  logic signed [W-1:0] a0, a1, a2, a3, a4, a5, a6, a7,
   output logic signed [2*W+2:0] x   // wide enough for 4 products
);
   // Intermediate products
   logic signed [2*W-1:0] p0, p1, p2, p3;


   // Use signed multipliers (A.b)
   mult_mnbit_signed #(W, W) m0 (.a(a0), .b(a1), .product(p0));
   mult_mnbit_signed #(W, W) m1 (.a(a2), .b(a3), .product(p1));
   mult_mnbit_signed #(W, W) m2 (.a(a4), .b(a5), .product(p2));
   mult_mnbit_signed #(W, W) m3 (.a(a6), .b(a7), .product(p3));


   // Add them together
   always_comb begin
       x = p0 + p1 + p2 + p3;
   end
endmodule






//--------------------B. Multiplexers------------------
	module full_adder_mux( //Generic mux structure
      input  logic a, b, cin,
      output logic sum, cout
	);
    //(a,b) = select
    logic [1:0] sel;
    assign sel = {a,b};

    // sum = mux4to1(cin, ~cin, ~cin, cin)
    mux4to1_slice mux_sum (
        .a(cin),    // sel=00
        .b(~cin),   // sel=01
        .c(~cin),   // sel=10
        .d(cin),    // sel=11
        .s(sel),
        .y(sum)
    );

    // cout = mux4to1(0, cin, cin, 1)
    mux4to1_slice mux_cout (
        .a(1'b0),   // sel=00
        .b(cin),    // sel=01
        .c(cin),    // sel=10
        .d(1'b1),   // sel=11
        .s(sel),
        .y(cout)
    );
    endmodule

	module mux4to1_slice( 
    input  logic a,
    input  logic b,
    input  logic c,
    input  logic d,
    input  logic [1:0] s,
    output logic y
);
    logic u1_out, u2_out, u3_out, u4_out;
    logic s0, s1, s0_inv, s1_inv;

    assign s0 = s[0];
    assign s1 = s[1];

    nand2_delay inv0 (.a(s0), .b(s0), .y(s0_inv));
    nand2_delay inv1 (.a(s1), .b(s1), .y(s1_inv));
    nand3_delay U1 (.a(a), .b(s0_inv), .c(s1_inv), .y(u1_out));
    nand3_delay U2 (.a(b), .b(s0),    .c(s1_inv), .y(u2_out));
    nand3_delay U3 (.a(c), .b(s0_inv), .c(s1),    .y(u3_out));
    nand3_delay U4 (.a(d), .b(s0),    .c(s1),    .y(u4_out));
    nand4_delay U5 (.a(u1_out), .b(u2_out), .c(u3_out), .d(u4_out), .y(y));
	endmodule


    module rca_nbit #(parameter N = 4)(
        input  logic [N-1:0] a,
        input  logic [N-1:0] b,
        input  logic cin,
        output logic [N-1:0] sum,
        output logic cout
    );
        logic [N:0] carry;
        assign carry[0] = cin;

        genvar i;
        generate
            for (i = 0; i < N; i++) begin : adder_loop
                full_adder_mux fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i]),
                    .sum(sum[i]),
                    .cout(carry[i+1])
                );
            end
        endgenerate

        assign cout = carry[N];
    endmodule



//--------------------C. Shifter and rotator------------------
module shifter_rotator(
    input  logic [3:0] x,
    input  logic [1:0] select,
    output logic [3:0] y
);

    always_comb begin
        case (select)
            2'b00: y = x << 1;                   // Shift left
            2'b01: y = x >> 1;                   // Shift right
            2'b10: y = {x[2:0], x[3]};           // Rotate left
            2'b11: y = {x[0], x[3:1]};           // Rotate right
            default: y = 4'b0000;
        endcase
    end

endmodule
