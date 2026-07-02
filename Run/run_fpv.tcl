set_fml_appmode FPV
set design top_I2C
read_file -top top_I2C -format sverilog -sva -vcs {-f ../Run/filelist}

create_clock clk -period 100
create_reset reset_n -sense low

sim_run -stable
sim_save_reset

# ---------------------------
# Basic  assumptions
# ---------------------------
fvassume -expr {reset_n !== 1'bx}
fvassume -expr {Master_enable !== 1'bx}
fvassume -expr {rd_wr_en !== 1'bx}
fvassume -expr {addr_in !== 8'hxx}
fvassume -expr {D_in !== 8'hxx}
fvassume -expr {S_in !== 3'bxxx}

fvassume -expr {addr_in inside {[0:255]}}
fvassume -expr {D_in inside {[0:255]}}
fvassume -expr {S_in inside {[3'b000:3'b111]}}

# Master enable stable
fvassume -expr {Master_enable == 1'b0 || Master_enable == 1'b1}

# ---------------------------
# Prevent multiple writes before read
# ---------------------------
fvassume -expr {@(posedge clk) disable iff (!reset_n)
    !( (present_state == SEND_WRITE_ACK && stop == 1 && !illegal_addr)
       ##[1:$]
       (present_state == SEND_WRITE_ACK && stop == 1 && !illegal_addr)
    )};

# ---------------------------
#  Prevent read of unrelated address
# ---------------------------
fvassume -expr {@(posedge clk) disable iff (!reset_n)
    (present_state == SEND_ADDR_ACK && m_rd_wrn == 1 && !illegal_addr)
        |-> (m_addr == $past(m_addr,1));
};

# ---------------------------
# PROVE 
# ---------------------------
#prove -all

#report_properties -assertions -all
#report_properties -cover -all
#report_failures -all

