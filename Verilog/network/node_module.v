/*
This is the NODE module for our network that handles the computations for each 
node. The PE(s) and IF module(s) are located here.
*/
`include "connect_parameters.v"


module node_module(N_clk, N_rst, if_i_flit, 
					if_i_credit, if_o_credit_valid,
					if_o_credit, if_o_data, if_o_data_valid, Node_id,
					a_in, a_out, dummy);
	
	input wire N_clk, N_rst;
	input wire [72:0] if_i_flit;
	input wire [7:0] Node_id;
	input wire [63:0] a_in;

	output wire [2:0] if_i_credit;
	output wire if_o_credit_valid;
	output wire [2:0] if_o_credit;
	output wire [72:0] if_o_data;
	output wire if_o_data_valid;
	output [63:0] a_out;
	output reg [63:0] dummy;
	
	reg [31:0] test_value_A = 32'b01000000001000000000000000000000; 
	reg [31:0] test_value_B = 32'b01000000100000000000000000000000;
	reg [31:0] test_value_C = 32'b00111111100100000000000000000000;

  // Talking to IF
	wire req_ack;
	wire [31:0] PE_mult_result, PE_add_result;
	reg [31:0] send_data;
	reg [3:0] flit_count;
	

	reg PE_add, send_req, send_data_valid;
	reg [7:0] n_ID, src_node, dest_node;

	// unused
	wire unused1;
	wire [63:0] unused2;
	reg [5:0] unused4;
	reg unused5;


  // State flow control
	reg [3:0] n_state;
	localparam  START = 4'd0,
				UPDATE_K = 4'd1,
				RECEIVE_Akj = 4'd2,
				RECEIVE_Lik = 4'd3,
				UPDATE_A = 4'd4,
				BROADCAST_A = 4'd5,
				SEND_REQ_A = 4'd6,
				BROADCAST_A_TO_TASKkj = 4'd7,
				RECEIVE_Ajj = 4'd10,
				CALCULATE_lij = 4'd11,
				BROADCAST_L = 4'd12,
				SEND_REQ_L = 4'd13,
				BROADCAST_L_TO_TASKik = 4'd14,
				DONE = 4'd15;


  // Local values for computation
	reg [63:0] a;
	real a_real;
	assign a_out = a;
	reg [2:0] i, j, k;
	wire [2:0] k_max;
	assign k_max = (i<=j) ? i : j;
	reg [63:0] a_kj, l_ik, a_jj, l_ij;
	real a_kj_real, l_ik_real, a_jj_real, l_ij_real;
	real lik_akj_real;
	localparam n = 5;	// nxn matrix (1 based)



	always @ (posedge N_clk) begin
		if(N_rst == 0)
			begin
				a <= a_in;

				// Communication
				n_state <= START;
				n_ID <= Node_id;
				send_data_valid <= 1'b0;
				send_req <= 1'b0;
				flit_count <= 4'b0;

				// Local
				i <= Node_id/n;
				j <= Node_id%n;
				
				
			end

		else 
			begin
		   
		        case(n_state)
		        	START:
		        		begin
		        			// RTL
		        			k <= 3'd1;
		        			a_real <= $bitstoreal(a);

		        			// NSL
		        			n_state <= UPDATE_K;
		        		end

					UPDATE_K:
						begin
							// RTL
							k <= k + 1;

							// NSL
							if(k <= k_max)
								begin
									n_state <= RECEIVE_Akj;
								end
							else
								begin
									if(k_max == i) begin			// Vertical broadcast (element of L matrix)
											n_state <= BROADCAST_A;
											k <= i;	// K begins at i+1, (first incremented in Broadcast_A)
											a <= $realtobits(a_real);
										end
									else begin						// Horizontal broadcast after diagonal retrieval (element of U matrix)
											n_state <= RECEIVE_Ajj;
										end
								end

						end

					RECEIVE_Akj:
						begin
							// RTL
							if(if_i_flit[72])	// valid bit check
								begin
									// Increment flit counter
									flit_count <= flit_count + 1;
									if( flit_count==0 && !if_i_flit[71] )	// first flit of a multiple flit packet
										a_kj[63:32] <= if_i_flit[31:0];
									else if( flit_count==1 && if_i_flit[71] )	// second and last flit of a packet
										a_kj[31:0] <= if_i_flit[31:0];
									else
										$display("Invalid packet received for node%d", Node_id);

								end

							// NSL
							if(flit_count==1 && if_i_flit[72:71]==2'b11)	// getting second and final packet
								begin
									n_state <= RECEIVE_Lik;
									flit_count <= 4'd0;
								end
						end

					RECEIVE_Lik:
						begin
							// RTL
							if(if_i_flit[72])	// valid bit check
								begin
									// Increment flit counter
									flit_count <= flit_count + 1;
									if( flit_count==0 && !if_i_flit[71] )	// first flit of a multiple flit packet
										l_ik[63:32] <= if_i_flit[31:0];
									else if( flit_count==1 && if_i_flit[71] )	// second and last flit of a packet
										l_ik[31:0] <= if_i_flit[31:0];
									else
										$display("Invalid packet received for node%d", Node_id);

								end

							// NSL
							if(flit_count==1 && if_i_flit[72:71]==2'b11)	// getting second and final packet
								begin
									n_state <= UPDATE_A;
									flit_count <= 4'd0;
									a_kj_real <= $bitstoreal(a_kj);
								end

						end

					UPDATE_A:
						begin
							// RTL
							l_ik_real = $bitstoreal(l_ik);
							a_real <= a_real - (lik_akj_real * a_kj_real);

							// NSL
							n_state <= UPDATE_K;
						end

					BROADCAST_A:
						begin
							// RTL
							k <= k+1;
							
							// NSL
							if(k < n-1) begin 		// loop from k=i...n   (not <= because k will be incremented after comparison, n-1 because n is 1 based)
								n_state <= SEND_REQ_A;
							end
							else begin
								n_state <= DONE;
							end
						end

					SEND_REQ_A:
						begin
							send_req <= 1'b1;
							if(req_ack == 1'b1)
								begin
									n_state <= BROADCAST_A_TO_TASKkj;
									send_req <= 1'b0;
									flit_count <= 4'd1;			// begin with flit_count=1;
									src_node <= Node_id;
									dest_node <= (5*k) + j;		// Node_id of vertically lower node (k,j)
									send_data_valid <= 1'b1;
									send_data <= a[63:32];
								end
						end

					BROADCAST_A_TO_TASKkj:
						begin
							// RTL
							if(flit_count == 4'd1) begin
								send_data <= a[31:0];	// second flit data
							end
							if(flit_count == 4'd2) begin
								send_data_valid <= 1'b0;	// this is the last flit, so send as tail
							end

							if(send_data_valid && req_ack)
								flit_count <= flit_count + 1;

							// NSL
							if(req_ack == 0'b0)	// done sending packet of 2 flits
							   begin
								n_state <= BROADCAST_A;
								end
						end

					RECEIVE_Ajj:
						begin
							// RTL
							if(if_i_flit[72])	// valid bit check
								begin
									// Increment flit counter
									flit_count <= flit_count + 1;
									if( flit_count==0 && !if_i_flit[71] )	// first flit of a multiple flit packet
										a_jj[63:32] <= if_i_flit[31:0];
									else if( flit_count==1 && if_i_flit[71] )	// second and last flit of a packet
										a_jj[31:0] <= if_i_flit[31:0];
									else
										$display("Invalid packet received for node%d", Node_id);

								end

							// NSL
							if(flit_count==1 && if_i_flit[72:71]==2'b11)	// getting second and final packet
								begin
									n_state <= CALCULATE_lij;
									flit_count <= 4'd0;
								end

						end

					CALCULATE_lij:
						begin
							// RTL
							a_jj_real = $bitstoreal(a_jj);
							l_ij_real <= a_real / a_jj_real;

							// NSL
							n_state <= BROADCAST_L;
							k <= j; // K begins at j+1, (first incremented in Broadcast_L)
						end

					BROADCAST_L:
						begin
							// RTL
							l_ij <= $realtobits(l_ij_real);
							k <= k + 1;

							// NSL
							if(k < n-1) begin 		// loop from k=i...n   (not <= because k will be incremented after comparison, n-1 because n is 1 based)
								n_state <= SEND_REQ_L;
							end
							else begin
								n_state <= DONE;
							end
						end

					SEND_REQ_L:
						begin

							// RTL
							send_req <= 1'b1;

							// NSL
							if(req_ack == 1'b1)
								begin
									n_state <= BROADCAST_L_TO_TASKik;
									send_req <= 1'b0;
									flit_count <= 4'd1;			// begin with flit_count=1;
									src_node <= Node_id;
									dest_node <= (5*i) + k;		// Node_id of horizontally right node (i,k)
									send_data_valid <= 1'b1;
									send_data <= l_ij[63:32];
								end
						end

					BROADCAST_L_TO_TASKik:
						begin
							// RTL
							if(flit_count == 4'd1) begin
								send_data <= l_ij[31:0];	// second flit data
							end
							if(flit_count == 4'd2) begin
								send_data_valid <= 1'b0;	// this is the last flit, so send as tail
							end

							if(send_data_valid && req_ack)
								flit_count <= flit_count + 1;

							// NSL
							if(req_ack == 0'b0)	// done sending packet of 2 flits
							   begin
								n_state <= BROADCAST_L;
								end
						end

					DONE:
						begin

						end
		          
		        endcase

			end // end else
    
		  
	end // end always

	 m_if_2_router_v3 IF_Router(
		.clk(N_clk), .rst_n(N_rst),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
		.i_comm_send_req(send_req),
		.o_comm_send_ack(req_ack),
		.i_data_valid(send_data_valid),
		.i_data(send_data),
		.i_src(src_node),
		.i_dst(dest_node),
		.local_id(n_ID),
		
		
		//signals Between IF and ROUTER
		.i_credit(if_i_credit),
		.o_credit_valid(if_o_credit_valid),
		.o_credit(if_o_credit),
		.o_data(if_o_data),
		.o_data_valid(if_o_data_valid),
		.i_flit(if_i_flit),


		//Unused
		
		.i_id(unused4),
		.i_ack_rx(unused5),
		.o_req_rx(unused1),
		.o_data_input(unused2),
		.o_data_input_valid(unused1),
		.i_seq_len(unused4)
		);


	PE processor_element(.clk(N_clk), .A(test_value_A), .B(test_value_B), 
						.C(test_value_C), .mult_result(PE_mult_result),
						.add_result(PE_add_result));



endmodule







