
`timescale 1ns/1ns

module FFT_tb
();
reg                       clk,reset,en;
reg           [31:0]      in_point0,in_point1,in_point2,in_point3;
wire          [31:0]      data_out,address;
wire                      we,done;

reg         [15:0]      ram     [65535:0];
reg         [31:0]      result;


FFT tb( .clk(clk), .reset(reset), .en(en),
        .in_point0(in_point0), .in_point1(in_point1), .in_point2(in_point2), .in_point3(in_point3),
        .data_out(data_out), .address(address),
        .we(we), .done(done));

integer w;
integer x;
integer y;
integer z;
integer fid;

initial begin
    $dumpfile("FFT_tb.vcd");
    $dumpvars(0,FFT_tb);

    clk='b0;
    reset='b0;
    en='b0;
    #10
    clk=~clk;
    reset='b1;
    en='b0;
    #10
    clk=~clk;
    reset='b0;
    en='b1;
    // Add stimulus here
		$readmemb("G:\\VLSI_ASIC_IC_designs\\fastft\\input.txt",ram);
		begin
		fid= $fopen("G:\\VLSI_ASIC_IC_designs\\fastft\\output.txt","w");
		end

    in_point0[15:0]=16'b0;
    in_point1[15:0]=16'b0;
    in_point2[15:0]=16'b0;
    in_point3[15:0]=16'b0;

    for(w = 0 ;w <= 65535;w = w + 1)
			begin
			in_point3[31:16] =ram[w];
			for(x = 0 ;x <= 65535;x = x + 1)
                begin
                in_point2[31:16] =ram[x];
                for(y = 0 ;y <= 65535;y = y + 1)
                    begin
                    in_point1[31:16] =ram[y];
                    for(z = 0 ;z <= 65535;z = z + 1)
                        begin
                        #10
                        clk=~clk;
                        reset='b1;
                        en='b0;
                        #10
                        clk=~clk;
                        reset='b0;
                        en='b1;
                        in_point0[31:16] =ram[z];
                        repeat(2) #10 clk=~clk;
                        $fwrite(fid,"point 0: %d, point 1: %d, point 2: %d, point 3: %d \nFFT_0: %d , %d\n", in_point0[31:16],in_point1[31:16],in_point2[31:16],in_point3[31:16],data_out[31:16],data_out[15:0]);
                        repeat(2) #10 clk=~clk;
                        $fwrite(fid,"FFT_1: %d , %d\n",data_out[31:16],data_out[15:0]);
                        repeat(2) #10 clk=~clk;
                        $fwrite(fid,"FFT_2: %d , %d\n",data_out[31:16],data_out[15:0]);
                        repeat(2) #10 clk=~clk;
                        $fwrite(fid,"FFT_3: %d , %d\n",data_out[31:16],data_out[15:0]);
                        repeat(2) #10 clk=~clk;
                        end
                    end
                end
			end
end

endmodule
