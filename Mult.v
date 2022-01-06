module Mult(
input [15:0]a,b,

output[31:0]out
				);
wire [31:0] A,B,A_,B_;
wire [31:0] A_start [31:0];
wire [31:0] zero,one;
wire [31:0] ans     [30:0];
wire go;
assign go = a[15]&b[15];
assign A_[31:0]={{16{a[15]}},a[15:0]};
assign B_[31:0]={{16{b[15]}},b[15:0]};
Adder converta(.a({32'b0}),.b(A_),.sum_dif(A),.carry_in(go),.add_sub(go));
Adder convertb(.a({32'b0}),.b(B_),.sum_dif(B),.carry_in(go),.add_sub(go));
assign zero[31:0] = 32'h00000000;
	generate
	genvar i,j;
	
	for(i=0;i<32;i=i+1)
		begin : oi
		
		for(j=0;j<32;j=j+1)
				begin : start_plus
					assign A_start[i][j]=A[j]&B[i];
			end
		end
	
	Adder add(.a({A_start[0][31:0]}),.b({A_start[1][30:0],zero[0]}),.sum_dif(ans[0][31:0]),.carry_in(0),.add_sub(0));
	
	for(i=2;i<32;i=i+1)
		begin : o
						
						Adder adds(.a({ans[i-2][31:0]}),.b({A_start[i][31-i:0],zero[i-1:0]}),.sum_dif(ans[i-1][31:0]),.carry_in(0),.add_sub(0));
		end
		assign out = ans[30][31:0];
	endgenerate

endmodule 
