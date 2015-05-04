/*
This is the NODE module for our network that handles the computations for each 
node. The PE(s) and IF module(s) are located here.
*/

module node(N_clk, N_rst_n, input_flit, output_data,
			output_data_valid, out_credit, out_credit_valid, in_credit,
			node_number);

	input N_clk, N_rst_n, in_credit;
	input [4:0] node_number;
	//input [31:0] input_data;
	//input [7:0] source, destination;
	input [68:0] input_flit;				
	//input [4:0] destination;


	output [68:0] output_data;
	output [1:0] out_credit, output_data_valid, out_credit_valid;

	reg [32:0] test_value_A = 32'b01000000001000000000000000000000; 
	reg [32:0] test_value_B = 32'b01000000100000000000000000000000;
	reg [32:0] test_value_C = 32'b00111111100100000000000000000000;
	reg [32:0] data_to_be_sent, input_data;
	reg [7:0]  N_local_id, source, destination;
	reg [5:0] sequence_length, id, name;

	reg i_ack, o0_req, data_to_be_sent_valid;

	reg in_comm_send_request = 0;
	reg out_comm_send_ack = 0;
	reg input_data_valid = 0;

	wire [5:0] PE_mult_result;
	wire [5:0] PE_add_result;

	integer i =0;

	/*always @ (posedge N_clk) begin
	  //for(i = 0; i < 25; i = i + 1) begin
	  name <= node_number;
		if(input_flit[68]) begin // valid flit

       	  $display("Ejecting flit %x at receive port", input_flit[31:0]);
        end
      //end
    end
*/

	m_if_2_router_v3 if_router(.clk(N_clk),.rst_n(N_rst_n),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
		.i_comm_send_req(in_comm_send_request), .o_comm_send_ack(out_comm_send_ack), 
		.i_data_valid(input_data_valid), .i_data(input_data), .i_src(source), 
		.i_dst(destination), .i_seq_len(sequence_length), .i_id(id),
		.i_ack_rx(i_ack), .o_req_rx(o_req),
		.o_data_input(data_to_be_sent),
		.o_data_input_valid(data_to_be_sent_valid),
		//signals Between IF and ROUTER
		.i_credit(in_credit), .o_credit_valid(out_credit_valid), .o_credit(out_credit),
		.o_data(output_data), .o_data_valid(output_data_valid), .i_flit(flit),
		//Tag
		.local_id(N_local_id));

	//testing one pe 
	PE processor_element(.clk(N_clk), .A(test_value_A), .B(test_value_B), 
						.C(test_value_C), .mult_result(PE_mult_result), 
						.add_result(PE_add_result));
	//assign node_number = 

endmodule 