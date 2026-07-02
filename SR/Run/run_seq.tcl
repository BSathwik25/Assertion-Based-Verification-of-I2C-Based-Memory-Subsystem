set_fml_appmode SEQ

analyze -format sverilog -library spec ../RTL/shift_register_2.sv
analyze -format sverilog -library impl ../RTL/shift_register.sv
elaborate_seq -spectop shift_register_2 -impltop shift_register

map_by_name -input

create_clock spec.Clock -period 100 
create_reset spec.Clear -sense low

sim_run -stable
sim_save_reset

fvassert -expr {@(posedge impl.Clock) disable iff(!impl.Clear) spec.Q == impl.Q}

