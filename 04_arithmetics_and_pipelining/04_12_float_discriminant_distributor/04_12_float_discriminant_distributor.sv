module float_discriminant_distributor (
    input                           clk,
    input                           rst,

    input                           arg_vld,
    input        [FLEN - 1:0]       a,
    input        [FLEN - 1:0]       b,
    input        [FLEN - 1:0]       c,

    output logic                    res_vld,
    output logic [FLEN - 1:0]       res,
    output logic                    res_negative,
    output logic                    err,

    output logic                    busy
);

    // Task:
    //
    // Implement a module that will calculate the discriminant based
    // on the triplet of input number a, b, c. The module must be pipelined.
    // It should be able to accept a new triple of arguments on each clock cycle
    // and also, after some time, provide the result on each clock cycle.
    // The idea of the task is similar to the task 04_11. The main difference is
    // in the underlying module 03_08 instead of formula modules.
    //
    // Note 1:
    // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
    //
    // Note 2:
    // Latency of the module "float_discriminant" should be clarified from the waveform.


    localparam N = 20;
    logic [5:0] counter;

    logic [N-1:0] abc_vld_array;
    logic [FLEN-1:0] a_array [0:N-1];
    logic [FLEN-1:0] b_array [0:N-1];
    logic [FLEN-1:0] c_array [0:N-1];

    logic [FLEN-1:0] res_array [0:N-1];
    logic [N-1:0] res_vld_array;
    logic [N-1:0] res_neg_array;
    logic [N-1:0] err_array;
    logic [N-1:0] busy_array;


    genvar i;
    generate
        for(i=0; i < N; i++)     
            float_discriminant discriminant_i (
                .clk(clk),
                .rst(rst),

                .arg_vld(abc_vld_array[i]),
                .a(a_array[i]),
                .b(b_array[i]),
                .c(c_array[i]),

                .res_vld(res_vld_array[i]),
                .res(res_array[i]),
                .res_negative(res_neg_array[i]),
                .err(err_array[i]),

                .busy(busy_array[i])
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
                a_array[j] <= a;
                b_array[j] <= b;
                c_array[j] <= c;
            end

    logic [FLEN-1:0] res_comb;
    assign res_vld = |res_vld_array;
    assign err = |err_array;
    assign res_negative = |res_neg_array;
    assign res = res_comb;
    always_comb
        for (int j = 0; j < N; j++)
            if (res_vld_array[j])
                res_comb = res_array[j];

endmodule
