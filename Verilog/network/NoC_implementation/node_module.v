/*
This is the NODE module for our network that handles the computations for each 
node. The PE(s) and IF module(s) are located here.
*/
`include "connect_parameters.v"


module node_module(N_clk, N_rst, Node_i_flit, 
					Node_i_credit, Node_o_credit_valid,
					Node_o_credit, Node_o_data, Node_o_data_valid, Node_id);
	
	localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
	  reg [vc_bits-1:0]   vc;


	input wire N_clk, N_rst;
	input wire [72:0] Node_i_flit;
	input wire [7:0] Node_id;

	output wire [2:0] Node_i_credit;
	output wire Node_o_credit_valid;
	output wire [2:0] Node_o_credit;
	output wire [72:0] Node_o_data;
	output wire Node_o_data_valid;
	
	reg [31:0] test_value_A = 32'b01000000001000000000000000000000; 
	reg [31:0] test_value_B = 32'b01000000100000000000000000000000;
	reg [31:0] test_value_C = 32'b00111111100100000000000000000000;

	wire Node_o_data_input_valid, Node_o_comm_send_ack, Node_o_req_rx;
	wire [31:0] PE_mult_result, PE_add_result, PE_to_IF_i_data;
	wire [63:0] Node_o_data_input;

	reg PE_add, Node_i_comm_send_req, Node_i_data_valid,
		Node_i_ack_rx;
	reg [7:0] Node_i_src, Node_i_dst;
	reg [7:0] Node_local_id;
	reg [5:0] Node_i_seq_len, Node_i_id;


	reg [3:0] Node_state;
	localparam n_Start = 4'd0;
	localparam n_Sending = 4'd1;
	localparam n_Sent = 4'd2;

	//This selects between the add or multiplication PE result for the PE to IF data 
	//wire: 1 sends the add result and 0 sends the mult result
	assign PE_to_IF_i_data = PE_add ? PE_add_result : PE_mult_result; 

	always @ (posedge N_clk) begin
		if(N_rst == 0)
			begin
				Node_state <= n_Start;
				Node_local_id <= Node_id;
		end

		else begin
			//$display("The outgoing flit is: %x", Node_o_data);
			// send a 2-flit packet from send port 0 to receive port 1
		    Node_i_data_valid <= 1'b1;
		    Node_i_dst <= 8'd4;
		    Node_i_src <= 8'd7;
		    vc = 0;
		    PE_add <=0;
		    //data = 'ha;
		    //Node_o_data <= {1'b1 /*valid*/, 1'b1 /*tail*/, Node_i_dst, vc, PE_to_IF_i_data};
		    if(Node_local_id == 8'd7)
		    	begin
		    	if(!Node_o_comm_send_ack && Node_state == n_Start)
		    		Node_i_comm_send_req <= 1;
		    	else
		    	begin
		    		if(Node_state == n_Start)
		    		begin
		    			Node_state <= n_Sending;
		    			Node_i_data_valid <= 1;
		    		end
		    		else if(Node_state == n_Sending)
		    		begin
		    			Node_state <= n_Sent;
		    			Node_i_data_valid <= 0;
		    		end
		 			//$display("Node%d send data is %b", Node_local_id, PE_to_IF_i_data);
		 		end
		    end

		    if((Node_local_id == 8'd7) && (Node_i_flit[72] == 1))
		    	begin
		    		//$display("Node%d receive data is: %b", Node_local_id, Node_i_flit[31:0]);
       		  		//$display("@%3d: Ejecting flit %x at receive port %0d", cycle, flit_out_wire[i], i);//, nodes[i]);
      		end



		end
	end

	always @ (Node_local_id) begin
		$display("Node local id is: %d", Node_local_id);
	end

	 m_if_2_router_v3 IF_Router(
		.clk(N_clk), .rst_n(N_rst),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
		.i_comm_send_req(Node_i_comm_send_req),
		.o_comm_send_ack(Node_o_comm_send_ack),
		.i_data_valid(Node_i_data_valid),
		.i_data(PE_to_IF_i_data),
		.i_src(Node_i_src),
		.i_dst(Node_i_dst),
		.i_seq_len(Node_i_seq_len),
		.i_id(Node_i_id),
		.i_ack_rx(Node_i_ack_rx),
		.o_req_rx(Node_o_req_rx),
		.o_data_input(Node_o_data_input),
		.o_data_input_valid(Node_o_data_input_valid),
		//signals Between IF and ROUTER
		.i_credit(Node_i_credit),
		.o_credit_valid(Node_o_credit_valid),
		.o_credit(Node_o_credit),
		.o_data(Node_o_data),
		.o_data_valid(Node_o_data_valid),
		.i_flit(Node_i_flit),
		//Tag
		.local_id(Node_local_id)
		);


	PE processor_element(.clk(N_clk), .A(test_value_A), .B(test_value_B), 
						.C(test_value_C), .mult_result(PE_mult_result),
						.add_result(PE_add_result));



endmodule