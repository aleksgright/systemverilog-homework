module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.

    logic [$clog2(n_inputs)-1:0] counter;

    logic [width-1:0] data_array [0:n_inputs-1];
    logic [n_inputs-1:0] vld_array;
    logic [n_inputs-1:0] present;

    logic [width-1:0] look_ahead;
    logic [width-1:0] res_comb;
    assign down_data = res_comb;

    logic res_vld_comb;
    assign down_vld = res_vld_comb;

    always_comb 
        for (int j = 0; j < n_inputs; j++)
            if (counter == j) begin
                if (vld_array[j])
                    res_comb = data_array[j];
                else if (up_vlds[j])
                    res_comb = up_data[j];
            end

    always_comb 
        for (int j = 0; j < n_inputs; j++)
            if (counter == j) 
                res_vld_comb =vld_array[j] | up_vlds[j];
            
    

    always_ff @(posedge clk)
        if (rst)
            vld_array <= n_inputs'(0);
        else 
            for (int j = 0; j < n_inputs; j++)
                if (j==counter&&vld_array[j]) 
                    vld_array[j]<=up_vlds[j];
                else if (j == counter)
                    vld_array[j] <= '0;
                else
                    if (up_vlds[j])
                        vld_array[j] <= up_vlds[j];

    always_ff @(posedge clk)
        for (int j = 0; j < n_inputs; j++)
            if (j==counter&&vld_array[j]) 
                data_array[j]<=up_data[j];
            else if (j != counter)
                if (up_vlds[j])
                    data_array[j] <= up_data[j];
        
    always_ff @(posedge clk) 
        if (rst)
            counter <= '0;
        else
            if (down_vld)
                counter <= (counter == n_inputs-1) ? 0 : (counter + 1);
    

endmodule
