module top (
    input clk,                //FPGA clock (27MHz)
    
    input [7:0] video_data,  //B0-B7
    input pclk,              //Clock from ADV7283
    
    inout sda,               //I2C Lines
    output scl,
    
    output reset_n,          //Reset and power down
    output pwdn_n,

    output [3:0] tmds_p,     //HDMI +/- output B0-B3
    output [3:0] tmds_n
);

//Power and reset control
reg [31:0] power_cnt = 0;
reg [31:0] timeout = 0;
reg reset_r = 0;
reg pwdn_r = 0;

assign reset_n = reset_r;
assign pwdn_n  = pwdn_r;

always @(posedge clk) begin
    power_cnt <= power_cnt + 1;

    if (power_cnt > 1_000_000)  //Small delay
        pwdn_r <= 1;   //Pull power down and reset high (active lows)
        reset_r <= 1;

    //If video isn't working, start counting
    if (vid_valid) 
        timeout <= 0;
    else
        timeout <= timeout + 1;

    if (timeout > 27_000_000)   //Long delay
        reset_r <= 0; //reset
end

//I2C
i2c_init i2c0 (
    .clk(clk),
    .scl(scl),
    .sda(sda)
);

//Wires for Gowin's pre-written clock define
wire [7:0] pixel;
wire pixel_valid;
wire pix_clk;
wire pix_clk_10x;

Gowin_PLLVR pll0 (
    .clkin(clk),          //27 MHz
    .clkout(pix_clk),     //27 MHz
    .clkoutd(pix_clk_10x) //270 MHz
);

//Wires for bt.656 decoder
wire [7:0] y, cb, cr;
wire vid_valid;
wire hsync, vsync;

//8-Bit to YCbCr
bt656_decoder dec (
    .pclk(pclk),
    .data(video_data),
    .y(y),
    .cb(cb),
    .cr(cr),
    .valid(vid_valid),
    .hsync(hsync),
    .vsync(vsync)
);

//YCbCr to RGB
wire [7:0] r, g, b;
rgb_convert rgb (
    .y(y),
    .cb(cb),
    .cr(cr),
    .r(r),
    .g(g),
    .b(b)
);

//HDMI Output
hdmi_top hdmi (
    .pix_clk(pix_clk),
    .pix_clk_10x(pix_clk_10x),
    .r(r),
    .g(g),
    .b(b),
    .hsync(hsync),
    .vsync(vsync),
    .de(vid_valid),
    .tmds_p(tmds_p),
    .tmds_n(tmds_n)
);

endmodule
