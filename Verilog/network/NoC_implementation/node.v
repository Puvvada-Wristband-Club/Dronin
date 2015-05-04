/*
This is the NODE module for our network that handles the computations for each 
node. The PE(s) and IF module(s) are located here.
*/

module node(N_clk, N_rst_n, input_data, output_data,
			output_data_valid, source, destination,
			out_credit, out_credit_valid, flit);

	input N_clk;
	input N_rst_n;
	input [31:0] input_data; 
	input [68:0] flit;				
	//input [4:0] destination;


	output [68:0] output_data;
	output out_credit, output_data_valid, out_credit_valid;

	reg [3:0] test_value_A = 0; 
	reg [3:0] test_value_B = 2;
	reg [3:0] test_value_C = 4;
	reg [7:0] source, destination;
	reg [5:0] sequence_length, id;

	reg in_comm_send_request = 0;
	reg out_comm_send_ack = 0;
	reg input_data_valid = 0;

	wire [5:0] PE_mult_result;sdfsa
	wire [5:0] PE_add_result;

	m_if_2_router_v3 if_router(.clk(N_clk),.rst_n(N_rst_n),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
		.i_comm_send_req(in_comm_send_request), .o_comm_send_ack(out_comm_send_ack), 
		.i_data_valid(input_data_valid), .i_data(input_data), .i_src(source), 
		.i_dst(destination), .i_seq_len(sequence_length), .i_id(id),
		i_ack_rx, o_req_rx,
		o_data_input,
		o_data_input_valid,
		//signals Between IF and ROUTER
		i_credit, .o_credit_valid(out_credit_valid), .o_credit(out_credit),
		.o_data(output_data), .o_data_valid(output_data_valid),.i_flit(flit),
		//Tag
		local_id);

	//testing one pe 
	PE processor_element(.clk(N_clk), .A(test_value_A), .B(test_value_B), 
						.C(test_value_C), .mult_result(PE_result), 
						.add_result(PE_add_result));


endmoudle 