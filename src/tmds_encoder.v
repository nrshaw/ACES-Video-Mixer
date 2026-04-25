module tmds_encoder (
    input pix_clk,
    input [7:0] din,
    input c0, c1,
    input de,
    output reg [9:0] dout
);

reg [3:0] ones;
reg [8:0] q_m;
integer i;

always @(posedge pix_clk) begin
    if (de) begin
        //Count ones
        ones = din[0]+din[1]+din[2]+din[3]+din[4]+din[5]+din[6]+din[7];

        //Generate q_m (From wiki.sipeed.com)
        q_m[0] = din[0];
        for (i=1; i<8; i=i+1)
            q_m[i] = q_m[i-1] ^ din[i];

        q_m[8] = (ones > 4) || (ones == 4 && din[0] == 0);

        dout <= {~q_m[8], q_m};
    end else begin
        case ({c1,c0})    //From wiki.sipeed.com
            2'b00: dout <= 10'b1101010100;
            2'b01: dout <= 10'b0010101011;
            2'b10: dout <= 10'b0101010100;
            2'b11: dout <= 10'b1010101011;
        endcase
    end
end

endmodule
