set_fml_appmode FPV 
set design DFF_top

read_file -top DFF_top -format sverilog -sva -vcs {-f ../RTL/filelist}

create_clock Clock -period 100
create_reset Clear -sense low

sim_run -stable
sim_save_reset


fvassert -expr {@(posedge Clock) disable iff(!Clear) D |=> Q}
fvassert -expr {@(posedge Clock) disable iff(!Clear) !D |=> !Q}