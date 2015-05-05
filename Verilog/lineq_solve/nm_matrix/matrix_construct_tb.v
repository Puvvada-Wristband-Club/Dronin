`timescale 1 ns / 100 ps

module matrix_construct_tb;

 // global inputs
reg         reset_tb, clk_tb;
reg [7:0]   m_dim_tb, n_dim_tb;
 // constructor inputs
reg               start_tb;
reg [128*128*32-1:0] matrix_in_tb;
 // matrix inputs
 
 // constructor outputs
wire _write_tb;
wire [7:0]  _m_addr_tb, _n_addr_tb;
wire [31:0] matrix_entry_tb;
wire        q_Idle_tb, q_Construct_tb;

 // testing variables
integer f;

 //state string
reg [32*8:1] state_string;

matrix_construct dut(
 .reset(reset_tb),
 .clk(clk_tb),
 .start(start_tb),
 .m_dim(m_dim_tb),
 .n_dim(n_dim_tb),
 .matrix_in(matrix_in_tb),
 .write(_write_tb),
 .m_addr(_m_addr_tb),
 .n_addr(_n_addr_tb),
 .matrix_entry(matrix_entry_tb),
 .q_Idle(q_Idle_tb),
 .q_Construct(q_Construct_tb)
 );


integer clk_cnt, start_clock_cnt, clocks_taken;
 
//generate the clock
 initial
	begin: CLOCK_GENERATOR
	 clk_tb = 0;
	 forever
		begin
			#5 clk_tb = ~ clk_tb;
		end
	end
	
//generate reset stimulus
initial
  begin  : RESET_GENERATOR
    reset_tb = 1;
	   //initialiaze to avoid red
     #6 reset_tb = 0;
  end
 
//generate clock counter
  initial
   begin  : CLK_COUNTER
    clk_cnt = 0;
	@(posedge clk_tb); // wait until a little after the positive edge
    forever
     begin 
	      @(posedge clk_tb);
		    clk_cnt = clk_cnt + 1;
     end 
   end
 
 //initialize output file
  initial
   begin
      f = $fopen("matrix_construct_tb.txt");
   end
   
 //generate input stimuli
  initial
   begin
      @(posedge clk_tb);
      $fwrite(f, "arr = [1 2 3 4 5 6]\n\n");
      
      m_dim_tb = 3;
      n_dim_tb = 2;
      start_tb = 1;
      matrix_in_tb = {32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1};
      
      @(posedge clk_tb);
      start_tb = 0;
   end
   
endmodule //matrix_construct_tb
