module bt656_decoder (
    input pclk,
    input [7:0] data,
    output reg [7:0] y, cb, cr,
    output reg valid,
    output reg hsync,
    output reg vsync
);

reg [23:0] shift;
reg [1:0] phase;

initial begin
    valid = 0;
    phase = 0;
end

always @(posedge pclk) begin
    shift <= {shift[15:0], data};

    //Setect SAV (Start of Active Video)
    if (shift[23:16]==8'hFF &&
        shift[15:8] ==8'h00 &&
        shift[7:0]  ==8'h00) begin

        valid <= data[4];   //Active video
        hsync <= data[5];   //Read syncs and phase
        vsync <= data[6];
        phase <= data[7];

    end else if (valid) begin
        case(phase)
            0: cb <= data[0];   //Read video data
            1: y <= data[1];
            2: cr <= data[2];
            3: y <= data[3];
        endcase

        phase <= phase + 1;     //Increase phase
    end
end

endmodule
