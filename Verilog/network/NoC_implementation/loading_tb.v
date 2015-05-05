
`timescale 1ns / 1ps

`include "connect_parameters.v"


module loading_tb();
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2*HalfClkPeriod;

  // non-VC routers still reeserve 1 dummy bit for VC.
  localparam vc_bits = (`NUM_VCS > 1) ? $clog2(`NUM_VCS) : 1;
  localparam dest_bits = $clog2(`NUM_USER_RECV_PORTS);
  localparam flit_port_width = 2 /*valid and tail bits*/+ `FLIT_DATA_WIDTH + dest_bits + vc_bits;
  localparam credit_port_width = 1 + vc_bits; // 1 valid bit
  localparam test_cycles = 50;

  //VC counters each of 4 bits for each virtual channel
  reg [3:0] counter [0:1]; 

  reg Clk;
  reg Rst_n;

  // input regs
  //reg send_flit [0:`NUM_USER_SEND_PORTS-1]; // enable sending flits
  wire send_flit_wire [0:`NUM_USER_SEND_PORTS-1];
  wire [flit_port_width-1:0] flit_in_wire [0:`NUM_USER_SEND_PORTS-1]; // send port inputs

  wire send_credit_wire [0:`NUM_USER_RECV_PORTS-1]; // enable sending credits
  wire [credit_port_width-1:0] credit_in_wire [0:`NUM_USER_RECV_PORTS-1]; //recv port credits

  // output wires
  wire [credit_port_width-1:0] credit_out_wire [0:`NUM_USER_SEND_PORTS-1];
  wire [flit_port_width-1:0] flit_out_wire [0:`NUM_USER_RECV_PORTS-1];

  reg [31:0] cycle;
  integer i,j;
  //integer j;

  // packet fields
  reg is_valid;
  reg is_tail;
  reg [dest_bits-1:0] dest;
  reg [vc_bits-1:0]   vc;
  reg [`FLIT_DATA_WIDTH-1:0] data;

	//This is the signals for the Matrix testing
	 // inputs
	reg make_tb;
	reg [7:0]             m1_dim_tb, n1_dim_tb;
	reg [128*128*32-1:0]  matrix1_in_tb;

	 // outputs
	wire [128*128*32-1:0] matrix_out_tb;

	matrix_make matrix_dut(
	 .reset(~Rst_n),
	 .clk(Clk),
	 .make(make_tb),
	 .m1_dim(m1_dim_tb),
	 .n1_dim(n1_dim_tb),
	 .matrix1_in(matrix1_in_tb),
	 .matrix_out(matrix_out_tb)
	 );

	 // testing variables
	integer f;


  // Generate Clock
  initial Clk = 0;
  always #(HalfClkPeriod) Clk = ~Clk;

  // Run simulation 
  initial begin 
    cycle = 0;
    Rst_n = 0;
    #(ClkPeriod);
    Rst_n = 1;


	end
  // Monitor arriving flits
  always @ (posedge Clk) begin
    cycle <= cycle + 1;
    for(i = 0; i < `NUM_USER_RECV_PORTS; i = i + 1) begin
      if(flit_out_wire[i][flit_port_width-1]) begin // valid flit

        $display("@%3d: Ejecting flit %x at receive port %0d", cycle, flit_out_wire[i], i);//, nodes[i]);
      end
    end

    // terminate simulation
    if (cycle > test_cycles) begin
      //$finish();
    end
  end

 //generate input stimuli
  initial
   begin
      @(posedge Clk);
      //$fwrite(f, "arr = [1 2 3 4 5 6]\n\n");
      m1_dim_tb = 4;
      n1_dim_tb = 4;
      matrix1_in_tb = {32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1};
   end
   
  // Add your code to handle flow control here (sending receiving credits)

  
  // Instantiate CONNECT network
  
  //Here is the instantialtion of the 25 Nodes. Use a generate block to instantiate 
  //the 25 nodes dynamically. The nodes start at 1 (pre-testing phase)

  /*node_module Node_4(.N_clk(Clk), .N_rst(Rst_n), .Node_i_flit(flit_out_wire[4]),
              .Node_i_credit(credit_out_wire[4]), .Node_o_credit_valid(send_credit_wire[4]),
              .Node_o_credit(credit_in_wire[4]), .Node_o_data(flit_in_wire[4]), 
              .Node_o_data_valid(send_flit_wire[4]), .Node_id(4));

  node_module Node_7(.N_clk(Clk), .N_rst(Rst_n), .Node_i_flit(flit_out_wire[7]),
              .Node_i_credit(credit_out_wire[7]), .Node_o_credit_valid(send_credit_wire[7]),
              .Node_o_credit(credit_in_wire[7]), .Node_o_data(flit_in_wire[7]), 
              .Node_o_data_valid(send_flit_wire[7]), .Node_id(7));*/
 generate 

    genvar g;

      for(g=0; g<25; g=g+1) begin
        
        node_module Nodes(.N_clk(Clk), .N_rst(Rst_n), .Node_i_flit(flit_out_wire[g]),
                    .Node_i_credit(credit_out_wire[g]), .Node_o_credit_valid(send_credit_wire[g]),
                    .Node_o_credit(credit_in_wire[g]), .Node_o_data(flit_in_wire[g]), 
                    .Node_o_data_valid(send_flit_wire[g]), .Node_id(g));
      end

 endgenerate

  
  mkNetwork dut
  (.CLK(Clk)
   ,.RST_N(Rst_n)

   ,.send_ports_0_putFlit_flit_in(flit_in_wire[0])
   ,.EN_send_ports_0_putFlit(send_flit_wire[0])

   ,.EN_send_ports_0_getCredits(1'b1) // drain credits
   ,.send_ports_0_getCredits(credit_out_wire[0])

     ,.send_ports_1_putFlit_flit_in(flit_in_wire[1])
     ,.EN_send_ports_1_putFlit(send_flit_wire[1])

     ,.EN_send_ports_1_getCredits(1'b1) // drain credits
     ,.send_ports_1_getCredits(credit_out_wire[1])

     // add rest of send ports here
     ,.send_ports_2_putFlit_flit_in(flit_in_wire[2])
     ,.EN_send_ports_2_putFlit(send_flit_wire[2])
      
     ,.EN_send_ports_2_getCredits(1'b1) // drain credits
     ,.send_ports_2_getCredits(credit_out_wire[2])
     
     ,.send_ports_3_putFlit_flit_in(flit_in_wire[3])
  	 ,.EN_send_ports_3_putFlit(send_flit_wire[3])

  		,.EN_send_ports_3_getCredits(1'b1) // drain credits
  		,.send_ports_3_getCredits(credit_out_wire[3])

  		,.send_ports_4_putFlit_flit_in(flit_in_wire[4])
  		,.EN_send_ports_4_putFlit(send_flit_wire[4])

  		,.EN_send_ports_4_getCredits(1'b1)
  		,.send_ports_4_getCredits(credit_out_wire[4])

		 ,.send_ports_5_putFlit_flit_in(flit_in_wire[5])
		 ,.EN_send_ports_5_putFlit(send_flit_wire[5])

		 ,.EN_send_ports_5_getCredits(1'b1)
		 ,.send_ports_5_getCredits(credit_out_wire[5])
 
		 ,.send_ports_6_putFlit_flit_in(flit_in_wire[6])
		 ,.EN_send_ports_6_putFlit(send_flit_wire[6])

		 ,.EN_send_ports_6_getCredits(1'b1)
		 ,.send_ports_6_getCredits(credit_out_wire[6])

		 ,.send_ports_7_putFlit_flit_in(flit_in_wire[7])
		 ,.EN_send_ports_7_putFlit(send_flit_wire[7])

		 ,.EN_send_ports_7_getCredits(1'b1)
		 ,.send_ports_7_getCredits(credit_out_wire[7])

		 ,.send_ports_8_putFlit_flit_in(flit_in_wire[8])
		 ,.EN_send_ports_8_putFlit(send_flit_wire[8])

		 ,.EN_send_ports_8_getCredits(1'b1)
		 ,.send_ports_8_getCredits(credit_out_wire[8])

		 ,.send_ports_9_putFlit_flit_in(flit_in_wire[9])
		 ,.EN_send_ports_9_putFlit(send_flit_wire[9])

		 ,.EN_send_ports_9_getCredits(1'b1)
		 ,.send_ports_9_getCredits(credit_out_wire[9])

		 ,.send_ports_10_putFlit_flit_in(flit_in_wire[10])
		 ,.EN_send_ports_10_putFlit(send_flit_wire[10])

		 ,.EN_send_ports_10_getCredits(1'b1)
		 ,.send_ports_10_getCredits(credit_out_wire[10])

		 ,.send_ports_11_putFlit_flit_in(flit_in_wire[11])
		 ,.EN_send_ports_11_putFlit(send_flit_wire[11])

		 ,.EN_send_ports_11_getCredits(1'b1)
		 ,.send_ports_11_getCredits(credit_out_wire[11])

		 ,.send_ports_12_putFlit_flit_in(flit_in_wire[12])
		 ,.EN_send_ports_12_putFlit(send_flit_wire[12])

		 ,.EN_send_ports_12_getCredits(1'b1)
		 ,.send_ports_12_getCredits(credit_out_wire[12])

		 ,.send_ports_13_putFlit_flit_in(flit_in_wire[13])
		 ,.EN_send_ports_13_putFlit(send_flit_wire[13])

		 ,.EN_send_ports_13_getCredits(1'b1)
		 ,.send_ports_13_getCredits(credit_out_wire[13])

		 ,.send_ports_14_putFlit_flit_in(flit_in_wire[14])
		 ,.EN_send_ports_14_putFlit(send_flit_wire[14])

		 ,.EN_send_ports_14_getCredits(1'b1)
		 ,.send_ports_14_getCredits(credit_out_wire[14])

		 ,.send_ports_15_putFlit_flit_in(flit_in_wire[15])
		 ,.EN_send_ports_15_putFlit(send_flit_wire[15])

		 ,.EN_send_ports_15_getCredits(1'b1)
		 ,.send_ports_15_getCredits(credit_out_wire[15])

		 ,.send_ports_16_putFlit_flit_in(flit_in_wire[16])
		 ,.EN_send_ports_16_putFlit(send_flit_wire[16])

		 ,.EN_send_ports_16_getCredits(1'b1)
		 ,.send_ports_16_getCredits(credit_out_wire[16])

		 ,.send_ports_17_putFlit_flit_in(flit_in_wire[17])
		 ,.EN_send_ports_17_putFlit(send_flit_wire[17])

		 ,.EN_send_ports_17_getCredits(1'b1)
		 ,.send_ports_17_getCredits(credit_out_wire[17])

		 ,.send_ports_18_putFlit_flit_in(flit_in_wire[18])
		 ,.EN_send_ports_18_putFlit(send_flit_wire[18])

		 ,.EN_send_ports_18_getCredits(1'b1)
		 ,.send_ports_18_getCredits(credit_out_wire[18])

		 ,.send_ports_19_putFlit_flit_in(flit_in_wire[19])
		 ,.EN_send_ports_19_putFlit(send_flit_wire[19])

		 ,.EN_send_ports_19_getCredits(1'b1)
		 ,.send_ports_19_getCredits(credit_out_wire[19])

		 ,.send_ports_20_putFlit_flit_in(flit_in_wire[20])
		 ,.EN_send_ports_20_putFlit(send_flit_wire[20])

		 ,.EN_send_ports_20_getCredits(1'b1)
		 ,.send_ports_20_getCredits(credit_out_wire[20])

		 ,.send_ports_21_putFlit_flit_in(flit_in_wire[21])
		 ,.EN_send_ports_21_putFlit(send_flit_wire[21])

		 ,.EN_send_ports_21_getCredits(1'b1)
		 ,.send_ports_21_getCredits(credit_out_wire[21])

		 ,.send_ports_22_putFlit_flit_in(flit_in_wire[22])
		 ,.EN_send_ports_22_putFlit(send_flit_wire[22])

		 ,.EN_send_ports_22_getCredits(1'b1)
		 ,.send_ports_22_getCredits(credit_out_wire[22])

		 ,.send_ports_23_putFlit_flit_in(flit_in_wire[23])
		 ,.EN_send_ports_23_putFlit(send_flit_wire[23])

		 ,.EN_send_ports_23_getCredits(1'b1)
		 ,.send_ports_23_getCredits(credit_out_wire[23])

		 ,.send_ports_24_putFlit_flit_in(flit_in_wire[24])
		 ,.EN_send_ports_24_putFlit(send_flit_wire[24])

		 ,.EN_send_ports_24_getCredits(1'b1)
		 ,.send_ports_24_getCredits(credit_out_wire[24])
   

   ,.EN_recv_ports_0_getFlit(1'b1) // drain flits
   ,.recv_ports_0_getFlit(flit_out_wire[0])

   ,.recv_ports_0_putCredits_cr_in(credit_in_wire[0])
   ,.EN_recv_ports_0_putCredits(send_credit_wire[0])

     ,.EN_recv_ports_1_getFlit(1'b1) // drain flits
     ,.recv_ports_1_getFlit(flit_out_wire[1])

     ,.recv_ports_1_putCredits_cr_in(credit_in_wire[1])
     ,.EN_recv_ports_1_putCredits(send_credit_wire[1])

     // add rest of receive ports here
     ,.EN_recv_ports_2_getFlit(1'b1) // drain flits
     ,.recv_ports_2_getFlit(flit_out_wire[2])

     ,.recv_ports_2_putCredits_cr_in(credit_in_wire[2])
     ,.EN_recv_ports_2_putCredits(send_credit_wire[2])

     ,.EN_recv_ports_3_getFlit(1'b1) // drain flits
     ,.recv_ports_3_getFlit(flit_out_wire[3])

     ,.recv_ports_3_putCredits_cr_in(credit_in_wire[3])
     ,.EN_recv_ports_3_putCredits(send_credit_wire[3])

     ,.EN_recv_ports_4_getFlit(1'b1) // drain flits
     ,.recv_ports_4_getFlit(flit_out_wire[4])

     ,.recv_ports_4_putCredits_cr_in(credit_in_wire[4])
     ,.EN_recv_ports_4_putCredits(send_credit_wire[4])

     ,.EN_recv_ports_5_getFlit(1'b1) // drain flits
     ,.recv_ports_5_getFlit(flit_out_wire[5])

     ,.recv_ports_5_putCredits_cr_in(credit_in_wire[5])
     ,.EN_recv_ports_5_putCredits(send_credit_wire[5])

     ,.EN_recv_ports_6_getFlit(1'b1) // drain flits
     ,.recv_ports_6_getFlit(flit_out_wire[6])

     ,.recv_ports_6_putCredits_cr_in(credit_in_wire[6])
     ,.EN_recv_ports_6_putCredits(send_credit_wire[6])

     ,.EN_recv_ports_7_getFlit(1'b1) // drain flits
     ,.recv_ports_7_getFlit(flit_out_wire[7])

     ,.recv_ports_7_putCredits_cr_in(credit_in_wire[7])
     ,.EN_recv_ports_7_putCredits(send_credit_wire[7])

     ,.EN_recv_ports_8_getFlit(1'b1) // drain flits
     ,.recv_ports_8_getFlit(flit_out_wire[8])

     ,.recv_ports_8_putCredits_cr_in(credit_in_wire[8])
     ,.EN_recv_ports_8_putCredits(send_credit_wire[8])

     ,.EN_recv_ports_9_getFlit(1'b1) // drain flits
     ,.recv_ports_9_getFlit(flit_out_wire[9])

     ,.recv_ports_9_putCredits_cr_in(credit_in_wire[9])
     ,.EN_recv_ports_9_putCredits(send_credit_wire[9])

     ,.EN_recv_ports_10_getFlit(1'b1) // drain flits
     ,.recv_ports_10_getFlit(flit_out_wire[10])

     ,.recv_ports_10_putCredits_cr_in(credit_in_wire[10])
     ,.EN_recv_ports_10_putCredits(send_credit_wire[10])

     ,.EN_recv_ports_11_getFlit(1'b1) // drain flits
     ,.recv_ports_11_getFlit(flit_out_wire[11])

     ,.recv_ports_11_putCredits_cr_in(credit_in_wire[11])
     ,.EN_recv_ports_11_putCredits(send_credit_wire[11])

     ,.EN_recv_ports_12_getFlit(1'b1) // drain flits
     ,.recv_ports_12_getFlit(flit_out_wire[12])

     ,.recv_ports_12_putCredits_cr_in(credit_in_wire[12])
     ,.EN_recv_ports_12_putCredits(send_credit_wire[12])

     ,.EN_recv_ports_13_getFlit(1'b1) // drain flits
     ,.recv_ports_13_getFlit(flit_out_wire[13])

     ,.recv_ports_13_putCredits_cr_in(credit_in_wire[13])
     ,.EN_recv_ports_13_putCredits(send_credit_wire[13])

     ,.EN_recv_ports_14_getFlit(1'b1) // drain flits
     ,.recv_ports_14_getFlit(flit_out_wire[14])

     ,.recv_ports_14_putCredits_cr_in(credit_in_wire[14])
     ,.EN_recv_ports_14_putCredits(send_credit_wire[14])

     ,.EN_recv_ports_15_getFlit(1'b1) // drain flits
     ,.recv_ports_15_getFlit(flit_out_wire[15])

     ,.recv_ports_15_putCredits_cr_in(credit_in_wire[15])
     ,.EN_recv_ports_15_putCredits(send_credit_wire[15])

     ,.EN_recv_ports_16_getFlit(1'b1) // drain flits
     ,.recv_ports_16_getFlit(flit_out_wire[16])

     ,.recv_ports_16_putCredits_cr_in(credit_in_wire[16])
     ,.EN_recv_ports_16_putCredits(send_credit_wire[16])

     ,.EN_recv_ports_17_getFlit(1'b1) // drain flits
     ,.recv_ports_17_getFlit(flit_out_wire[17])

     ,.recv_ports_17_putCredits_cr_in(credit_in_wire[17])
     ,.EN_recv_ports_17_putCredits(send_credit_wire[17])

     ,.EN_recv_ports_18_getFlit(1'b1) // drain flits
     ,.recv_ports_18_getFlit(flit_out_wire[18])

     ,.recv_ports_18_putCredits_cr_in(credit_in_wire[18])
     ,.EN_recv_ports_18_putCredits(send_credit_wire[18])

     ,.EN_recv_ports_19_getFlit(1'b1) // drain flits
     ,.recv_ports_19_getFlit(flit_out_wire[19])

     ,.recv_ports_19_putCredits_cr_in(credit_in_wire[19])
     ,.EN_recv_ports_19_putCredits(send_credit_wire[19])

     ,.EN_recv_ports_20_getFlit(1'b1) // drain flits
     ,.recv_ports_20_getFlit(flit_out_wire[20])

     ,.recv_ports_20_putCredits_cr_in(credit_in_wire[20])
     ,.EN_recv_ports_20_putCredits(send_credit_wire[20])

     ,.EN_recv_ports_21_getFlit(1'b1) // drain flits
     ,.recv_ports_21_getFlit(flit_out_wire[21])

     ,.recv_ports_21_putCredits_cr_in(credit_in_wire[21])
     ,.EN_recv_ports_21_putCredits(send_credit_wire[21])

     ,.EN_recv_ports_22_getFlit(1'b1) // drain flits
     ,.recv_ports_22_getFlit(flit_out_wire[22])

     ,.recv_ports_22_putCredits_cr_in(credit_in_wire[22])
     ,.EN_recv_ports_22_putCredits(send_credit_wire[22])

     ,.EN_recv_ports_23_getFlit(1'b1) // drain flits
     ,.recv_ports_23_getFlit(flit_out_wire[23])

     ,.recv_ports_23_putCredits_cr_in(credit_in_wire[23])
     ,.EN_recv_ports_23_putCredits(send_credit_wire[23])

     ,.EN_recv_ports_24_getFlit(1'b1) // drain flits
     ,.recv_ports_24_getFlit(flit_out_wire[24])

     ,.recv_ports_24_putCredits_cr_in(credit_in_wire[24])
     ,.EN_recv_ports_24_putCredits(send_credit_wire[24])
   );


endmodule