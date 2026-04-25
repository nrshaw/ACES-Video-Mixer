module hdmi_top (
    input pix_clk,      //27 MHz
    input pix_clk_10x,  //270 MHz (PLL)
    input [7:0] r,      //Video data
    input [7:0] g,
    input [7:0] b,
    input hsync,
    input vsync,
    input de,

    output [3:0] tmds_p,//HDMI pins
    output [3:0] tmds_n
);

wire [9:0] tmds_r, tmds_g, tmds_b;

wire tmds_r_serial;
wire tmds_g_serial;
wire tmds_b_serial;

//TMDS encoding
tmds_encoder enc_r (.pix_clk(pix_clk), .din(r), .c0(hsync), .c1(vsync), .de(de), .dout(tmds_r));
tmds_encoder enc_g (.pix_clk(pix_clk), .din(g), .c0(hsync), .c1(vsync), .de(de), .dout(tmds_g));
tmds_encoder enc_b (.pix_clk(pix_clk), .din(b), .c0(hsync), .c1(vsync), .de(de), .dout(tmds_b));

//Serialize (5x clk to 10x for +/-)
serializer ser_r (.clk(pix_clk_10x), .data(tmds_r), .out(tmds_r_serial));
serializer ser_g (.clk(pix_clk_10x), .data(tmds_g), .out(tmds_g_serial));
serializer ser_b (.clk(pix_clk_10x), .data(tmds_b), .out(tmds_b_serial));

//Pins for HDMI channels (differential +/-)
assign tmds_p[3] = pix_clk;
assign tmds_n[3] = ~pix_clk;

assign tmds_p[2] = tmds_r_serial;
assign tmds_n[2] = ~tmds_r_serial;

assign tmds_p[1] = tmds_g_serial;
assign tmds_n[1] = ~tmds_g_serial;

assign tmds_p[0] = tmds_b_serial;
assign tmds_n[0] = ~tmds_b_serial;

endmodule
