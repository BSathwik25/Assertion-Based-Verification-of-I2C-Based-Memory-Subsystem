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