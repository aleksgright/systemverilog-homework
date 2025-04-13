module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N = 50;

    logic [6:0] counter;
    logic [95:0] abc_array [0:N-1];
    logic [N-1:0] abc_vld_array;

    logic [31:0] res_array [0:N-1];
    logic [N-1:0] res_vld_array;

    genvar i;
    generate
        for(i=0; i < N; i++)     
            if (formula == 1)
                if (impl == 1)
                    formula_1_impl_1_top formula_top_i (
                        .clk(clk),
                        .rst(rst),

                        .arg_vld(abc_vld_array[i]),
                        .a(abc_array[i][31:0]),
                        .b(abc_array[i][63:32]),
                        .c(abc_array[i][95:64]),

                        .res_vld(res_vld_array[i]),
                        .res(res_array[i])
                    );
                else
                    formula_1_impl_2_top formula_top_i (
                        .clk(clk),
                        .rst(rst),

                        .arg_vld(abc_vld_array[i]),
                        .a(abc_array[i][31:0]),
                        .b(abc_array[i][63:32]),
                        .c(abc_array[i][95:64]),

                        .res_vld(res_vld_array[i]),
                        .res(res_array[i])
                    );
            else
                formula_2_top formula_top_i (
                        .clk(clk),
                        .rst(rst),

                        .arg_vld(abc_vld_array[i]),
                        .a(abc_array[i][31:0]),
                        .b(abc_array[i][63:32]),
                        .c(abc_array[i][95:64]),

                        .res_vld(res_vld_array[i]),
                        .res(res_array[i])
                    );
    endgenerate

    

    always_ff @(posedge clk)
        if (rst)
            counter <= '0;
        else
            if (arg_vld)
                counter <= (counter == N-1) ? 0 : (counter + 1'b1);

    always_ff @(posedge clk)
        if(rst)
            abc_vld_array <= N'(0);
        else 
            for (int j = 0; j < N; j++) 
                if (j==counter)
                    abc_vld_array[j] <= arg_vld;
                else
                    abc_vld_array[j] <= '0;

    always_ff @(posedge clk)
        for (int j = 0; j<N; j++)
            if (arg_vld && j == counter) begin
                abc_array[j][31:0] <= a;
                abc_array[j][63:32] <= b;
                abc_array[j][95:64] <= c;
            end

    logic [31:0] res_comb;
    assign res_vld = |res_vld_array;
    assign res = res_comb;
    always_comb
        for (int j = 0; j < N; j++)
            if (res_vld_array[j])
                res_comb = res_array[j];

endmodule
