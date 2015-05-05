`timescale 1 ns / 100 ps

//`include "matrix_io.sv"

module mn_matrix_tb;

 // global inputs
reg         reset_tb, clk_tb;
reg [7:0]   m_dim_tb, n_dim_tb;
 // constructor inputs
reg               start_tb;
reg [128*128*32-1:0] matrix_in_tb;
 // matrix inputs
reg   write_tb, read_tb;
reg   transpose_tb;
reg [7:0]  m_addr_tb, n_addr_tb;
reg [31:0]  data_in_tb;
	
 // constructor outputs
wire        _write_tb;
wire [7:0]  _m_addr_tb, _n_addr_tb;
wire [31:0] matrix_entry_tb;
wire        q_Idle_tb, q_Construct_tb;
 // matrix outputs
wire [31:0] data_out_tb;

 // testing variables
reg       construct_flag;
reg [7:0] next_m, next_n;
integer i, j, k;
integer f;

 //state string
reg [32*8:1] state_string;

matrix_construct constructor(
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
 
//instantiating the DUT
 mn_matrix dut(
 .reset(reset_tb),
 .clk(clk_tb),
 .write(write_tb),
 .read(read_tb),
 .m_dim(m_dim_tb),
 .n_dim(n_dim_tb),
 .m_addr(m_addr_tb),
 .n_addr(n_addr_tb),
 .transpose(transpose_tb),
 .data_in(data_in_tb),
 .data_out(data_out_tb)
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
      f = $fopen("output.txt");
   end
   
 //generate input stimuli
  initial
   begin
      construct_flag = 0;
  	   @(posedge clk_tb);
  	   #1;
      $fwrite(f, "arr = [1 2 3 4 5 6]\n\n");
      
      m_dim_tb = 3;
      n_dim_tb = 2;
      start_tb = 1;
      matrix_in_tb = {32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1};
      
      @(posedge clk_tb);
      #1;
      start_tb = 0;
      
      wait(construct_flag);
      wait(!construct_flag);
      @(posedge clk_tb);
      #1;
      
      read_matrix(m_dim_tb, n_dim_tb);
      @(posedge clk_tb);
      #1;
      read_matrix_transpose(m_dim_tb, n_dim_tb);
   end

  // connect construct outputs to matrix inputs
  always @(posedge clk_tb)
  begin
      construct_flag <= q_Construct_tb;
      if (construct_flag)
      begin          
          m_addr_tb <= _m_addr_tb;
          n_addr_tb <= _n_addr_tb;
          
          data_in_tb <= matrix_entry_tb;
          write_tb <= _write_tb;
      end
  end

task read_matrix;
  input [31:0] m, n;
   begin
      write_tb = 0;
      read_tb = 1;
      transpose_tb = 0;
      
      $fwrite(f, "matrix A:\n");
      for (i = 0; i < m; i = i + 1)
       begin
          for (j = 0; j < n; j = j + 1)
           begin
              n_addr_tb = j;
              m_addr_tb = i;
              @(posedge clk_tb);
              #1;
              $fwrite(f, "%d\t", data_out_tb);
           end
          $fwrite(f, "\n");
        end
       $fwrite(f, "\n");
   end
endtask

task read_matrix_transpose;
  input [31:0] m, n;
   begin
      write_tb = 0;
      read_tb = 1;
      transpose_tb = 1;
      
      $fwrite(f, "matrix A':\n");
      for (i = 0; i < n; i = i + 1)
       begin
          for (j = 0; j < m; j = j + 1)
           begin
              n_addr_tb = j;
              m_addr_tb = i;
              @(posedge clk_tb);
              #1;
              $fwrite(f, "%d\t", data_out_tb);
           end
          $fwrite(f, "\n");
        end
        $fwrite(f, "\n");
        @(posedge clk_tb);
        #1;
        transpose_tb = 0;
   end
endtask
endmodule //mn_matrix_tb



