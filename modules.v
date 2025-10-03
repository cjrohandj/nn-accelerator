module ReLU #(
	parameter W = 8,
	parameter N = 4,
	parameter Accw = 32
)(

	input wire signed [N*N*Accw-1:0] ReLU_in,
	output wire signed [N*N*Accw-1:0] ReLU_out
	);
	genvar i;
	generate
		for (i = 0; i<N*N; i=i+1) begin:row

			assign  ReLU_out[i*Accw+: Accw] = 
					ReLU_in[i*Accw+: Accw]>0 
				       	? ReLU_in[i*Accw+: Accw] : 0;
			end
	endgenerate
endmodule

module systolic_array_NxN #(
	parameter N = 4,
	parameter W = 8,
	parameter Accw = 32
)(
	input wire clk,
	input wire rst, 
	input wire systolic_en,
	input wire signed [N*W-1:0] a_in,
	input wire signed [N*W-1:0] b_in,
	output wire signed [N*N*Accw-1:0] acc_out
);
	wire signed [W-1:0] a_wire[0:N-1][0:N-1];
	wire signed [W-1:0] b_wire[0:N-1][0:N-1];
	wire signed [Accw-1:0] acc_wire[0:N-1][0:N-1];

	genvar i,j;

	generate 
		for (i=0;i<N;i=i+1) begin:row
			for (j=0;j<N;j=j+1) begin:col
				mac #(.W(W), .Accw(Accw), .N(N)) 
			       	 mac_inst(
				.clk(clk), .rst(rst), .en(systolic_en), 
				.a_in((j==0) ? a_in[i*W+: W] : a_wire[i][j-1]), 				.a_out(a_wire[i][j]),
				.b_in((i==0) ? b_in[j*W+: W] : b_wire[i-1][j]),
				.b_out(b_wire[i][j]), 
				.acc(acc_wire[i][j])
		);
		assign acc_out[(i*N+j)*Accw+: Accw] = acc_wire[i][j];
		
			end
		end
	endgenerate

endmodule


	

module mac #(
	parameter N = 4,
	parameter W = 8,
	parameter Accw = 32

)(
	input wire clk,
	input wire rst,
	input wire en,
	input wire signed [W-1:0] a_in,
	input wire signed [W-1:0] b_in,
	output wire signed [W-1:0] a_out,
	output wire signed [W-1:0] b_out,
	output reg signed [Accw-1:0] acc
);

	assign a_out = a_in;
	assign b_out = b_in;

	always @(posedge clk) begin
		if (rst) begin
			acc <= '0;
		end else if (en) begin
			acc <= acc + (a_in*b_in);
		
		end
	end	

endmodule
