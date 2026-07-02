//import i2c_package::*;
module top_I2C(
    input  logic                 clk,
    input  logic                 reset_n,
    input  logic                 Master_enable,
    input  logic                 rd_wr_en,
    input  logic [ADDR_WIDTH-1:0] addr_in,
    input  logic [DATA_WIDTH-1:0] D_in,
    input  logic [2:0]           S_in,
    input  logic                 MSBIn,
    input  logic                 LSBIn,
    output logic                 done,
    output logic [DATA_WIDTH-1:0] data_out
);

    // --- internal wires ---
    logic [DATA_WIDTH-1:0] SR_out;
    logic ACK;
    logic SDA;
    logic SCL;            // bus SCL
    logic scl_drv;        // master-driven SCL
    logic scl_stretch_n;  // slave stretch control (1 = no stretch, 0 = hold low)

    // Functional unit (shift register)
    shift_register i_SR (
        .Q    (SR_out),
        .Clock(clk),
        .Clear(reset_n),
        .D    (D_in),
        .S    (S_in),
        .MSBIn(MSBIn),
        .LSBIn(LSBIn)
    );

    // Master now drives scl_drv instead of bus directly
    I2C_master i_I2C_master (
        .data_in     (SR_out),
        .addr_in     (addr_in),
        .clk         (clk),
        .enable      (Master_enable),
        .ACK         (ACK),
        .reset       (!reset_n),
        .wr_rdn_en_in(rd_wr_en),
        .SDA         (SDA),
        .SCL_drv     (scl_drv)   // <--- renamed port
    );

    // Slave receives bus SCL and drives stretch_n
    I2C_slave i_I2C_slave (
        .data_out     (data_out),
        .done         (done),
        .ACK          (ACK),
        .SDA          (SDA),
        .SCL          (SCL),      // bus SCL
        .reset_n      (reset_n),
        .clk          (clk),
        .scl_stretch_n(scl_stretch_n) // <--- new port
    );

    // Wired-AND SCL bus with clock stretching
    assign SCL = scl_drv & scl_stretch_n;

endmodule
