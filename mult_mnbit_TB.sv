`timescale 1ns / 1ps
module mult_mnbit_TB;
    parameter M=4, N=4; 
    
    logic [M-1:0] A, B;
    logic [M+N-1:0] Product;

    // Instantiate DUT
    mult_mnbit #(M, N) dut (.A(A), .B(B), .product(Product));

    initial begin
        // Header
        $display("Time\tA\tB\t|\tProduct");
        $display("--------------------------------");

        // Unsigned tests
        A = 1;  B = 6;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        A = 0;  B = 6;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        A = 1;  B = 6;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        A = 0;  B = 0;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        A = 4;  B = 2;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        A = 5;  B = 5;  #10;
        $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);

        $finish;
    end
endmodule

/* //Runs from 0 0 to 15 15 and multiplies them
`timescale 1ns / 1ps
module mult_mnbit_TB;
    parameter M=4, N=4; 
    
    logic [M-1:0] A, B;
    logic [M+N-1:0] Product;

    // Instantiate DUT
    mult_mnbit #(M, N) dut (.A(A), .B(B), .product(Product));

   integer i, j; // loop counters

    initial begin
        // Header
        $display("Time\tA\tB\t|\tProduct");
        $display("--------------------------------");

        // Exhaustive test: all input combinations
        for (i = 0; i < (1<<M); i = i + 1) begin
            for (j = 0; j < (1<<N); j = j + 1) begin
                A = i;
                B = j;
                #1; // wait 1 time unit
                $display("%4t\t%d\t%d\t|\t%d", $time, A, B, Product);
            end
        end

        $display("Exhaustive test completed.");
        $finish;
    end
endmodule

*/
