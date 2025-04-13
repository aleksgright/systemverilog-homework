//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);

    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0


    enum logic [2:0] {
        idle = 'b000,
        first_passed = 'b001,
        second_passed = 'b010,
        third_passed = 'b011,
        first_vld = 'b100,
        second_vld = 'b101,
        third_vld = 'b110
    } state, new_state;

    always_comb begin
        new_state = state;
        case (state)
            idle: if (arg_vld) new_state = first_passed;

            first_passed: new_state = second_passed;

            second_passed: new_state = third_passed;

            third_passed: if (isqrt_y_vld) new_state = first_vld;

            first_vld: new_state = second_vld;

            second_vld: new_state = third_vld;

            third_vld: new_state = idle;

        endcase
    end

    always_comb begin
        isqrt_x_vld = '0;
        isqrt_x = '0;

        case (state)
            idle: 
                if (arg_vld) begin
                    isqrt_x_vld = '1;
                    isqrt_x = a;
                end

            first_passed: begin
                isqrt_x_vld = '1;
                isqrt_x = b;
            end

            second_passed: begin
                isqrt_x_vld = '1;
                isqrt_x = c;
            end
        endcase
    end


    always_ff @(posedge clk)
        if (rst)
            state<=idle;
        else
            state <= new_state;
    
    always_ff @(posedge clk)
        if (rst)
            res<='0;
        else
            if (isqrt_y_vld)
                res <= res + isqrt_y;
            else if (state == idle)
                res <= '0;

    always_ff @(posedge clk)
        if (rst)
            res_vld<='0;
        else
            res_vld<= state == third_vld;

endmodule
