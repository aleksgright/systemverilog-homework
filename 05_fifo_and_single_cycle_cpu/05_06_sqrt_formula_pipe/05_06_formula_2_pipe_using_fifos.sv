//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
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
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
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
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 04_10_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    localparam width = 32;
    localparam ISQRT_LATENCY = 16;

    logic [width-1:0] isqrt_c_out, isqrt_b_out;
    logic isqrt_c_vld, isqrt_b_vld, isqrt_a_vld;

    logic [width-1:0] fifo_b_out, fifo_a_out;

    logic sum_1_vld;
    logic [width-1:0] sum_1;

    logic sum_2_vld;
    logic [width-1:0] sum_2;

    flip_flop_fifo_with_counter # (.width(width), .depth(ISQRT_LATENCY))
    fifo_b (
        .clk(clk),
        .rst(rst),
        .push(arg_vld),
        .pop(isqrt_c_vld),
        .write_data(b),
        .read_data(fifo_b_out),
        .empty(),
        .full()
    );

    flip_flop_fifo_with_counter # (.width(width), .depth(ISQRT_LATENCY * 2 + 1))
    fifo_a (
        .clk(clk),
        .rst(rst),
        .push(arg_vld),
        .pop(isqrt_b_vld),
        .write_data(a),
        .read_data(fifo_a_out),
        .empty(),
        .full()
    );    

    isqrt #(.n_pipe_stages(ISQRT_LATENCY)) isqrt1 (
        .clk          (clk),
        .rst          (rst),

        .x_vld    (arg_vld),
        .x              (c),

        .y_vld (isqrt_c_vld),
        .y     (isqrt_c_out)
    );

    isqrt # (.n_pipe_stages(ISQRT_LATENCY) ) isqrt2 (
        .clk          (clk),
        .rst          (rst),

        .x_vld  (sum_1_vld),
        .x          (sum_1),

        .y_vld (isqrt_b_vld),
        .y     (isqrt_b_out)
    ); 

    isqrt # (.n_pipe_stages(ISQRT_LATENCY) ) isqrt3 (
        .clk         (clk),
        .rst         (rst),

        .x_vld (sum_2_vld),
        .x         (sum_2),

        .y_vld   (res_vld),
        .y           (res)
    );


    always_ff @(posedge clk) 
        if (rst)    begin
            sum_1_vld <= '0;
            sum_2_vld <= '0;
        end
        else begin
            sum_1_vld <= isqrt_c_vld;
            sum_2_vld <= isqrt_b_vld;
        end

    always_ff @(posedge clk)
        begin
        if (isqrt_c_vld)
            sum_1 <= isqrt_c_out + fifo_b_out;
        if (isqrt_b_vld)
            sum_2 <= isqrt_b_out + fifo_a_out;
        end

endmodule
