


module FFT
(
    input                   clk,reset,en,
    input       [31:0]      in_point0,in_point1,in_point2,in_point3,
    output      [31:0]      data_out,address,
    output                  we,done
);
wire    [31:0]    stage_1               [3:0];
wire    [31:0]    stage_2               [3:0];
wire    [31:0]    out_point0,out_point1,out_point2,out_point3;


//store
general_register point0( .D(in_point0),
                         .reset(reset), .clk(clk), .en(en),
                         .Q(stage_1[0]));

general_register point1( .D(in_point1),
                         .reset(reset), .clk(clk), .en(en),
                         .Q(stage_1[1]));

general_register point2( .D(in_point2),
                         .reset(reset), .clk(clk), .en(en),
                         .Q(stage_1[2]));

general_register point3( .D(in_point3),
                         .reset(reset), .clk(clk), .en(en),
                         .Q(stage_1[3]));

//compute node
butterfly stage1_0(.a(stage_1[0]),      .b(stage_1[2]),     .W(32'h00010000),
                   .x_even(stage_2[0]), .x_odd(stage_2[1]));

butterfly stage1_1(.a(stage_1[1]),      .b(stage_1[3]),     .W(32'h00010000),
                   .x_even(stage_2[2]), .x_odd(stage_2[3]));


//compute node
butterfly stage2_0(.a(stage_2[0]),     .b(stage_2[2]),     .W(32'h00010000),
                   .x_even(out_point0), .x_odd(out_point2));

butterfly stage2_1(.a(stage_2[1]),     .b(stage_2[3]),     .W(32'h0000FFFF),
                   .x_even(out_point3), .x_odd(out_point1));

controller control(.en(en), .clk(clk), .reset(reset),
                   .data_in_0(out_point0), .data_in_1(out_point1), .data_in_2(out_point2), .data_in_3(out_point3),
                   .we(we), .done(done),
                   .data_out(data_out), .address(address));

endmodule

///////////////////////BUTTERFLY////////////////////////////////////
module butterfly
(
    input       [31:0]      a,b,W,
    output      [31:0]      x_even,x_odd
);
wire    [31:0]      b_W;

complex_mult temp( .a(b[31:16]), .b(b[15:0]), .c(W[31:16]), .d(W[15:0]), .out(b_W));

adder_32bit even( .a(a), .b(b_W),
                  .real_cin('b0), .imag_cin('b0),
                  .sum(x_even));

adder_32bit odd ( .a(a), .b(b_W),
                  .real_cin('b1), .imag_cin('b1),
                  .sum(x_odd));


endmodule
///////////////////////CONTROLLER///////////////////////////////////
module controller
(
    input                   en,clk,reset,
    input       [31:0]      data_in_0,data_in_1,data_in_2,data_in_3,
    output                  we,done,
    output      [31:0]      data_out,address
);
reg     [2:0]   counter;
wire    [2:0]   count_temp;
wire            en_temp;
wire    [31:0]  data_out_temp,address_temp;

parameter address_0     ='h400100;
parameter address_1     ='h400110;
parameter address_2     ='h400120;
parameter address_3     ='h400130;
parameter address_done  ='h400060;

assign en_temp=(counter[2]&!counter[1]&counter[0])^en;
assign done=counter[2]&!counter[1]&counter[0];
assign we=en;

always @(posedge clk or posedge reset) begin
if(reset) counter <='b0;
else begin
    if (en_temp== 1) counter<=counter + 1;
end
end

adder_3bit sub( .a(counter), .b('b1),
                .cin('b1),
                .sum(count_temp));

mux4_1 data     ( .temp1_0(data_in_0), .temp1_1(data_in_1), .temp1_2(data_in_2), .temp1_3(data_in_3),
                  .sel(count_temp[1:0]),
                  .temp2(data_out_temp));

mux4_1 address_ ( .temp1_0(address_0), .temp1_1(address_1), .temp1_2(address_2), .temp1_3(address_3),
                  .sel(count_temp),
                  .temp2(address_temp));

assign data_out =done?{31'b0,done}:data_out_temp;
assign address  =done?address_done:address_temp;

endmodule
///////////////////////REGISTER/////////////////////////////////////

module general_register
(
	input					[31:0]		D,
	input			                    reset,clk,en,
	output	    reg         [31:0]		Q
);

always @ (posedge clk or posedge reset) begin
if(reset) Q<='b0;
else begin
	if (en==1) Q<=D;
end
end

endmodule


///////////////////////FULL ADDER_COMPLEX////////////////////////////

module adder_32bit
(
	input		[31:0]		a,b,
	input					real_cin,imag_cin,               //if 1 then subtract, 0 add
	output	    [31:0]		sum
);
wire            [15:0]      a_real,a_imag,b_real,b_imag;
wire			[15:0]		real_cout,imag_cout;

assign a_real=a[31:16];
assign b_real=b[31:16]^{16{real_cin}};
assign a_imag=a[15:0];
assign b_imag=b[15:0]^{16{imag_cin}};

adder a0  (.a(a_real[0]),  .b(b_real[0]),  .cin(real_cin),      .sum(sum[0]),  .cout(real_cout[0]));
adder a1  (.a(a_real[1]),  .b(b_real[1]),  .cin(real_cout[0]),  .sum(sum[1]),  .cout(real_cout[1]));
adder a2  (.a(a_real[2]),  .b(b_real[2]),  .cin(real_cout[1]),  .sum(sum[2]),  .cout(real_cout[2]));
adder a3  (.a(a_real[3]),  .b(b_real[3]),  .cin(real_cout[2]),  .sum(sum[3]),  .cout(real_cout[3]));
adder a4  (.a(a_real[4]),  .b(b_real[4]),  .cin(real_cout[3]),  .sum(sum[4]),  .cout(real_cout[4]));
adder a5  (.a(a_real[5]),  .b(b_real[5]),  .cin(real_cout[4]),  .sum(sum[5]),  .cout(real_cout[5]));
adder a6  (.a(a_real[6]),  .b(b_real[6]),  .cin(real_cout[5]),  .sum(sum[6]),  .cout(real_cout[6]));
adder a7  (.a(a_real[7]),  .b(b_real[7]),  .cin(real_cout[6]),  .sum(sum[7]),  .cout(real_cout[7]));
adder a8  (.a(a_real[8]),  .b(b_real[8]),  .cin(real_cout[7]),  .sum(sum[8]),  .cout(real_cout[8]));
adder a9  (.a(a_real[9]),  .b(b_real[9]),  .cin(real_cout[8]),  .sum(sum[9]),  .cout(real_cout[9]));
adder a10 (.a(a_real[10]), .b(b_real[10]), .cin(real_cout[9]),  .sum(sum[10]), .cout(real_cout[10]));
adder a11 (.a(a_real[11]), .b(b_real[11]), .cin(real_cout[10]), .sum(sum[11]), .cout(real_cout[11]));
adder a12 (.a(a_real[12]), .b(b_real[12]), .cin(real_cout[11]), .sum(sum[12]), .cout(real_cout[12]));
adder a13 (.a(a_real[13]), .b(b_real[13]), .cin(real_cout[12]), .sum(sum[13]), .cout(real_cout[13]));
adder a14 (.a(a_real[14]), .b(b_real[14]), .cin(real_cout[13]), .sum(sum[14]), .cout(real_cout[14]));
adder a15 (.a(a_real[15]), .b(b_real[15]), .cin(real_cout[14]), .sum(sum[15]), .cout(real_cout[15]));

adder a16 (.a(a_imag[0]),  .b(b_imag[0]),  .cin(imag_cin),      .sum(sum[16]), .cout(imag_cout[0]));
adder a17 (.a(a_imag[1]),  .b(b_imag[1]),  .cin(imag_cout[0]),  .sum(sum[17]), .cout(imag_cout[1]));
adder a18 (.a(a_imag[2]),  .b(b_imag[2]),  .cin(imag_cout[1]),  .sum(sum[18]), .cout(imag_cout[2]));
adder a19 (.a(a_imag[3]),  .b(b_imag[3]),  .cin(imag_cout[2]),  .sum(sum[19]), .cout(imag_cout[3]));
adder a20 (.a(a_imag[4]),  .b(b_imag[4]),  .cin(imag_cout[3]),  .sum(sum[20]), .cout(imag_cout[4]));
adder a21 (.a(a_imag[5]),  .b(b_imag[5]),  .cin(imag_cout[4]),  .sum(sum[21]), .cout(imag_cout[5]));
adder a22 (.a(a_imag[6]),  .b(b_imag[6]),  .cin(imag_cout[5]),  .sum(sum[22]), .cout(imag_cout[6]));
adder a23 (.a(a_imag[7]),  .b(b_imag[7]),  .cin(imag_cout[6]),  .sum(sum[23]), .cout(imag_cout[7]));
adder a24 (.a(a_imag[8]),  .b(b_imag[8]),  .cin(imag_cout[7]),  .sum(sum[24]), .cout(imag_cout[8]));
adder a25 (.a(a_imag[9]),  .b(b_imag[9]),  .cin(imag_cout[8]),  .sum(sum[25]), .cout(imag_cout[9]));
adder a26 (.a(a_imag[10]), .b(b_imag[10]), .cin(imag_cout[9]),  .sum(sum[26]), .cout(imag_cout[10]));
adder a27 (.a(a_imag[11]), .b(b_imag[11]), .cin(imag_cout[10]), .sum(sum[27]), .cout(imag_cout[11]));
adder a28 (.a(a_imag[12]), .b(b_imag[12]), .cin(imag_cout[11]), .sum(sum[28]), .cout(imag_cout[12]));
adder a29 (.a(a_imag[13]), .b(b_imag[13]), .cin(imag_cout[12]), .sum(sum[29]), .cout(imag_cout[13]));
adder a30 (.a(a_imag[14]), .b(b_imag[14]), .cin(imag_cout[13]), .sum(sum[30]), .cout(imag_cout[14]));
adder a31 (.a(a_imag[15]), .b(b_imag[15]), .cin(imag_cout[14]), .sum(sum[31]), .cout(imag_cout[15]));


endmodule
////////////3_bit_adder//////////////////////
module adder_3bit
(
	input		[2:0]		a,b,
	input					cin,               //if 1 then subtract, 0 add
	output	    [2:0]		sum
);
wire			[2:0]		cout;
wire            [2:0]       b_temp;

assign b_temp={3{cin}}^b;

adder a0  (.a(a[0]),  .b(b_temp[0]),  .cin(cin),      .sum(sum[0]),  .cout(cout[0]));
adder a1  (.a(a[1]),  .b(b_temp[1]),  .cin(cout[0]),  .sum(sum[1]),  .cout(cout[1]));
adder a2  (.a(a[2]),  .b(b_temp[2]),  .cin(cout[1]),  .sum(sum[2]),  .cout(cout[2]));

endmodule
/////////////half adder//////////////////////

module adder
(
	input				a,b,cin,
	output			    sum,cout
);

assign sum=(a^b)^cin;
assign cout=((a^b)&cin)|a&b;

endmodule

/////////////MUX/////////////////////////////

module mux4_1
(
	input 	[31:0]	temp1_0,temp1_1,temp1_2,temp1_3,
	input		[1:0]		sel,
	output	[31:0]	temp2
);

assign temp2=sel[1]?(sel[0]?temp1_3:temp1_2):(sel[0]?temp1_1:temp1_0);

endmodule
