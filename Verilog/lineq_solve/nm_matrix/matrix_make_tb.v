`timescale 1 ns / 100 ps

module matrix_make_tb;

 // inputs
reg   reset_tb, clk_tb;
reg   make_tb;
reg [7:0]             m1_dim_tb, n1_dim_tb;
reg [128*128*32-1:0]  matrix1_in_tb;

 // outputs
wire [128*128*32-1:0] matrix_out_tb;

 // testing variables
integer f;

 //state string
reg [32*8:1] state_string;

matrix_make dut(
 .reset(reset_tb),
 .clk(clk_tb),
 .make(make_tb),
 .m1_dim(m1_dim_tb),
 .n1_dim(n1_dim_tb),
 .matrix1_in(matrix1_in_tb),
 .matrix_out(matrix_out_tb)
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
      f = $fopen("matrix_make_tb.txt");
   end
   
 //generate input stimuli
  initial
   begin
      @(posedge clk_tb);
      $fwrite(f, "arr = [1 2 3 4 5 6]\n\n");
      m1_dim_tb = 3;
      n1_dim_tb = 2;
      matrix1_in_tb = {32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1};
   end
   
endmodule //matrix_make_tb
