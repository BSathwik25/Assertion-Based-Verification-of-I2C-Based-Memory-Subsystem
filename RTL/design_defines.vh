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

//master states
typedef enum logic [3:0] {
	IDLE,
	START,
	ADDR_PHASE,
	READ_WRITE_PHASE,
	ADDR_ACK,
	DATA_PHASE,
	DATA_ACK,
	STOP
 } State;
 
 //slave states
typedef enum logic [3:0] {
	S_IDLE, 
	COLLECT_ADDR,
	COLLECT_RW, 
	SEND_ADDR_ACK,
	READ_FROM_MEM,
	COLLECT_DATA,
	SEND_READ_ACK,
	SEND_WRITE_ACK
} state_t;