//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    logic [width-1:0] accumulated_count;
 
    always_ff @(posedge clk or posedge rst)
        if(rst) begin
            accumulated_count <= 1'b1;
            parallel_data <= '0;
            parallel_valid <= '0;
            //accumulated_data <= '0;
        end
        else begin
            if (serial_valid) begin 
                parallel_data <= {serial_data, parallel_data[width-1:1]};
                accumulated_count <= {accumulated_count[width-2:0], accumulated_count[width-1]};
                //accumulated_count <= accumulated_count + 1;
            
                if (accumulated_count[width-1]) begin
                    parallel_valid <= 1'b1;
                    accumulated_count <= 'b1;
                end else parallel_valid <= '0;
            end
            else parallel_valid <= '0;
                

        end


endmodule
