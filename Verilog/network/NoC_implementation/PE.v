module PE (clk, A, B, C, begin_calculation, mult_result, add_result, mult_ready, add_ready);

parameter PRECISION = 32;

/*
mult_result: A*B (10 clocks)
add_result : C-(A*B) (25 clocks)
*/

input clk;
input [PRECISION-1:0] A, B, C;
input begin_calculation;
output [PRECISION-1:0] mult_result, add_result;
output reg mult_ready, add_ready;

reg [4:0] counter;
reg [1:0] m_state;
localparam IDLE = 2'd0;
localparam CALCULATING = 2'd1;
//localparam DONE = 2'd2;

reg [PRECISION-1:0] out;
wire [PRECISION-1:0] mult_comp_result;
reg [PRECISION-1:0] add_a, add_b;

	multsplat11 mult_comp (
		.clock (clk),
		.dataa (A),
		.datab (B),
		.result (mult_comp_result));
	
	subsplat14 adder_comp (
		.clock (clk),
		.dataa (add_a),
		.datab (add_b),
		.result (add_result));

	always @ (posedge clk)
	begin
	  case(m_state)
	    IDLE: begin
	      mult_ready <= 1'b0;
	      add_ready <= 1'b0;
	      add_a <= C;
		    add_b <= mult_comp_result;
		    
		    if(begin_calculation)
		      begin
		        m_state <= CALCULATING;
		        counter <= 5'd0;
		      end
	    end
	      
	    CALCULATING: begin
	      counter <= counter + 1;
	      
	      if(counter == 5'd10)
	        begin
	         mult_ready <= 1'b1;
	         add_b <= mult_comp_result;
	        end
	        
	      if(counter == 5'd25)
	        begin
	          add_ready <= 1'b1;
	          m_state <= IDLE;
	        end
	      
	    end
/*
      DONE: begin
        
      end
*/
		
		
		endcase
	end
	
	assign mult_result = mult_comp_result;

endmodule
