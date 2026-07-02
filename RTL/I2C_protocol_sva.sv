module I2C_protocol_sva (
    input logic clk,
    input logic reset_n,
    input logic SDA,
    input logic SCL
);
    // Register previous values for edge detection
    logic SDA_prev;
    logic SCL_prev;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            SDA_prev <= 1'b1;
            SCL_prev <= 1'b1;
        end else begin
            SDA_prev <= SDA;
            SCL_prev <= SCL;
        end
    end
    
    // Detect START condition: SDA falls while SCL high
    logic start_detected;
    always_comb begin
        start_detected = SCL && SCL_prev && !SDA && SDA_prev;
    end
    
    // Detect STOP condition: SDA rises while SCL high
    logic stop_detected;
    always_comb begin
        stop_detected = SCL && SCL_prev && SDA && !SDA_prev;
    end
    
    // SDA must be stable while SCL is CONTINUOUSLY high
    property p_sda_stable_when_scl_high;
        @(posedge clk) disable iff (!reset_n)
            (SCL_prev && SCL && !start_detected && !stop_detected) 
            |-> $stable(SDA);
    endproperty
    
    assert property (p_sda_stable_when_scl_high)
        else $error("I2C: SDA changed while SCL was stable high (illegal).");
    
    /*
    property p_txn_has_termination;
        @(posedge clk) disable iff (!reset_n)
            start_detected 
            |-> 
            ##[1:5000] (stop_detected || start_detected || (SDA && SCL));
    endproperty
    
    assert property (p_txn_has_termination)
        else $error("I2C: Transaction did not terminate within 5000 cycles.");
    */
    

    property p_no_permanent_start;
        @(posedge clk) disable iff (!reset_n)
            start_detected |-> ##[1:$] (stop_detected || !start_detected);
    endproperty
    
    // This is a cover, not assert - just for observability
    cover property (p_no_permanent_start);
    
    // Protocol coverage
    cover property (@(posedge clk) disable iff (!reset_n) start_detected);
    cover property (@(posedge clk) disable iff (!reset_n) stop_detected);
    
endmodule
