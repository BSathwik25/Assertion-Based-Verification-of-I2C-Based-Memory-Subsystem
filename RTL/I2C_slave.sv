module I2C_slave (
    output logic [DATA_WIDTH-1:0] data_out,
    output bit                    done,
    output logic                  ACK,
    input  logic                  SDA,
    input  logic                  SCL,
    input  bit                    clk,
    input  bit                    reset_n,
    output logic                  scl_stretch_n
);

    // -------------------------------
    // Memory config
    // -------------------------------
    localparam int MEM_TOTAL_DEPTH = (1 << ADDR_WIDTH); // 256
    localparam int MEM_LEGAL_DEPTH = 128;               // 0–127 legal

    // -------------------------------
    // Internal signals
    // -------------------------------
    logic [ADDR_WIDTH-1:0] m_addr;
    logic [DATA_WIDTH-1:0] m_data;

    logic m_rd_wrn;

    bit  [3:0] addr_count;
    bit  [2:0] data_count;

    logic [DATA_WIDTH-1:0] mem [MEM_TOTAL_DEPTH-1:0];

    state_t present_state, next_state;

    logic start, stop;

    logic illegal_addr;
    logic stretch_en;

    assign illegal_addr  = (m_addr >= MEM_LEGAL_DEPTH);
    assign scl_stretch_n = ~stretch_en;

    // -------------------------------
    // START/STOP Detection
    // -------------------------------
    always @(negedge SDA)
        if (present_state == S_IDLE) begin
            start <= SCL;
            stop  <= 0;
        end

    always @(posedge SDA)
        if ((present_state == SEND_WRITE_ACK) ||
           ((m_rd_wrn == 1) && (present_state == SEND_ADDR_ACK))) begin
            stop  <= SCL;
            start <= 0;
        end

    // -------------------------------
    // Sequential Block
    // -------------------------------
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            present_state <= S_IDLE;
            mem           <= '{default:0};
            stretch_en    <= 0;
        end else begin
            present_state <= next_state;

            case (present_state)
                S_IDLE: begin
                    addr_count <= 0;
                    data_count <= 0;
                    m_addr <= 'x;
                    m_data <= 'x;
                end

                COLLECT_ADDR: begin
                    if (addr_count < ADDR_WIDTH) begin
                        addr_count <= addr_count + 1;
                        m_addr     <= {m_addr[6:0], SDA};
                    end
                end

                COLLECT_RW: begin
                    m_rd_wrn <= SDA;
                end

                COLLECT_DATA: begin
                    if (data_count < DATA_WIDTH) begin
                        data_count <= data_count + 1;
                        m_data     <= {m_data[6:0], SDA};
                    end
                end

                SEND_WRITE_ACK: begin
                    if (!illegal_addr)
                        mem[m_addr] <= m_data;
                end
            endcase
        end

        // Clock stretch pattern
        unique case (present_state)
            COLLECT_DATA,
            READ_FROM_MEM: stretch_en <= (data_count == 3 || data_count == 5);
            default:       stretch_en <= 0;
        endcase
    end

    // -------------------------------
    // Next State Logic
    // -------------------------------
    always_comb begin
        next_state = present_state;

        case (present_state)

            S_IDLE: begin
                if (start)
                    next_state = COLLECT_ADDR;
            end

            COLLECT_ADDR: begin
                if (addr_count == ADDR_WIDTH-1)
                    next_state = COLLECT_RW;
            end

            COLLECT_RW:
                next_state = SEND_ADDR_ACK;

            SEND_ADDR_ACK: begin
                if (illegal_addr) begin
                    if (stop)
                        next_state = S_IDLE;
                end else if (m_rd_wrn == 1) begin
                    if (stop)
                        next_state = S_IDLE;
                end else begin
                    next_state = COLLECT_DATA;
                end
            end

            COLLECT_DATA: begin
                if (data_count == DATA_WIDTH-1)
                    next_state = SEND_WRITE_ACK;
            end

            SEND_WRITE_ACK: begin
                if (stop)
                    next_state = S_IDLE;
            end
        endcase
    end

    // -------------------------------
    // Output Logic
    // -------------------------------
    always_comb begin
        data_out = 'z;
        done     = 0;
        ACK      = 'z;

        case (present_state)
            SEND_ADDR_ACK: begin
                if (!illegal_addr) begin
                    ACK = 1'b0;
                    if (m_rd_wrn) begin
                        data_out = mem[m_addr];
                        done     = 1'b1;
                    end
                end
            end

            SEND_WRITE_ACK:
                if (!illegal_addr)
                    ACK = 1'b0;
        endcase
    end

endmodule
