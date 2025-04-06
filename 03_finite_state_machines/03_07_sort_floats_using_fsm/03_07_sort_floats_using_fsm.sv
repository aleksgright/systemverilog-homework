//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    logic [0:2][FLEN - 1:0] array;

    wire [3:0] x;
    wire [3:0] y;
    wire [3:0] ans;
    assign x = 4'b101x;
    assign y = 4'b0001;
    assign ans = x + y;
    
    enum logic [2:0] {
        idle = 'b000,
        first_comparison = 'b001,
        second_comparison = 'b010,
        third_comparison = 'b011,
        array_sorted = 'b100, 
        error = 'b101
    } state, new_state;

    always_comb
    begin
        new_state = state;
        case (state)
            idle:begin 
                if (valid_in)
                    new_state = first_comparison;
                else 
                    new_state = idle;
            end
            
            first_comparison: 
                if (f_le_err)
                    new_state = error;
                else
                    new_state = second_comparison;

            second_comparison: 
                if (f_le_err)
                    new_state = error;
                else
                    new_state = third_comparison;

            third_comparison:
                if (f_le_err)
                    new_state = error;
                else
                    new_state = array_sorted;

            array_sorted: 
                new_state = idle;

            error:
                new_state = idle;
        endcase
    end

    always_comb 
    begin
        f_le_a = '0;
        f_le_b = '0;

        case (state)
            idle: 
                if (valid_in) begin
                    sorted = unsorted;
                    array = unsorted;
                    f_le_a = sorted[0];
                    f_le_b = sorted[1];
                end

            first_comparison: 
                if (~f_le_res) begin
                    array = {sorted[1], sorted[0], sorted[2]};
                    f_le_a = sorted[0];
                    f_le_b = sorted[2];
                end
                else begin
                    array = sorted;
                    f_le_a = sorted[1];
                    f_le_b = sorted[2];
                end
            

            second_comparison: 
                if (~f_le_res) begin
                    array = {sorted[0], sorted[2], sorted[1]};
                    f_le_a = sorted[0];
                    f_le_b = sorted[2];
                end
                else begin
                    array = sorted;
                    f_le_a = sorted[0];
                    f_le_b = sorted[1];
                end
            

            third_comparison:
                if (~f_le_res)
                    array = {sorted[1], sorted[0], sorted[2]};
                else
                    array = sorted;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst)
            state <= idle;
        else
            state <= new_state;

    always_ff @(posedge clk)
        if(rst)
            sorted<='0;
        else
            sorted<=array;

    always_ff @ (posedge clk)
        if (rst)
            err <= '0;
        else
            err <= (state == error);

    always_ff @ (posedge clk)
        if (rst) 
            valid_out <= '0;
        else
            valid_out <= (state == array_sorted | state == error);

endmodule
