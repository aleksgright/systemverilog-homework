//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

// A non-parameterized module
// that implements the signed multiplication of 4-bit numbers
// which produces 8-bit result

module signed_mul_4
(
  input  signed [3:0] a, b,
  output signed [7:0] res
);

  assign res = a * b;

endmodule

// A parameterized module
// that implements the unsigned multiplication of N-bit numbers
// which produces 2N-bit result

module unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  output [2 * n - 1:0] res
);

  assign res = a * b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

// Task:
//
// Implement a parameterized module
// that produces either signed or unsigned result
// of the multiplication depending on the 'signed_mul' input bit.

module signed_or_unsigned_mul
# (
  parameter n = 8
)
(
  input  [    n - 1:0] a, b,
  input                signed_mul,
  output [2 * n - 1:0] res
);

  //assign res = signed_mul ? ($signed(a) * $signed(b)) : (a * b) ;
  logic [2 * n - 1:0]  res_stub;
  assign res = res_stub;
  always_comb
    if (signed_mul)
      res_stub = $signed(a) * $signed(b);
    else 
      res_stub = a * b;
  




  // logic [2 * n - 1:0]  res_stub;
  // logic [n-1:0] a_mod, b_mod;
  // logic sign;
  // assign res = res_stub;
  // always_comb begin
  //   if (signed_mul) begin
  //     sign = a[n-1] ^ b[n-1];

  //     a_mod = a[n-1] ? ~(a[n-1:0]-1) : a[n-1:0];
  //     b_mod = b[n-1] ? ~(b[n-1:0]-1) : b[n-1:0];

  //     res_stub = a_mod*b_mod;
  //     if (sign)
  //       res_stub = (~res_stub + 1);
  //   end
  //   else  
  //     res_stub = a * b;
  // end

endmodule
