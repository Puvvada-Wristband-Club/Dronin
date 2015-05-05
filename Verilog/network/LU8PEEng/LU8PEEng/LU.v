//auto-generated LU.v
//datapath for computating LU factorization
//by Wei Zhang

module LU (clk, start, m, n, loop, mode, done, 
			curReadAddrMem, curReadDataMem, curWriteByteEnMem, curWriteDataMem, curWriteAddrMem, curWriteEnMem, curMemSel,
			leftWriteByteEnMem, leftWriteDataMem, leftWriteAddrMem, leftWriteEnMem, leftMemSel);


parameter PRECISION = 32, NUMPE = 8, PEWIDTH = 3, BLOCKWIDTH = 6;
parameter RAMWIDTH = 256, RAMNUMBYTES = 32, RAMSIZEWIDTH = 7, TOPSIZEWIDTH = 10;
parameter TOPINPUTDELAY = 3, TOPOUTPUTDELAY = 1;
parameter MEMINPUTDELAY = 2, MEMOUTPUTDELAY = 1;

input clk, start;
input[BLOCKWIDTH-1:0] m, n, loop;
input[1:0] mode;
output done;
wire[RAMWIDTH-1:0] curWriteData0, curWriteData1;
wire[RAMSIZEWIDTH-1:0] curWriteAddr0, curReadAddr0, curWriteAddr1, curReadAddr1;
wire[RAMWIDTH-1:0] curReadData0, curReadData1;
wire[RAMNUMBYTES-1:0] curWriteByteEn0, curWriteByteEn1;
wire curWriteEn0, curWriteEn1;

input[RAMWIDTH-1:0] curWriteDataMem;
output[RAMWIDTH-1:0] curReadDataMem;
input[RAMSIZEWIDTH-1:0] curWriteAddrMem, curReadAddrMem;
input[RAMNUMBYTES-1:0] curWriteByteEnMem;
input curWriteEnMem;
input[RAMWIDTH-1:0] leftWriteDataMem;
input[RAMSIZEWIDTH-1:0] leftWriteAddrMem;
input[RAMNUMBYTES-1:0] leftWriteByteEnMem;
input leftWriteEnMem;
input leftMemSel, curMemSel;

wire[RAMWIDTH-1:0] curReadDataLU, curReadDataMem;
wire[RAMWIDTH-1:0] curWriteDataLU, curWriteDataMem;
wire[RAMSIZEWIDTH-1:0] curWriteAddrLU, curWriteAddrMem, curReadAddrLU, curReadAddrMem;
wire[RAMNUMBYTES-1:0] curWriteByteEnLU, curWriteByteEnMem;
wire curWriteEnLU, curWriteEnMem;

reg[RAMWIDTH-1:0] curReadData0Reg[MEMOUTPUTDELAY-1:0], curReadData1Reg[MEMOUTPUTDELAY-1:0];
reg[RAMWIDTH-1:0] leftReadData0Reg[MEMOUTPUTDELAY-1:0], leftReadData1Reg[MEMOUTPUTDELAY-1:0];
reg[RAMWIDTH-1:0] curWriteData0Reg[MEMINPUTDELAY-1:0], curWriteData1Reg[MEMINPUTDELAY-1:0];
reg[RAMSIZEWIDTH-1:0] curWriteAddr0Reg[MEMINPUTDELAY-1:0], curReadAddr0Reg[MEMINPUTDELAY-1:0];
reg[RAMSIZEWIDTH-1:0] curWriteAddr1Reg[MEMINPUTDELAY-1:0], curReadAddr1Reg[MEMINPUTDELAY-1:0];
reg[RAMNUMBYTES-1:0] curWriteByteEn0Reg[MEMINPUTDELAY-1:0], curWriteByteEn1Reg[MEMINPUTDELAY-1:0];
reg curWriteEn0Reg[MEMINPUTDELAY-1:0], curWriteEn1Reg[MEMINPUTDELAY-1:0];
reg[RAMWIDTH-1:0] leftWriteData0Reg[MEMINPUTDELAY-1:0], leftWriteData1Reg[MEMINPUTDELAY-1:0];
reg[RAMSIZEWIDTH-1:0] leftWriteAddr0Reg[MEMINPUTDELAY-1:0], leftReadAddr0Reg[MEMINPUTDELAY-1:0];
reg[RAMSIZEWIDTH-1:0] leftWriteAddr1Reg[MEMINPUTDELAY-1:0], leftReadAddr1Reg[MEMINPUTDELAY-1:0];
reg[RAMNUMBYTES-1:0] leftWriteByteEn0Reg[MEMINPUTDELAY-1:0], leftWriteByteEn1Reg[MEMINPUTDELAY-1:0];
reg leftWriteEn0Reg[MEMINPUTDELAY-1:0], leftWriteEn1Reg[MEMINPUTDELAY-1:0];

reg[PRECISION-1:0] multOperand;
reg[PRECISION-1:0] diag;
wire[PRECISION-1:0] recResult;
wire[PRECISION-1:0] multA[NUMPE-1:0], multResult[NUMPE-1:0];
wire[PRECISION-1:0] addA[NUMPE-1:0], addResult[NUMPE-1:0];

wire[RAMWIDTH-1:0] leftReadData0, leftReadData1, leftWriteData0, leftWriteData1;
wire[RAMSIZEWIDTH-1:0] leftWriteAddr0, leftWriteAddr1, leftReadAddr0, leftReadAddr1;
wire[RAMNUMBYTES-1:0] leftWriteByteEn0, leftWriteByteEn1;
wire leftWriteEn0, leftWriteEn1;
wire[RAMWIDTH-1:0] leftReadDataLU, leftWriteDataLU, leftWriteDataMem;
wire[RAMSIZEWIDTH-1:0] leftWriteAddrLU, leftWriteAddrMem, leftReadAddrLU;
wire[RAMNUMBYTES-1:0] leftWriteByteEnLU, leftWriteByteEnMem;
wire leftWriteEnLU, leftWriteEnMem;

wire[PRECISION-1:0] topWriteData;
reg[PRECISION-1:0] topWriteDataLU;
wire[PRECISION-1:0] topReadData, topReadDataLU;
wire[TOPSIZEWIDTH-1:0] topWriteAddr, topWriteAddrLU, topReadAddr, topReadAddrLU;
wire topWriteEn, topWriteEnLU;

reg[PRECISION-1:0] topReadDataReg[TOPOUTPUTDELAY-1:0];
reg[PRECISION-1:0] topWriteDataReg[TOPINPUTDELAY-1:0];
reg[TOPSIZEWIDTH-1:0] topWriteAddrReg[TOPINPUTDELAY-1:0], topReadAddrReg[TOPINPUTDELAY-1:0];
reg topWriteEnReg[TOPINPUTDELAY-1:0];

wire[RAMWIDTH-1:0] rcWriteData;
wire leftWriteSel, curWriteSel, topSourceSel;
wire diagEn;
wire[PEWIDTH-1:0] topWriteSel;

wire MOSel;
wire MOEn;

// control block
LUControl conBlock (clk, start, m, n, loop, mode, done, 
                    curReadAddrLU, curWriteAddrLU, curWriteByteEnLU, curWriteEnLU, curWriteSel,
                    leftReadAddrLU, leftWriteAddrLU, leftWriteByteEnLU, leftWriteEnLU,  leftWriteSel,
                    topReadAddrLU, topWriteAddrLU, topWriteEnLU, topWriteSel, topSourceSel, diagEn, MOSel, MOEn);

// fp_div unit
divsp rec (clk, 32'h3F800000, diag, recResult);

// on-chip memory blocks that store the matrix to be LU factorized
// store current blocks data
ram currentBlock0 (curWriteByteEn0, clk, curWriteData0, curReadAddr0, curWriteAddr0, curWriteEn0, curReadData0);
ram currentBlock1 (curWriteByteEn1, clk, curWriteData1, curReadAddr1, curWriteAddr1, curWriteEn1, curReadData1);
// store left blocks data
ram leftBlock0(leftWriteByteEn0, clk, leftWriteData0, leftReadAddr0, leftWriteAddr0, leftWriteEn0, leftReadData0);

ram leftBlock1(leftWriteByteEn1, clk, leftWriteData1, leftReadAddr1, leftWriteAddr1, leftWriteEn1, leftReadData1);

// store top block data
top_ram topBlock(clk, topWriteData, topReadAddr, topWriteAddr, topWriteEn, topReadDataLU);

// processing elements that does the main computation of LU factorization
mult_add PE0 (clk, multA[0], multOperand, addA[0], multResult[0], addResult[0]);
mult_add PE1 (clk, multA[1], multOperand, addA[1], multResult[1], addResult[1]);
mult_add PE2 (clk, multA[2], multOperand, addA[2], multResult[2], addResult[2]);
mult_add PE3 (clk, multA[3], multOperand, addA[3], multResult[3], addResult[3]);
mult_add PE4 (clk, multA[4], multOperand, addA[4], multResult[4], addResult[4]);
mult_add PE5 (clk, multA[5], multOperand, addA[5], multResult[5], addResult[5]);
mult_add PE6 (clk, multA[6], multOperand, addA[6], multResult[6], addResult[6]);
mult_add PE7 (clk, multA[7], multOperand, addA[7], multResult[7], addResult[7]);

// connect to ports of the left blocks
assign leftWriteDataLU = (leftWriteSel == 0) ? curReadDataLU : rcWriteData;
always @ (posedge clk)
begin
	if(leftMemSel == 0)
	begin
		leftWriteData0Reg[0] <= leftWriteDataMem;
		leftWriteAddr0Reg[0] <= leftWriteAddrMem;
		leftWriteByteEn0Reg[0] <= leftWriteByteEnMem;
		leftWriteEn0Reg[0] <= leftWriteEnMem;
		leftWriteData1Reg[0] <= leftWriteDataLU;
		leftWriteAddr1Reg[0] <= leftWriteAddrLU;
		leftWriteByteEn1Reg[0] <= leftWriteByteEnLU;
		leftWriteEn1Reg[0] <= leftWriteEnLU;
	end
	else
	begin
		leftWriteData0Reg[0] <= leftWriteDataLU;
		leftWriteAddr0Reg[0] <= leftWriteAddrLU;
		leftWriteByteEn0Reg[0] <= leftWriteByteEnLU;
		leftWriteEn0Reg[0] <= leftWriteEnLU;
		leftWriteData1Reg[0] <= leftWriteDataMem;
		leftWriteAddr1Reg[0] <= leftWriteAddrMem;
		leftWriteByteEn1Reg[0] <= leftWriteByteEnMem;
		leftWriteEn1Reg[0] <= leftWriteEnMem;
	end
	leftReadAddr0Reg[0] <= leftReadAddrLU;
	leftReadAddr1Reg[0] <= leftReadAddrLU;
	leftWriteData0Reg[1] <= leftWriteData0Reg[0];
	leftWriteAddr0Reg[1] <= leftWriteAddr0Reg[0];
	leftReadAddr0Reg[1] <= leftReadAddr0Reg[0];
	leftWriteByteEn0Reg[1] <= leftWriteByteEn0Reg[0];
	leftWriteEn0Reg[1] <= leftWriteEn0Reg[0];
	leftWriteData1Reg[1] <= leftWriteData1Reg[0];
	leftWriteAddr1Reg[1] <= leftWriteAddr1Reg[0];
	leftReadAddr1Reg[1] <= leftReadAddr1Reg[0];
	leftWriteByteEn1Reg[1] <= leftWriteByteEn1Reg[0];
	leftWriteEn1Reg[1] <= leftWriteEn1Reg[0];
end
assign leftWriteData0 = leftWriteData0Reg[1];
assign leftWriteAddr0 = leftWriteAddr0Reg[1];
assign leftReadAddr0 = leftReadAddr0Reg[1];
assign leftWriteByteEn0 = leftWriteByteEn0Reg[1];
assign leftWriteEn0 = leftWriteEn0Reg[1];
assign leftWriteData1 = leftWriteData1Reg[1];
assign leftWriteAddr1 = leftWriteAddr1Reg[1];
assign leftReadAddr1 = leftReadAddr1Reg[1];
assign leftWriteByteEn1 = leftWriteByteEn1Reg[1];
assign leftWriteEn1 = leftWriteEn1Reg[1];

always @ (posedge clk)
begin
		leftReadData0Reg[0] <= leftReadData0;
		leftReadData1Reg[0] <= leftReadData1;
end
assign leftReadDataLU = (leftMemSel == 0) ? leftReadData1Reg[0] : leftReadData0Reg[0];
// data feed to fp div unit
always @ (posedge clk)
begin
	if (diagEn == 1)
	begin
			diag <= topReadData;
	end
end
// one of the inputs to the PE
always @ (posedge clk)
begin
	if (start == 1)
		multOperand <= 0;
	else if (MOEn == 1)
	begin
		if (MOSel == 0)
			multOperand <= recResult;
		else
			multOperand <= topReadData;
	end
end

// connections to top block memory ports
always @ (*)
begin
	if (topSourceSel == 0)
		case (topWriteSel)
		0:
			topWriteDataLU = curReadDataLU[255:224];
		1:
			topWriteDataLU = curReadDataLU[223:192];
		2:
			topWriteDataLU = curReadDataLU[191:160];
		3:
			topWriteDataLU = curReadDataLU[159:128];
		4:
			topWriteDataLU = curReadDataLU[127:96];
		5:
			topWriteDataLU = curReadDataLU[95:64];
		6:
			topWriteDataLU = curReadDataLU[63:32];
		7:
			topWriteDataLU = curReadDataLU[31:0];
		default:
			topWriteDataLU = curReadDataLU[PRECISION-1:0];
		endcase
	else
		case (topWriteSel)
		0:
			topWriteDataLU = addResult[7];
		1:
			topWriteDataLU = addResult[6];
		2:
			topWriteDataLU = addResult[5];
		3:
			topWriteDataLU = addResult[4];
		4:
			topWriteDataLU = addResult[3];
		5:
			topWriteDataLU = addResult[2];
		6:
			topWriteDataLU = addResult[1];
		7:
			topWriteDataLU = addResult[0];
		default:
			topWriteDataLU = addResult[0];
		endcase
end

always @ (posedge clk)
begin
	topWriteDataReg[0] <= topWriteDataLU;
	topReadAddrReg[0] <= topReadAddrLU;
	topWriteAddrReg[0] <= topWriteAddrLU;
	topWriteEnReg[0] <= topWriteEnLU;
	topWriteDataReg[1] <= topWriteDataReg[0];
	topReadAddrReg[1] <= topReadAddrReg[0];
	topWriteAddrReg[1] <= topWriteAddrReg[0];
	topWriteEnReg[1] <= topWriteEnReg[0];
	topWriteDataReg[2] <= topWriteDataReg[1];
	topReadAddrReg[2] <= topReadAddrReg[1];
	topWriteAddrReg[2] <= topWriteAddrReg[1];
	topWriteEnReg[2] <= topWriteEnReg[1];
end
assign topWriteData = topWriteDataReg[2];
assign topReadAddr = topReadAddrReg[2];
assign topWriteAddr = topWriteAddrReg[2];
assign topWriteEn = topWriteEnReg[2];
always @ (posedge clk)
begin
	topReadDataReg[0] <= topReadDataLU;
end
assign topReadData = topReadDataReg[0];

// connections to processing element
assign multA[0] = leftReadDataLU[31:0];
assign multA[1] = leftReadDataLU[63:32];
assign multA[2] = leftReadDataLU[95:64];
assign multA[3] = leftReadDataLU[127:96];
assign multA[4] = leftReadDataLU[159:128];
assign multA[5] = leftReadDataLU[191:160];
assign multA[6] = leftReadDataLU[223:192];
assign multA[7] = leftReadDataLU[255:224];

assign addA[0] = curReadDataLU[31:0];
assign addA[1] = curReadDataLU[63:32];
assign addA[2] = curReadDataLU[95:64];
assign addA[3] = curReadDataLU[127:96];
assign addA[4] = curReadDataLU[159:128];
assign addA[5] = curReadDataLU[191:160];
assign addA[6] = curReadDataLU[223:192];
assign addA[7] = curReadDataLU[255:224];

// connections to ports of the current blocks
assign rcWriteData[31:0] = (curWriteSel == 0) ? multResult[0] : addResult[0];
assign rcWriteData[63:32] = (curWriteSel == 0) ? multResult[1] : addResult[1];
assign rcWriteData[95:64] = (curWriteSel == 0) ? multResult[2] : addResult[2];
assign rcWriteData[127:96] = (curWriteSel == 0) ? multResult[3] : addResult[3];
assign rcWriteData[159:128] = (curWriteSel == 0) ? multResult[4] : addResult[4];
assign rcWriteData[191:160] = (curWriteSel == 0) ? multResult[5] : addResult[5];
assign rcWriteData[223:192] = (curWriteSel == 0) ? multResult[6] : addResult[6];
assign rcWriteData[255:224] = (curWriteSel == 0) ? multResult[7] : addResult[7];
assign curWriteDataLU = rcWriteData;

always @ (posedge clk)
begin
	if(curMemSel == 0)
	begin
		curWriteData0Reg[0] <= curWriteDataMem;
		curWriteAddr0Reg[0] <= curWriteAddrMem;
		curReadAddr0Reg[0] <= curReadAddrMem;
		curWriteByteEn0Reg[0] <= curWriteByteEnMem;
		curWriteEn0Reg[0] <= curWriteEnMem;
		curWriteData1Reg[0] <= curWriteDataLU;
		curWriteAddr1Reg[0] <= curWriteAddrLU;
		curReadAddr1Reg[0] <= curReadAddrLU;
		curWriteByteEn1Reg[0] <= curWriteByteEnLU;
		curWriteEn1Reg[0] <= curWriteEnLU;
	end
	else
	begin
		curWriteData0Reg[0] <= curWriteDataLU;
		curWriteAddr0Reg[0] <= curWriteAddrLU;
		curReadAddr0Reg[0] <= curReadAddrLU;
		curWriteByteEn0Reg[0] <= curWriteByteEnLU;
		curWriteEn0Reg[0] <= curWriteEnLU;
		curWriteData1Reg[0] <= curWriteDataMem;
		curWriteAddr1Reg[0] <= curWriteAddrMem;
		curReadAddr1Reg[0] <= curReadAddrMem;
		curWriteByteEn1Reg[0] <= curWriteByteEnMem;
		curWriteEn1Reg[0] <= curWriteEnMem;
	end
	curWriteData0Reg[1] <= curWriteData0Reg[0];
	curWriteAddr0Reg[1] <= curWriteAddr0Reg[0];
	curReadAddr0Reg[1] <= curReadAddr0Reg[0];
	curWriteByteEn0Reg[1] <= curWriteByteEn0Reg[0];
	curWriteEn0Reg[1] <= curWriteEn0Reg[0];
	curWriteData1Reg[1] <= curWriteData1Reg[0];
	curWriteAddr1Reg[1] <= curWriteAddr1Reg[0];
	curReadAddr1Reg[1] <= curReadAddr1Reg[0];
	curWriteByteEn1Reg[1] <= curWriteByteEn1Reg[0];
	curWriteEn1Reg[1] <= curWriteEn1Reg[0];
end
assign curWriteData0 = curWriteData0Reg[1];
assign curWriteAddr0 = curWriteAddr0Reg[1];
assign curReadAddr0 = curReadAddr0Reg[1];
assign curWriteByteEn0 = curWriteByteEn0Reg[1];
assign curWriteEn0 = curWriteEn0Reg[1];
assign curWriteData1 = curWriteData1Reg[1];
assign curWriteAddr1 = curWriteAddr1Reg[1];
assign curReadAddr1 = curReadAddr1Reg[1];
assign curWriteByteEn1 = curWriteByteEn1Reg[1];
assign curWriteEn1 = curWriteEn1Reg[1];

always @ (posedge clk)
begin
		curReadData0Reg[0] <= curReadData0;
		curReadData1Reg[0] <= curReadData1;
end
assign curReadDataMem = (curMemSel == 0) ? curReadData0Reg[0] : curReadData1Reg[0];
assign curReadDataLU = (curMemSel == 0) ? curReadData1Reg[0] : curReadData0Reg[0];
endmodule
