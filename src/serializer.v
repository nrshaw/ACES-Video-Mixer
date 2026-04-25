module serializer (
    input clk,
    input [9:0] data,
    output reg out
);

reg [9:0] shift;
reg [3:0] cnt;              //Count

always @(posedge clk) begin
    if (cnt == 0) begin     //If count 0
        shift <= data;      //Set shift to data
        cnt <= 9;           //Set count to 9
    end else begin
        shift <= shift >> 1;//Bitshift shift right 1
        cnt <= cnt - 1;     //-1 from count
    end

    out <= shift[0];        //Outputs B0 of shift
end

endmodule
