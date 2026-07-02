//import i2c_package::*;
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
