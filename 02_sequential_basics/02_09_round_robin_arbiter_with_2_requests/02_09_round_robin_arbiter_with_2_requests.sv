//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic next;
    
    assign grants = { (~requests[0]&requests[1]) | (requests[1] & next), (~requests[1]&requests[0]) | (requests[0] & ~next) };

    always_ff @(posedge clk or posedge rst)
        if(rst) begin
            next <= '0;
        end
        else begin
            if (requests[1] & requests[0]) next = ~next;
            else if (requests[0]) next = 1;
            else if (requests[1]) next = 0;

        end
        


endmodule
