`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Southern California
// Engineer: Anta Imata Safo
// 
// Design Name:    LU Implementation
// Module Name:    matrix_construct
//////////////////////////////////////////////////////////////////////////////////

module matrix_construct(reset, clk, start, m_dim, n_dim, matrix_in,
                        write, m_addr, n_addr, matrix_entry,
                        q_Idle, q_Construct);

 // inputs
input       reset, clk;
input       start;
input [128*128*32-1:0] matrix_in;

input [7:0] m_dim, n_dim;

// outputs
output        write;
output [7:0]  m_addr, n_addr;
output [31:0] matrix_entry;
output        q_Idle, q_Construct;

 // regs
reg        write;
reg [7:0]  m_addr, n_addr;
reg [7:0]   next_m, next_n;
reg [1:0]   state;
reg [31:0]  matrix_entry;

 // loop integers
integer i, head;

 //combination logic assignments
assign	{q_Construct, q_Idle} = state;

 //state machine states
localparam
 IDLE         = 2'b01,
 CONSTRUCT    = 2'b10,
 UNKN         = 2'bxx;

always @(posedge clk, posedge reset) //asynchronous active_high Reset
 begin
    if (reset) 
	  begin
        matrix_entry <= 32'd0;
        state <= IDLE;
	  end
    else // under positive edge of the clock
    begin
        case (state)
            IDLE:
            begin
                write <= 0;
                m_addr <= 0;
                n_addr <= 0;
                head <= 0;
                
                next_m <= 0;
                next_n <= 0;
                
                if (start)
                begin
                    write <= 1;
                    state <= CONSTRUCT;
                end
            end
            CONSTRUCT:
            begin
                // timing hack
                m_addr <= next_m;
                n_addr <= next_n;
                // increment head
                head <= head + 32;
                // move column
                next_n <= next_n + 1;
                // move row
                if (next_n == (n_dim - 1))
                begin
                    next_n <= 0;
                    next_m <= next_m + 1;
                end
                
                for (i = 0; i < 32; i = i + 1)
                begin
                    matrix_entry[i] <= matrix_in[head+i];
                end
                
                if (next_n == (n_dim - 1) && next_m == (m_dim - 1))
                    state <= IDLE;
            end
        endcase
    end
end // end of always procedural block 
endmodule //matrix_construct





