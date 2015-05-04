module PE (clk, A, B, C, mult_result, add_result);

parameter PRECISION = 32;

input clk;
input [PRECISION-1:0] A, B, C;
output [PRECISION-1:0] mult_result, add_result;

reg [PRECISION-1:0] out;
wire [PRECISION-1:0] mult_comp_result;

	always @ (posedge clk)
	begin
		add_result <= A+B;
		mult_result <= B*C;
	end
	
	assign mult_result = mult_comp_result;

endmodule
