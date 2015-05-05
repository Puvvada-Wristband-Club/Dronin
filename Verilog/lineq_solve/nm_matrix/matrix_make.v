//////////////////////////////////////////////////////////////////////////////////
// Company: University of Southern California
// Engineer: Anta Imata Safo
// 
// Design Name:    LU Implementation
// Module Name:    matrix_make
//////////////////////////////////////////////////////////////////////////////////


module matrix_make(reset, clk, make, m1_dim, n1_dim, matrix1_in, matrix_out);

 // global inputs
input         reset, clk;
input         make;
input [7:0]   m1_dim, n1_dim;
input [128*128*32-1:0]  matrix1_in;
// global outputs
output [128*128*32-1:0]    matrix_out;

 // constructor inputs
reg   start;
 // matrix inputs
reg   write, read;
reg   transpose;
reg [7:0]   m_addr, n_addr;
reg [31:0]  data_in;
	
 // constructor outputs
wire        _write, construct_done;
wire [7:0]  _m_addr, _n_addr;
wire [31:0] matrix_entry;
wire        q_Idle, q_Construct;
 // matrix outputs
wire [31:0] data_out;

 // regs
reg [1:0]               state;
reg [128*128*32-1:0]    matrix_out;

reg          construct_lag; //timing hack
reg [15:0]   counter;

 // loop integers
integer i, j, k;

 //state machine states
localparam
 IDLE       = 2'b01,
 COMPUTE    = 2'b10,
 UNKN       = 2'bxx;

matrix_construct constructor(
 .reset(reset),
 .clk(clk),
 .start(start),
 .m_dim(m1_dim),
 .n_dim(n1_dim),
 .matrix_in(matrix1_in),
 .write(_write),
 .construct_done(construct_done),
 .m_addr(_m_addr),
 .n_addr(_n_addr),
 .matrix_entry(matrix_entry),
 .q_Idle(q_Idle),
 .q_Construct(q_Construct)
 );
 
mn_matrix matrix1(
.reset(reset),
.clk(clk),
.write(write),
.read(read1),
.m_dim(m1_dim),
.n_dim(n1_dim),
.m_addr(m_addr),
.n_addr(n_addr),
.transpose(transpose),
.data_in(data_in),
.data_out(data_out)
);
 
always @(posedge clk, posedge reset) //asynchronous active_high Reset
 begin
    if (reset) 
	   begin
	       matrix_out <= 0;
	       start <= 0;
	       counter <= 0;
	       state <= IDLE;
	   end
    else // under positive edge of the clock
     begin
        case (state)
            IDLE:
            begin
                start <= 1;
                counter <= counter + 1;
                //construct_lag <= construct_done;
                
                if (start == 1)
                    start <= 0;
                
                if (counter < m1_dim*n1_dim*2)
                  begin
                      m_addr <= _m_addr;
                      n_addr <= _n_addr;
          
                      data_in <= matrix_entry;
                      write <= _write;
                  end
                else
                    state <= COMPUTE;
            end
            COMPUTE:
            begin
                
            end
        endcase
    end
end
endmodule

