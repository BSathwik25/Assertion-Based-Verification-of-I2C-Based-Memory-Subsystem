module DFF_2(Q, Clock, Clear, D);

output logic Q;
input logic Clock;
input logic Clear;
input logic D;
  
always @(posedge Clock, negedge Clear)
begin
	if (!Clear) 
		Q <= 0;
    else 
		case (D)
			1'b0:	Q <= 1'b0;
			1'b1:	Q <= 1'b1;
		endcase
end

endmodule 