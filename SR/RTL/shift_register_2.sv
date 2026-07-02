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


module shift_register_2(Q, Clock, Clear, D, S, MSBIn, LSBIn);

output [DATA_WIDTH-1:0] Q;
input Clock;
input Clear;
input [DATA_WIDTH-1:0] D;
input [2:0] S;
input MSBIn;
input LSBIn;

logic [DATA_WIDTH-1:0] SR;		// shift register

assign Q = SR;
  
always @(posedge Clock, negedge Clear)
	begin
	if (~Clear)
		SR <= '0;
	else
		case (S)
		NOP:	SR <= SR;
		LOAD:	SR <= D;
		LSR:	SR <= {MSBIn,				SR[DATA_WIDTH-1:1]};
		LSL:	SR <= {SR[DATA_WIDTH-2:0],  LSBIn};
		ROTR:	SR <= {SR[0],				SR[DATA_WIDTH-1:1]};
		ROTL:	SR <= {SR[DATA_WIDTH-2:0],	SR[DATA_WIDTH-1]};
		ASR:	SR <= {SR[DATA_WIDTH-1],	SR[DATA_WIDTH-1:1]};
		ASL:	SR <= {SR[DATA_WIDTH-2:0],	1'b0};
		endcase
	end
endmodule 