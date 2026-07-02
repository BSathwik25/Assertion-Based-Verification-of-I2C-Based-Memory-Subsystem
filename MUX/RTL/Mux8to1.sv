module Mux8to1(Y, V, S);
output logic Y;
input logic [7:0] V;
input logic [2:0] S;

    assign Y = V[S];      

endmodule