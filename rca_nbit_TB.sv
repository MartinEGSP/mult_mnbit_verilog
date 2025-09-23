`timescale 1ns/1ps

module rca_nbit_TB;

    parameter N = 4;

    // DUT inputs
    reg  [N-1:0] a, b;
    reg          cin;


    // DUT outputs
    wire [N-1:0] sum;
    wire         cout;

    // Instantiate DUT
    rca_nbit #(N) dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    integer i, j, k;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, rca_nbit_TB);

        $display("  a   b  cin |  sum  cout");
        $display("--------------------------------");

        // Exhaustive test for all a, b, cin
      cin = 0;
        for (i = 0; i < (1<<N); i=i+1) begin
            for (j = 0; j < (1<<N); j=j+1) begin
                for (k = 0; k < 2; k=k+1) begin
                    a   = i;
                    b   = j;
                    #1; // let it settle

                  $display("%2d  %2d    %1d  |  %2d     %1d",
                        a, b, cin, sum, cout);
                end
            end
        end

        $display("RCA mux test completed.");
        $finish;
    end

endmodule
