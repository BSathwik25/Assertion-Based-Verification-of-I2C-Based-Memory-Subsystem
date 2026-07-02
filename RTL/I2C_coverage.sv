module I2C_master_cov (
    input logic      clk,
    input logic      reset,          // active high
    input logic      wr_rdn_en_in,
    input logic [3:0] burst_cnt,
    input State      present_state
);

    // Detect repeated start: START immediately after DATA_ACK
    State prev_state;
    logic       rep_start_event;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_state      <= IDLE;
            rep_start_event <= 1'b0;
        end else begin
            prev_state      <= present_state;
            rep_start_event <= (prev_state == DATA_ACK && present_state == START);
        end
    end

    // Coverage group
    covergroup cg_master @(posedge clk);
        // read/write intent
        cp_rw: coverpoint wr_rdn_en_in {
            bins write = {1'b0};
            bins read  = {1'b1};
        }

        // burst count (0-7 for 8-byte burst)
        cp_burst_cnt: coverpoint burst_cnt {
            bins single = {0}; // effectively one byte
            bins mid    = {3};
            bins full   = {7}; // 8th byte
        }

        // repeated start
        cp_rep_start: coverpoint rep_start_event {
            bins rep_used = {1};
        }

        // Cross burst vs rw vs rep-start
        cross cp_rw, cp_burst_cnt, cp_rep_start;
    endgroup

    cg_master u_cg_master = new();

endmodule

bind I2C_master I2C_master_cov u_i2c_master_cov (
    .clk          (clk),
    .reset        (reset),
    .wr_rdn_en_in (wr_rdn_en_in),
    .burst_cnt    (burst_cnt),
    .present_state(present_state)
);



module I2C_slave_cov (
    input logic clk,
    input logic reset_n,
    input logic illegal_addr,
    input logic stretch_en,
    input state_t present_state
);

    covergroup cg_slave @(posedge clk);
        // Legal vs illegal access
        cp_illegal: coverpoint illegal_addr {
            bins legal   = {1'b0};
            bins illegal = {1'b1};
        }

        // Clock stretching active or not
        cp_stretch: coverpoint stretch_en {
            bins no_stretch = {1'b0};
            bins stretch    = {1'b1};
        }

        // State where stretch occurs (for debug)
        cp_state: coverpoint present_state;

        // Cross: illegal vs stretch
        cross cp_illegal, cp_stretch;
    endgroup

    cg_slave u_cg_slave = new();

endmodule

bind I2C_slave I2C_slave_cov u_i2c_slave_cov (
    .clk         (clk),
    .reset_n     (reset_n),
    .illegal_addr(illegal_addr),
    .stretch_en  (stretch_en),
    .present_state(present_state)
);
