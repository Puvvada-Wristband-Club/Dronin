
module DataTransferUnit (clk, phy_clk, dtu_write_req, dtu_read_req, dtu_mem_addr, dtu_ram_addr, dtu_size, dtu_ack, dtu_done,
		ram_read_addr, ram_read_data, ram_write_byte_en, ram_write_data, ram_write_addr, ram_write_en,
		mem_rdata, mem_rdata_valid, mem_ready, mem_wdata_req, reset_n,
		burst_begin, mem_local_addr, mem_be, mem_read_req, mem_size, mem_wdata, mem_write_req);

parameter BURSTLEN = 2, BURSTWIDTH = 2;
parameter DATAWIDTH = 256, DATANUMBYTES = 32;
parameter MEMCONWIDTH = 128, MEMCONNUMBYTES = 16, DDRSIZEWIDTH = 24;
parameter FIFOSIZE = 16, FIFOSIZEWIDTH = 4;
parameter RAMWIDTH = 256, RAMNUMBYTES = 32, RAMSIZEWIDTH = 7;
parameter RATIO = 2, RAMLAT = 5;

output burst_begin;
output [DDRSIZEWIDTH-1:0] mem_local_addr;
output [MEMCONNUMBYTES-1: 0] mem_be;
output mem_read_req;
output [BURSTWIDTH-1:0] mem_size;
output [MEMCONWIDTH-1:0] mem_wdata;
output mem_write_req;
input clk, phy_clk;
input [MEMCONWIDTH-1:0] mem_rdata;
input mem_rdata_valid;
input mem_ready;
input mem_wdata_req;
input reset_n;

input dtu_write_req;
input dtu_read_req;
input [DDRSIZEWIDTH-1:0] dtu_mem_addr;
input [RAMSIZEWIDTH-1:0] dtu_ram_addr;
input [5:0] dtu_size;
output dtu_ack;
output dtu_done;

output[RAMWIDTH-1:0] ram_write_data;
input[RAMWIDTH-1:0] ram_read_data;
output[RAMSIZEWIDTH-1:0] ram_write_addr, ram_read_addr;
output[RAMNUMBYTES-1:0] ram_write_byte_en;
output ram_write_en;

parameter IDLE = 0, WRITE = 1, READ = 2;
reg [DDRSIZEWIDTH-1:0] mem_addr[RAMLAT:0];
reg [2:0] state;
wire [DATAWIDTH-1:0] rdata, ram_write_dataw, ram_read_dataw;

wire [RAMSIZEWIDTH-1:0] rfifo_addr;
reg fifo_write_reg[RAMLAT-1:0];
reg write_req_reg[RAMLAT-1:0];
reg read_req_reg[RAMLAT-1:0];
reg fifo_read_reg[0:0];
reg rdata_valid;
reg test_complete_reg[1:0];
reg [BURSTWIDTH-1:0] size_count[RAMLAT-1:0];
reg [RAMSIZEWIDTH-1:0] size;
reg [RAMSIZEWIDTH-1:0] ram_addr[RAMLAT-1:0];
reg [1:0] data_count;
reg ram_write_en_reg;

wire read_req;
wire write_req;
wire [FIFOSIZEWIDTH-1:0] wfifo_count;
wire rfull, wempty, rempty, rdcmd_empty, wrcmd_full, wrcmd_empty, rdata_empty;
wire [DATAWIDTH-1:0] mem_data;
wire not_stall;
wire fifo_write, fifo_read;
wire rdata_req;
wire [BURSTWIDTH+DDRSIZEWIDTH+1:0] wrmem_cmd, rdmem_cmd;
wire mem_cmd_ready, mem_cmd_issue;

// FIFOs to interact with off-chip memory
memcmd_fifo cmd_store(
	.aclr(~reset_n),
	.rdclk(phy_clk),
	.wrclk(clk),
	.data(wrmem_cmd),
	.rdreq(mem_cmd_ready),
	.rdempty(rdcmd_empty),
	.wrreq(mem_cmd_issue),
	.wrfull(wrcmd_full),
	.wrempty(wrcmd_empty),
	.q(rdmem_cmd));

wfifo wdata_store(
	.rdclk(phy_clk),
	.wrclk(clk),
	.data(mem_data),
	.rdreq(mem_wdata_req),
	.wrreq(fifo_write),
	.wrempty(wempty),
	.q(mem_wdata),
	.wrusedw(wfifo_count));

addr_fifo raddress_store (
	.clock(clk),
	.data(ram_addr[RAMLAT-2]),
	.rdreq(rdata_req),
	.wrreq(fifo_read),
	.empty(rempty),
	.full(rfull),
	.q(rfifo_addr));

rfifo rdata_store(
	.data(mem_rdata),
	.rdclk(clk),
	.rdreq(rdata_req),
	.wrclk(phy_clk),
	.wrreq(mem_rdata_valid),
	.q(rdata),
	.rdempty(rdata_empty));

assign mem_cmd_ready = (mem_ready == 1) && (rdcmd_empty == 0);
assign mem_cmd_issue = (wrcmd_full == 0) && (write_req == 1 || read_req == 1 || wrcmd_empty == 1);
assign wrmem_cmd[BURSTWIDTH+DDRSIZEWIDTH+1:DDRSIZEWIDTH+2] = size_count[0];
assign wrmem_cmd[DDRSIZEWIDTH+1:2] = mem_addr[0];
assign wrmem_cmd[1] = read_req;
assign wrmem_cmd[0] = write_req;
assign mem_write_req = rdmem_cmd[0] && rdcmd_empty == 0;
assign mem_read_req = rdmem_cmd[1] && rdcmd_empty == 0;
assign mem_local_addr = rdmem_cmd[DDRSIZEWIDTH+1:2];
assign burst_begin = 0;
assign mem_size = rdmem_cmd[BURSTWIDTH+DDRSIZEWIDTH+1:DDRSIZEWIDTH+2];
assign mem_be = ~0;
assign fifo_write = fifo_write_reg[0];
assign write_req = (not_stall) ? write_req_reg[0] : 0;
assign read_req = (not_stall) ? read_req_reg[0] : 0;
assign fifo_read = (not_stall) ? fifo_read_reg[0] : 0;
assign not_stall = (wfifo_count < FIFOSIZE-5) && (rfull == 0) && (wrcmd_full == 0);
assign dtu_ack = (state == IDLE);
assign dtu_done = (state == IDLE) && wempty && rempty;

assign ram_write_dataw[127:0] = rdata[255:128];
assign mem_data[127:0] = ram_read_dataw[255:128];
assign ram_write_dataw[255:128] = rdata[127:0];
assign mem_data[255:128] = ram_read_dataw[127:0];
assign ram_write_data = ram_write_dataw[255:0];
assign ram_read_dataw[255:0] = ram_read_data;
assign ram_write_addr = rfifo_addr;
assign ram_read_addr = ram_addr[RAMLAT-1];
assign ram_write_byte_en = ~0;
assign ram_write_en = ram_write_en_reg;
assign rdata_req = !rdata_empty;

// FSM to produce off-chip memory commands
always @ (posedge clk)
begin
	if (reset_n == 0)
	begin
		state <= IDLE;
	end
	else
	begin
		case (state)
		IDLE:
		begin
			if (dtu_write_req)
				state <= WRITE;
			else if (dtu_read_req)
				state <= READ;
			else
				state <= IDLE;
		end
		WRITE:
		begin
			if (not_stall && size == 0 && data_count < BURSTLEN)
				state <= IDLE;
			else
				state <= WRITE;
		end
		READ:
		begin
			if (not_stall && size == 0 && data_count < BURSTLEN)
				state <= IDLE;
			else
				state <= READ;
		end
		default:
		begin
			state <= IDLE;
		end
		endcase
	end
end

always @ (posedge clk)
begin

	if (reset_n == 0)
	begin
		size <= 0;
		data_count <= 0;
		size_count[RAMLAT-1] <= 1;
		mem_addr[RAMLAT] <= 0;
		ram_addr[RAMLAT-1] <= 0;
		fifo_write_reg[RAMLAT-1] <= 0;
		write_req_reg[RAMLAT-1] <= 0;
		fifo_read_reg[0] <= 0;
		read_req_reg[RAMLAT-1] <= 0;
	end
	else if (state == IDLE)
	begin
		size <= dtu_size;
		size_count[RAMLAT-1] <= BURSTLEN;
		mem_addr[RAMLAT] <= dtu_mem_addr;
		ram_addr[RAMLAT-1] <= dtu_ram_addr;
		fifo_write_reg[RAMLAT-1] <= 0;
		write_req_reg[RAMLAT-1] <= 0;
		fifo_read_reg[0] <= 0;
		read_req_reg[RAMLAT-1] <= 0;
		data_count <= 0;
	end
	else if (data_count >= BURSTLEN && not_stall)
	begin
		data_count <= data_count - BURSTLEN;
		mem_addr[RAMLAT] <= mem_addr[RAMLAT] + BURSTLEN;
		fifo_write_reg[RAMLAT-1] <= 0;
		write_req_reg[RAMLAT-1] <= state == WRITE;
		fifo_read_reg[0] <= 0;
		read_req_reg[RAMLAT-1] <= state == READ;
	end
	else if (size == 0 && data_count == 0 && not_stall)
	begin
		fifo_write_reg[RAMLAT-1] <= 0;
		write_req_reg[RAMLAT-1] <= 0;
		fifo_read_reg[0] <= 0;
		read_req_reg[RAMLAT-1] <= 0;
	end
	else if (size == 0 && not_stall)
	begin
		size_count[RAMLAT-1] <= data_count[BURSTWIDTH-1:0];
		fifo_write_reg[RAMLAT-1] <= 0;
		write_req_reg[RAMLAT-1] <= state == WRITE;
		fifo_read_reg[0] <= 0;
		read_req_reg[RAMLAT-1] <= state == READ;
	end
	else if (not_stall)
	begin
		size <= size - 1;
		data_count <= data_count + RATIO - BURSTLEN;
		mem_addr[RAMLAT] <= mem_addr[RAMLAT] + BURSTLEN;
		ram_addr[RAMLAT-1] <= ram_addr[RAMLAT-1]+1;
		fifo_write_reg[RAMLAT-1] <= state == WRITE;
		write_req_reg[RAMLAT-1] <= state == WRITE;
		fifo_read_reg[0] <= state == READ;
		read_req_reg[RAMLAT-1] <= state == READ;
	end
	else
	begin
		fifo_write_reg[RAMLAT-1] <= 0;
	end
end


always @ (posedge clk)
begin
	if (reset_n == 0)
	begin
		fifo_write_reg[0] <= 0;
		fifo_write_reg[1] <= 0;
		fifo_write_reg[2] <= 0;
		fifo_write_reg[3] <= 0;
	end
	else
	begin
		fifo_write_reg[0] <= fifo_write_reg[1];
		fifo_write_reg[1] <= fifo_write_reg[2];
		fifo_write_reg[2] <= fifo_write_reg[3];
		fifo_write_reg[3] <= fifo_write_reg[4];
	end

	if (reset_n == 0)
	begin
		mem_addr[0] <= 0;
		ram_addr[0] <= 0;
		size_count[0] <= 1;
		write_req_reg[0] <= 0;
		read_req_reg[0] <= 0;
		mem_addr[1] <= 0;
		ram_addr[1] <= 0;
		size_count[1] <= 1;
		write_req_reg[1] <= 0;
		read_req_reg[1] <= 0;
		mem_addr[2] <= 0;
		ram_addr[2] <= 0;
		size_count[2] <= 1;
		write_req_reg[2] <= 0;
		read_req_reg[2] <= 0;
		mem_addr[3] <= 0;
		ram_addr[3] <= 0;
		size_count[3] <= 1;
		write_req_reg[3] <= 0;
		read_req_reg[3] <= 0;
		mem_addr[4] <= 0;
	end
	else if (not_stall)
	begin
		size_count[0] <= size_count[1];
		mem_addr[0] <= mem_addr[1];
		ram_addr[0] <= ram_addr[1];
		write_req_reg[0] <= write_req_reg[1];
		read_req_reg[0] <= read_req_reg[1];
		size_count[1] <= size_count[2];
		mem_addr[1] <= mem_addr[2];
		ram_addr[1] <= ram_addr[2];
		write_req_reg[1] <= write_req_reg[2];
		read_req_reg[1] <= read_req_reg[2];
		size_count[2] <= size_count[3];
		mem_addr[2] <= mem_addr[3];
		ram_addr[2] <= ram_addr[3];
		write_req_reg[2] <= write_req_reg[3];
		read_req_reg[2] <= read_req_reg[3];
		size_count[3] <= size_count[4];
		mem_addr[3] <= mem_addr[4];
		ram_addr[3] <= ram_addr[4];
		write_req_reg[3] <= write_req_reg[4];
		read_req_reg[3] <= read_req_reg[4];
		mem_addr[4] <= mem_addr[5];
	end
	
	ram_write_en_reg  <= rdata_req;
end

endmodule
