//////////////////////////////////////////////////////////////////////////////////
// Company: University of Southern California
// Engineer: Anta Imata Safo
// 
// Design Name:    LU Implementation
// Module Name:    matrix_make
//////////////////////////////////////////////////////////////////////////////////


module matrix_make(reset, clk, make, m_dim, n_dim, matrix_in, read, m_addr, n_addr, data_out);

 // global inputs
input           reset, clk;
input           make, read;
input [7:0]     m_dim, n_dim;
input [7:0]     m_addr, n_addr;
input [128*128*32-1:0]  matrix_in;
 //global outputs
output [31:0]   data_out;

 // constructor inputs
reg   start;
 // matrix inputs
reg   write;
reg   transpose;
reg [31:0]      data_in;
	
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
 .m_dim(m_dim),
 .n_dim(n_dim),
 .matrix_in(matrix_in),
 .write(_write),
 .m_addr(_m_addr),
 .n_addr(_n_addr),
 .matrix_entry(matrix_entry),
 .q_Idle(q_Idle),
 .q_Construct(q_Construct)
 );
 
mn_matrix matrix(
.reset(reset),
.clk(clk),
.write(write),
.read(read),
.m_dim(m_dim),
.n_dim(n_dim),
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
                
                if (start == 1)
                    start <= 0;
                
                if (counter < m_dim*n_dim*2)
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

