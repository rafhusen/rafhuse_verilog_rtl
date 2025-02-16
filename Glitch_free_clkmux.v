/////////////////////////////////////////////////////////////
//Verilog code for Glitch free clock mux.
//basic idea is when select input switch the clock it may be encorporate the glitch in output clock due to asynchronous switching.
//so select input should be synchronous with respect to the clock intended to select and inverted to next select to indication of select next clock if the previous one is stopped.
/////////////////////////////////////////////////////////////
module clock_mux #(
parameter DEPTH = 2
)
(
input clk1,
input clk2,
input rst,
input sel,
output clk_out
);

reg [DEPTH-1:0]sync_sel_0;
reg [DEPTH-1:0]sync_sel_1;

wire sync_sel_0_out;
wire sync_sel_1_out;

wire sel_0; //for clk1
wire sel_1; //for clk2

// double flop synchronizer
always @(posedge clk1 or negedge rst )begin : synchronizer_for_sel0  
if(!rst)sync_sel_0 <= 'b0;
else sync_sel_0 <= {sync_sel_0[0],sel_0};
end

assign sync_sel_0_out = sync_sel_0[DEPTH-1];

// double flop synchronizer
always @(posedge clk1 or negedge rst )begin : synchronizer_for_sel1  
if(!rst)sync_sel_1 <= 'b0;
else sync_sel_1 <= {sync_sel_1[0],sel_1};
end

assign sync_sel_1_out = sync_sel_1[DEPTH-1];

assign sel_0 = (~sel)&~sync_sel_1_out; // to select clk1
assign sel_1 =  (sel)&~sync_sel_0_out; // to select clk2

  
// and with inverted clock because sync output is with respect to posedge and it force the clk to be zero at posedge and cause glitch at output so if we and with inverted clock will make smooth zero.
  assign clk_out = (sync_sel_0_out&~clk1) | (sync_sel_1_out&~clk2) ; 
  
endmodule
