module Mux8to1_2(Y, V, S);
output logic Y;
input logic [7:0] V;
input logic [2:0] S;

 always_comb 
 begin
  case(S)
  0 : Y = V[0];
  1 : Y = V[1];
  2 : Y = V[2];
  3 : Y = V[3];
  4 : Y = V[4];
  5 : Y = V[5];
  6 : Y = V[6];
  7 : Y = V[7];
  endcase    
end
endmodule