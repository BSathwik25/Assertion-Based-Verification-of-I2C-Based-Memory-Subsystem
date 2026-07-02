    module I2C_end2end_sva (
    input logic                  clk,
    input logic                  reset_n,
    // Internal slave signals
    input state_t                present_state,
    input logic [ADDR_WIDTH-1:0] m_addr,
    input logic [DATA_WIDTH-1:0] m_data,
    input logic                  m_rd_wrn,
    input logic                  illegal_addr,
    input logic [DATA_WIDTH-1:0] data_out,
    input bit                    done,
    input logic                  stop
);
    // Define as boolean conditions
    logic write_ok;
    logic read_ok;
    
    always_comb begin
        write_ok = (present_state == SEND_WRITE_ACK) && !illegal_addr && stop;
        read_ok  = (present_state == SEND_ADDR_ACK) && m_rd_wrn && !illegal_addr && done;
    end
    
    property p_write_then_read_same_data;
    logic [ADDR_WIDTH-1:0] saved_addr;
    logic [DATA_WIDTH-1:0] saved_data;
    @(posedge clk) disable iff (!reset_n)
        // capture address/data on a legal write
        (write_ok, saved_addr = m_addr, saved_data = m_data)
        // later, see a legal read from the same address with same data
        ##[1:1000] (read_ok && (m_addr == saved_addr) && (data_out == saved_data));
endproperty

cover property (p_write_then_read_same_data);


cover property (@(posedge clk) disable iff (!reset_n)
    write_ok ##[1:1000] read_ok
);

    
endmodule
