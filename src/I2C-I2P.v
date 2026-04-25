module i2c_init (
    input clk,
    output reg scl,
    inout sda
);

reg sda_out, sda_oe;
assign sda = sda_oe ? sda_out : 1'bz;

localparam DEV_ADDR = 8'h40;    //ADV7283 Address

//Clock divider (100kHz ish) - max 400kHz for I2C with ADV7283
reg [8:0] div;

always @(posedge clk)
    div <= div + 1;

wire tick = (div == 0);

//Script
reg [3:0] step;
reg [7:0] reg_addr, reg_data;
reg [3:0] bit_cnt;
reg [7:0] state = 0;

always @(*) begin
    case (step)
    0: begin reg_addr=8'h0F; reg_data=8'h80; end //Reset
    1: begin reg_addr=8'h0E; reg_data=8'h80; end //Power down
    2: begin reg_addr=8'h00; reg_data=8'h06; end //AIN5
    3: begin reg_addr=8'h3A; reg_data=8'h80; end //I2P (Interlaced-2-Progressive)
    4: begin reg_addr=8'h04; reg_data=8'h57; end //BT.656
    5: begin reg_addr=8'h9C; reg_data=8'h00; end //Suggested by Analog Inc.
    6: begin reg_addr=8'h9C; reg_data=8'hFF; end //Suggested by Analog Inc.
    default: begin reg_addr=8'h00; reg_data=8'h00; end
    endcase
end

always @(posedge clk) begin
if (tick) begin
    case (state)

    //Start
    0: begin scl<=1; sda_out<=1; sda_oe<=1; state<=1; end
    1: begin sda_out<=0; state<=2; end

    //Address
    2: begin bit_cnt<=7; state<=3; end
    3: begin scl<=0; sda_out<=DEV_ADDR[bit_cnt]; state<=4; end
    4: begin scl<=1;
        if(bit_cnt==0) state<=5;
        else begin bit_cnt<=bit_cnt-1; state<=3; end
    end

    //REG
    5: begin scl<=0; bit_cnt<=7; state<=6; end
    6: begin sda_out<=reg_addr[bit_cnt]; scl<=1;
        if(bit_cnt==0) state<=7;
        else bit_cnt<=bit_cnt-1;
    end

    //Data
    7: begin scl<=0; bit_cnt<=7; state<=8; end
    8: begin sda_out<=reg_data[bit_cnt]; scl<=1;
        if(bit_cnt==0) state<=9;
        else bit_cnt<=bit_cnt-1;
    end

    //Stop
    9: begin scl<=1; sda_out<=0; state<=10; end
    10: begin sda_out<=1;
        if (step < 6) begin
            step <= step + 1;
            state <= 0;
        end else begin
            state <= 10;
        end
    end

    endcase
end
end

endmodule
