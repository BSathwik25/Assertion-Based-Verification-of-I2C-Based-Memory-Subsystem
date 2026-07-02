set_fml_appmode SEQ

analyze -format sverilog -library spec ../RTL/DFF_2.sv
analyze -format sverilog -library impl ../RTL/DFF.sv
elaborate_seq -spectop DFF_2 -impltop DFF

map_by_name -input

create_clock spec.Clock -period 100 
create_reset spec.Clear -sense low

sim_run -stable
sim_save_reset

fvassert -expr {@(posedge impl.Clock) disable iff(!impl.Clear) spec.Q == impl.Q}