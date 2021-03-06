

`timescale 1ns/1ns

module FFT_tb
();
reg                     clk,reset,en;
reg         [31:0]      in_point0,in_point1,in_point2,in_point3;
wire        [31:0]      out_point0,out_point1,out_point2,out_point3;

FFT tb( .clk(clk), .reset(reset), .en(en),
        .in_point0(in_point0), .in_point1(in_point1), .in_point2(in_point2), .in_point3(in_point3),
        .out_point0(out_point0), .out_point1(out_point1), .out_point2(out_point2), .out_point3(out_point3));

initial begin
    $dumpfile("FFT_tb.vcd");
    $dumpvars(0,FFT_tb);

    clk='b0;
    reset='b0;
    en='b0;
    in_point0=32'h00060000;
    in_point1=32'h00030000;
    in_point2=32'h00050000;
    in_point3=32'h00040000;
    #10
    clk=~clk;
    reset='b1;
    en='b0;
    #10
    clk=~clk;
    reset='b0;
    en='b1;
    repeat(8) #10 clk=~clk;
    in_point0=32'h00100000;
    in_point1=32'h00250000;
    in_point2=32'h00050000;
    in_point3=32'h00090000;
    repeat(8) #10 clk=~clk;
end

endmodule
