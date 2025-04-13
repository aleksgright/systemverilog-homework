//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
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
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0
    logic [2:0] isqrt_vld;
    //logic [15:0] isqrt_out [2:0];
    logic [15:0] isqrt_a, isqrt_b, isqrt_c;

    isqrt isqrt1 (
        .clk           (clk),
        .rst           (rst),

        .x_vld     (arg_vld),
        .x               (a),

        .y_vld(isqrt_vld[0]),
        .y         (isqrt_a)
    );

    isqrt isqrt2 (
        .clk           (clk),
        .rst           (rst),

        .x_vld     (arg_vld),
        .x               (b),

        .y_vld(isqrt_vld[1]),
        .y         (isqrt_b)
    ); 

    isqrt isqrt3 (
        .clk           (clk),
        .rst           (rst),

        .x_vld     (arg_vld),
        .x               (c),

        .y_vld(isqrt_vld[2]),
        .y         (isqrt_c)
    );
    
    logic [31:0] res_comb;
    logic res_vld_comb;
    logic [31:0] sum_sqrt;
    assign sum_sqrt = isqrt_a + isqrt_b + isqrt_c;

    always_ff @(posedge clk) 
        if (rst)
            res_comb<='0;
        else
            if (&isqrt_vld)
                res_comb <= sum_sqrt;
    

    always_ff @(posedge clk) 
        if (rst)
            res_vld_comb<='0;
        else
            if (&isqrt_vld)
                res_vld_comb <= '1;
            else
                res_vld_comb <= '0;

    assign res_vld = res_vld_comb;
    assign res = res_comb;
         
endmodule
