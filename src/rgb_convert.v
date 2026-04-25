module rgb_convert (
    input [7:0] y, cb, cr,
    output [7:0] r, g, b
);

wire signed [9:0] r_tmp, g_tmp, b_tmp;

//Assign temp r, g, b values (converted from YCrCb)
assign r_tmp = y + (cr - 8'd128);
assign g_tmp = y - ((cb - 8'd128)>>1) - ((cr - 8'd128)>>1);
assign b_tmp = y + (cb - 8'd128);

//Clamp r, g, b values from 0-255 in ternary statements
assign r = (r_tmp < 0) ? 0 : (r_tmp > 255 ? 255 : r_tmp[7:0]);
assign g = (g_tmp < 0) ? 0 : (g_tmp > 255 ? 255 : g_tmp[7:0]);
assign b = (b_tmp < 0) ? 0 : (b_tmp > 255 ? 255 : b_tmp[7:0]);

endmodule
