//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe # (parameter width = 32)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [width-1:0] a,
    input  [width-1:0] b,
    input  [width-1:0] c,

    output        res_vld,
    output [width-1:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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

    parameter ISQRT_LATENCY = 16;
    logic [width-1:0] isqrt1_out, isqrt2_out, isqrt3_out;
    logic isqrt1_vld, isqrt2_vld, isqrt3_vld;

    logic [width-1:0] shift_register_n_depth_out, shift_register_2n1_depth_out;
    logic shift_register_n_depth_vld, shift_register_2n1_depth_vld;

    logic [width-1:0] sum_1;
    logic sum_1_vld;

    logic sum_2_vld;
    logic [width-1:0] sum_2;

    isqrt #(.n_pipe_stages(ISQRT_LATENCY)) isqrt1 (
        .clk          (clk),
        .rst          (rst),

        .x_vld    (arg_vld),
        .x              (c),

        .y_vld (isqrt1_vld),
        .y     (isqrt1_out)
    );

    isqrt # (.n_pipe_stages(ISQRT_LATENCY) ) isqrt2 (
        .clk          (clk),
        .rst          (rst),

        .x_vld  (sum_1_vld),
        .x          (sum_1),

        .y_vld (isqrt2_vld),
        .y     (isqrt2_out)
    ); 

    isqrt # (.n_pipe_stages(ISQRT_LATENCY) ) isqrt3 (
        .clk         (clk),
        .rst         (rst),

        .x_vld (sum_2_vld),
        .x         (sum_2),

        .y_vld   (res_vld),
        .y           (res)
    );

    shift_register_with_valid # (.width(width), .depth(ISQRT_LATENCY)) shift_register_n_depth
    (
        .clk                            (clk),
        .rst                            (rst),

        .in_vld                     (arg_vld),
        .in_data                          (b),

        .out_vld (shift_register_n_depth_vld),
        .out_data(shift_register_n_depth_out)
    );

    shift_register_with_valid # (.width(width), .depth(2*ISQRT_LATENCY+1)) shift_register_2n1_depth
    (
        .clk                              (clk),
        .rst                              (rst),

        .in_vld                       (arg_vld),
        .in_data                            (a),

        .out_vld (shift_register_2n1_depth_vld),
        .out_data(shift_register_2n1_depth_out)
    );

    always_ff @(posedge clk) 
        if (rst)    begin
            sum_1_vld <= '0;
            sum_2_vld <= '0;
        end
        else begin
            sum_1_vld <= isqrt1_vld;
            sum_2_vld <= isqrt2_vld;
        end

    always_ff @(posedge clk)
        begin
        if (isqrt1_vld)
            sum_1 <= isqrt1_out + shift_register_n_depth_out;
        if (isqrt2_vld)
            sum_2 <= isqrt2_out + shift_register_2n1_depth_out;
        end

endmodule
