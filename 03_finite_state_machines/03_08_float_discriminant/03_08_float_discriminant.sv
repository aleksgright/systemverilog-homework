//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    logic busy1, bsuy2, busy3, busy4;

    logic bb_valid, ac_valid, ac4_valid;

    logic sub_error, bb_err, ac_err, ac4_err;


    logic [FLEN - 1:0] sub_out; 
    logic [FLEN - 1:0] mul_out; 

    logic [FLEN - 1:0] bb_reg;
    logic bb_reg_valid;
    logic [FLEN - 1:0] bb_res;
    logic [FLEN - 1:0] ac_res;
    logic [FLEN - 1:0] ac4_res;
 
    f_sub sub(
        .clk(clk),
        .rst(rst),
        .a(bb_reg),
        .b(ac4_res),
        .up_valid(bb_reg_valid&ac4_valid),
        .res(res),
        .down_valid(res_vld),   
        .busy(busy4),
        .error(sub_error)
    );

    f_mult mul_bb(
        .clk(clk),
        .rst(rst),
        .a(b),
        .b(b),
        .up_valid(arg_vld),
        .res(bb_res),
        .down_valid(bb_valid),
        .busy(busy1),
        .error(bb_err)
    );

    f_mult mul_ac(
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(c),
        .up_valid(arg_vld),
        .res(ac_res),
        .down_valid(ac_valid),
        .busy(busy2),
        .error(ac_error)
    );

    f_mult mul_ac4(
        .clk(clk),
        .rst(rst),
        .a(ac_res),
        .b(64'h4010_0000_0000_0000),
        .up_valid(ac_valid),
        .res(ac4_res),
        .down_valid(ac4_valid),
        .busy(busy3),
        .error(ac4_err)
    );

    assign err = ac4_err | ac_err | bb_err | sub_error;

    always_ff @(posedge clk)
        if (rst) begin
            bb_reg<='0;
            bb_reg_valid <= '0;
        end
        else begin
            if (bb_valid)begin
                bb_reg<=bb_res;
                bb_reg_valid <= '1;
            end
        end


endmodule
