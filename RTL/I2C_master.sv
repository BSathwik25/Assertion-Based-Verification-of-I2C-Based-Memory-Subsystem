module I2C_master (
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [ADDR_WIDTH-1:0] addr_in,
    input  logic                  clk,
    input  logic                  enable,
    input  logic                  ACK,
    input  logic                  reset,
    input  logic                  wr_rdn_en_in,
    output logic                  SDA,
    output logic                  SCL_drv
);

    //-------------------------------
    // Internal regs
    //-------------------------------
    logic [DATA_WIDTH-1:0] data;
    logic [ADDR_WIDTH-1:0] addr;
    logic wr_rdn_en;

    bit SCL_enable;

    State present_state, next_state;

    logic [3:0] count;
    logic [3:0] count1;
    logic [3:0] burst_cnt;
    logic [3:0] burst_cnt_next;  // next value for burst counter

    // Parameters
    localparam int BURST_LEN = 8;
    localparam bit REP_START_EN = 1'b1;

    // -----------------------------
    // SCL Output
    // -----------------------------
    assign SCL_drv = (SCL_enable == 0) ? 1 : ~clk;

    always_ff @(negedge clk) begin
        if (reset)
            SCL_enable <= 1'b0;
        else if ((present_state == IDLE) ||
                 (present_state == DATA_ACK && ACK == 0) ||
                 (present_state == ADDR_ACK && ACK == 0 && wr_rdn_en == 1) ||
                 (present_state == STOP))
            SCL_enable <= 1'b0;
        else
            SCL_enable <= 1'b1;
    end

    // -----------------------------
    // State Register + Counters
    // -----------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            present_state <= IDLE;
            burst_cnt     <= 0;
        end else begin
            present_state <= next_state;
            burst_cnt     <= burst_cnt_next;  

            case (present_state)
                START: begin
                    count <= 4'd7;
                end

                ADDR_PHASE: count  <= count - 1;
                ADDR_ACK:   count1 <= 4'd7;
                DATA_PHASE: count1 <= count1 - 1;
            endcase
        end
    end

    // -----------------------------
    // Next State + Output Logic
    // -----------------------------
    always_comb begin
        SDA = 1'b1;
        next_state = present_state;
        burst_cnt_next = burst_cnt;  //Default to current value

        case (present_state)

            IDLE: begin
                if (enable) begin
                    addr       = addr_in;
                    data       = data_in;
                    wr_rdn_en  = wr_rdn_en_in;
                    next_state = START;
                end
            end

            START: begin
                SDA        = 1'b0;
                next_state = ADDR_PHASE;
                burst_cnt_next = 4'd0;  //  Reset burst counter
            end

            ADDR_PHASE: begin
                SDA = addr[count];
                if (count == 0)
                    next_state = READ_WRITE_PHASE;
            end

            READ_WRITE_PHASE: begin
                SDA = wr_rdn_en ? 1'b1 : 1'b0;
                next_state = ADDR_ACK;
            end

            ADDR_ACK: begin
                if (wr_rdn_en == 0) begin
                    if (ACK == 0)
                        next_state = DATA_PHASE;
                end else begin
                    SDA = 0;
                    if (ACK == 0)
                        next_state = STOP;
                end
            end

            DATA_PHASE: begin
                SDA = data[count1];
                if (count1 == 0)
                    next_state = DATA_ACK;
            end

            DATA_ACK: begin
                SDA = 0;
                if (ACK == 0) begin
                    if (burst_cnt < BURST_LEN-1) begin
                        burst_cnt_next = burst_cnt + 1;  // Use next signal
                        next_state = DATA_PHASE;
                    end else if (REP_START_EN && wr_rdn_en == 1) begin
                        next_state = START;
                    end else begin
                        next_state = STOP;
                    end
                end
            end

            STOP: begin
                SDA        = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

endmodule
