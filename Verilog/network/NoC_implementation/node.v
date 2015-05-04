

module node(N_clk, N_rst_n, input_data, output_data);

	input N_clk;
	input N_rst_n;
	input [31:0] input_data; 				
	
	output [31:0] output_data;

	reg test_value = 0; 

	m_if_2_router_v3 if_router(
		.clk(N_clk),
		.rst_n(N_rst_n),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
		i_comm_send_req,
		o_comm_send_ack,
		i_data_valid,
		i_data,
		i_src,
		i_dst,
		i_seq_len,
		i_id,
		i_ack_rx,
		o_req_rx,
		o_data_input,
		o_data_input_valid,
		//signals Between IF and ROUTER
		i_credit,
		o_credit_valid,
		o_credit,
		o_data,
		o_data_valid,
		i_flit,
		//Tag
		local_id);


endmoudle 