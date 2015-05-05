/*
This is the NODE module for our network that handles the computations for each 
node. The PE(s) and IF module(s) are located here.
*/
`include "connect_parameters.v"


<<<<<<< HEAD
module node_module(N_clk, N_rst, if_i_flit, 
					if_i_credit, if_o_credit_valid,
					if_o_credit, if_o_data, if_o_data_valid, Node_id);
=======
module node_module(N_clk, N_rst, Node_i_flit, 
					Node_i_credit, Node_o_credit_valid,
					Node_o_credit, Node_o_data, Node_o_data_valid, Node_id);
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c
	
	localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
	  reg [vc_bits-1:0]   vc;


	input wire N_clk, N_rst;
<<<<<<< HEAD
	input wire [72:0] if_i_flit;
	input wire [7:0] Node_id;

	output wire [2:0] if_i_credit;
	output wire if_o_credit_valid;
	output wire [2:0] if_o_credit;
	output wire [72:0] if_o_data;
	output wire if_o_data_valid;
=======
	input wire [72:0] Node_i_flit;
	input wire [7:0] Node_id;

	output wire [2:0] Node_i_credit;
	output wire Node_o_credit_valid;
	output wire [2:0] Node_o_credit;
	output wire [72:0] Node_o_data;
	output wire Node_o_data_valid;
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c
	
	reg [31:0] test_value_A = 32'b01000000001000000000000000000000; 
	reg [31:0] test_value_B = 32'b01000000100000000000000000000000;
	reg [31:0] test_value_C = 32'b00111111100100000000000000000000;

<<<<<<< HEAD
	wire req_ack;
	wire [31:0] PE_mult_result, PE_add_result, send_data;
	

	reg PE_add, send_req, send_data_valid;
	reg [7:0] src_node, dest_node;

	// unused
	wire unused1;
	wire [63:0] unused2;
	reg [7:0] unused3;
	reg [5:0] unused4;
	reg unused5;
=======
	wire Node_o_data_input_valid, Node_o_comm_send_ack, Node_o_req_rx;
	wire [31:0] PE_mult_result, PE_add_result, PE_to_IF_i_data;
	wire [63:0] Node_o_data_input;

	reg PE_add, Node_i_comm_send_req, Node_i_data_valid,
		Node_i_ack_rx;
	reg [7:0] Node_i_src, Node_i_dst;
	reg [7:0] Node_local_id;
	reg [5:0] Node_i_seq_len, Node_i_id;
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c


	reg [3:0] Node_state;
	localparam n_Start = 4'd0;
	localparam n_Sending = 4'd1;
	localparam n_Sent = 4'd2;

	//This selects between the add or multiplication PE result for the PE to IF data 
	//wire: 1 sends the add result and 0 sends the mult result
<<<<<<< HEAD
	//assign send_data = PE_add ? PE_add_result : PE_mult_result; 
	assign send_data = PE_add ? 32'b11111111111111111111111111111111 : PE_mult_result; 
=======
	assign PE_to_IF_i_data = PE_add ? PE_add_result : PE_mult_result; 
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c

	always @ (posedge N_clk) begin
		if(N_rst == 0)
			begin
				Node_state <= n_Start;
<<<<<<< HEAD
				unused3 <= Node_id;
		    src_node <= 8'd7;
				dest_node <= 8'd4;
				send_data_valid <= 1'b0;
		end

		else 
		  begin
			//$display("The outgoing flit is: %x", if_o_data);
			// send a 2-flit packet from send port 0 to receive port 1
		    
		    vc = 0;
		    PE_add <= 1;
		    //data = 'ha;
		    //if_o_data <= {1'b1 /*valid*/, 1'b1 /*tail*/, dest_node, vc, send_data};
		    if(unused3 == 8'd7)
		      begin
		    	   if(!req_ack && Node_state == n_Start)
		    		    send_req <= 1;
		    	   else
		    	     begin
		    		      if(Node_state == n_Start)
		    		        begin
		    			         Node_state <= n_Sending;
		    			         send_data_valid <= 1;
		    		        end
		    		      else if(Node_state == n_Sending)
		    		        begin
		    			         Node_state <= n_Sent;
		    			         send_data_valid <= 0;
		    		        end
		 			//$display("Node%d send data is %b", unused3, send_data);
		 		   end
		  end
    // end else
    
		  if((unused3 == 8'd4) && (if_i_flit[72] == 1))
		    begin
		    		$display("Node%d received data is: %b", unused3, if_i_flit[31:0]);
   		  		 //$display("@%3d: Ejecting flit %x at receive port %0d", cycle, flit_out_wire[i], i);//, nodes[i]);
	      end
=======
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
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c



		end
	end

<<<<<<< HEAD
=======
	always @ (Node_local_id) begin
		$display("Node local id is: %d", Node_local_id);
	end

>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c
	 m_if_2_router_v3 IF_Router(
		.clk(N_clk), .rst_n(N_rst),
		//general sending interface for master pe and mig_office
		//signals between PE and IF
<<<<<<< HEAD
		.i_comm_send_req(send_req),
		.o_comm_send_ack(req_ack),
		.i_data_valid(send_data_valid),
		.i_data(send_data),
		.i_src(src_node),
		.i_dst(dest_node),
		
		
		//signals Between IF and ROUTER
		.i_credit(if_i_credit),
		.o_credit_valid(if_o_credit_valid),
		.o_credit(if_o_credit),
		.o_data(if_o_data),
		.o_data_valid(if_o_data_valid),
		.i_flit(if_i_flit),


		//Unused
		.local_id(unused3),
		.i_id(unused4),
		.i_ack_rx(unused5),
		.o_req_rx(unused1),
		.o_data_input(unused2),
		.o_data_input_valid(unused1),
		.i_seq_len(unused4)
=======
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
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c
		);


	PE processor_element(.clk(N_clk), .A(test_value_A), .B(test_value_B), 
						.C(test_value_C), .mult_result(PE_mult_result),
						.add_result(PE_add_result));



<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> 8e3a23948499117268378fa8b11e7f4d3a1c0a3c
