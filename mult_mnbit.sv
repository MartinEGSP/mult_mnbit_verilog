`timescale 1ns / 1ps

module and2_delay( //2-input AND 
    input  logic a, b,
    output logic y
);
    assign y = a & b;   //No delay
endmodule


module rca_Nbit_co #(parameter N = 4)( //N-bit RCA with cout (unsigned, parameterized)
    input  logic [N-1:0] A, B,
    input  logic cin,
    output logic [N-1:0] Sum,
    output logic co
);
    logic [N:0] carry;         //carry chain
    assign carry[0] = cin;

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : adder_loop
            // ADDED: full-adder behavior using assign          ALLOWED?
            assign {carry[i+1], Sum[i]} = A[i] + B[i] + carry[i];
        end
    endgenerate

    assign co = carry[N];      // ADDED: final carry-out
endmodule


//--------------------A.a Multiplier --------------------
module mult_mnbit #(parameter M = 4, parameter N = 4)(
    input  logic [M-1:0] A,
    input  logic [N-1:0] B,
    output logic [M+N-1:0] product   
);

    // Partial products
    logic [N-1:0][M-1:0] prod_terms; // FIXED: dimensioning corrected (MxN matrix)

    // ADDED: generate AND gates for all partial products
    genvar i, j;
    generate
        for (i = 0; i < N; i++) begin : B_loop
            for (j = 0; j < M; j++) begin : A_loop
                and2_delay u_and (
                    .a(A[j]),     // FIXED: swapped index order (A[j] with B[i])
                    .b(B[i]), 
                    .y(prod_terms[i][j])
                );
            end
        end
    endgenerate

    // Internal signals for chaining adders (still assumes N=4 style)
    logic [N-1:0] A0, B0, Sum0, A1, B1, Sum1, A2, B2, Sum2;
    logic co0, co1, co2;

    //1 adder
    assign product[0]   = prod_terms[0][0];        // FIXED: now matches "product"
    assign A0[N-1]      = 1'b0;
    assign A0[N-2:0]    = prod_terms[0][N-1:1];    // a3b0 a2b0 a1b0
    assign B0           = prod_terms[1];           // a3b1 a2b1 a1b1 a0b1
    rca_Nbit_co #(N) u1 (.A(A0), .B(B0), .cin(1'b0), .Sum(Sum0), .co(co0));

    //2 adder
    assign A1[N-1]      = co0;
    assign A1[N-2:0]    = Sum0[N-1:1];
    assign product[1]   = Sum0[0];
    assign B1           = prod_terms[2];
    rca_Nbit_co #(N) u2 (.A(A1), .B(B1), .cin(1'b0), .Sum(Sum1), .co(co1));

    //3 adder
    assign A2[N-1]      = co1;
    assign A2[N-2:0]    = Sum1[N-1:1];
    assign product[2]   = Sum1[0];
    assign B2           = prod_terms[3];
    rca_Nbit_co #(N) u3 (.A(A2), .B(B2), .cin(1'b0), .Sum(Sum2), .co(co2));

    //Final Outputs
    assign product[6:3] = Sum2; 
    assign product[7]   = co2;
endmodule
