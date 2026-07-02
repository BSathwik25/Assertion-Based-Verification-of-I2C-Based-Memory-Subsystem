set_fml_appmode SEQ

analyze -format sverilog -library spec ../RTL/Mux8to1_2.sv
analyze -format sverilog -library impl ../RTL/Mux8to1.sv
elaborate_seq -spectop Mux8to1_2 -impltop Mux8to1

map_by_name -input 

fvassert -expr {spec.Y == impl.Y}