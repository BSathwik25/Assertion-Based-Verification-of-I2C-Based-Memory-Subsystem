//import i2c_package::*;

parameter NOP        = 3'b000;	
parameter LOAD       = 3'b001;	
parameter LSR        = 3'b010;	
parameter LSL        = 3'b011;	
parameter ROTR       = 3'b100;	
parameter ROTL       = 3'b101;	
parameter ASR        = 3'b110;	
parameter ASL	     = 3'b111;
parameter N          = 8;
parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 8;
parameter NRANDOM    = 100000;

//slave states
typedef enum logic [3:0] {
	IDLE, 
	COLLECT_ADDR,
	COLLECT_RW, 
	SEND_ADDR_ACK,
	READ_FROM_MEM,
	COLLECT_DATA,
	SEND_READ_ACK,
	SEND_WRITE_ACK
} state_t;


module DFF(Q, Clock, Clear, D);
output logic Q;
input logic Clock;
input logic Clear;
input logic D;

always_ff @(posedge Clock, negedge Clear) 
begin
    if (!Clear) Q <= 0;
    else Q <= D;   
end
endmodule

module Mux8to1(Y, V, S);
output logic Y;
input logic [N-1:0] V;
input logic [$clog2(N)-1:0] S;

    assign Y = V[S];      

endmodule

module shift_register(Q, Clock, Clear, D, S, MSBIn, LSBIn);



output logic [N-1:0] Q;
input logic Clock;
input logic Clear;

input logic [N-1:0] D;
input logic [2:0] S;
input logic MSBIn;
input logic LSBIn;

wire [N-1:0] Y;

//Instantiation of sub modules start here
//Mux generation
Mux8to1 Instance0 (Y[0], {1'b0, Q[1], Q[N-1], Q[1], LSBIn, Q[1], D[0], Q[0]}, S);
genvar i;
generate
    for (i=1; i < N-1; i = i+1)
    begin:MuxInstance
        Mux8to1 m (Y[i], {Q[i-1], Q[i+1], Q[i-1], Q[i+1], Q[i-1], Q[i+1], D[i], Q[i]}, S);
    end
endgenerate
Mux8to1 InstanceN (Y[N-1], {Q[N-2], Q[N-1], Q[N-2], Q[0], Q[N-2], MSBIn, D[N-1], Q[N-1]}, S);

//DFF generation
genvar k;
generate
    for (k=0; k < N; k = k+1)
    begin:DFFInstance
        DFF m (Q[k], Clock, Clear, Y[k]);
    end
endgenerate

endmodule