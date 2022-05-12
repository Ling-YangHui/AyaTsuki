`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module csr (
    input wire                  clk,
    input wire                  rst_n,

    // write_reg from mem_wb or ctrl
    input wire                  w_enable_i,
    input wire                  w_ctrl_enable_i,
    input wire [`csr_addr_bus]  w_addr_i,
    input wire [`csr_data_bus]  w_data_i,

    // write_reg from jtag
    input wire                  jtag_w_enable_i,
    input wire [`csr_addr_bus]  jtag_addr_i,
    input wire [`csr_data_bus]  jtag_w_data_i,

    // read_reg from id
    input wire [`csr_addr_bus]  r_addr_1_i,
    output wire [`csr_data_bus] r_data_1_o,
    input wire [`csr_addr_bus]  r_addr_2_i,
    output wire [`csr_data_bus] r_data_2_o,

    // read_reg from jtag
    output wire [`csr_data_bus] jtag_r_data_o,

    // direct write from ctrl
    input wire [`csr_data_bus]  w_mstatus_i,
    input wire [`csr_data_bus]  w_mepc_i,
    input wire [`csr_data_bus]  w_mie_i,
    input wire [`csr_data_bus]  w_mip_i,
    input wire [`csr_data_bus]  w_mcause_i,

    output wire [`csr_data_bus] r_mstatus_o,
    output wire [`csr_data_bus] r_mepc_o,
    output wire [`csr_data_bus] r_mtvec_o,
    output wire [`csr_data_bus] r_mie_o,
    output wire [`csr_data_bus] r_mip_o,
    output wire [`csr_data_bus] r_mcause_o
);

    reg [`csr_data_bus] mstatus;
    reg [`csr_data_bus] mepc;
    reg [`csr_data_bus] mtvec;
    reg [`csr_data_bus] mcycle;
    reg [`csr_data_bus] mie;
    reg [`csr_data_bus] mcause;
    reg [`csr_data_bus] mip;

    wire [`csr_data_bus] mstatus_in = (
        w_enable_i ? (
            (w_ctrl_enable_i) ? w_mstatus_i :
            (w_addr_i == `csr_mstatus_addr) ? w_data_i : mstatus
        ) : mstatus
    );
    wire [`csr_data_bus] mepc_in = (
        w_enable_i ? (
            (w_ctrl_enable_i) ? w_mepc_i :
            (w_addr_i == `csr_mepc_addr) ? w_data_i : mepc
        ) : mepc
    );
    wire [`csr_data_bus] mtvec_in = (
        w_enable_i ? (
            (w_addr_i == `csr_mtvec_addr) ? w_data_i : mtvec
        ) : mtvec
    );
    wire [`csr_data_bus] mcycle_in = mcycle + `csr_data_bus_width'b1;
    wire [`csr_data_bus] mie_in = (
        w_enable_i ? (
            (w_ctrl_enable_i) ? w_mepc_i : 
            (w_addr_i == `csr_mie_addr) ? w_data_i : mie
        ) : mie
    );

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            mstatus <= `csr_data_bus_width'b0;
            mepc <= `csr_data_bus_width'b0;
            mcycle <= `csr_data_bus_width'b0;
            mtvec <= `csr_data_bus_width'b0;
            mie <= `csr_data_bus_width'b0;
        end else begin
            mstatus <= mstatus_in;
            mcycle <= mcycle_in;
            mtvec <= mtvec_in;
            mepc <= mepc_in;
            mie <= mie_in;
        end
    end

    assign r_data_1_o = (
        (r_addr_1_i == `csr_mstatus_addr) ? mstatus_in :
        (r_addr_1_i == `csr_mepc_addr) ? mepc :
        (r_addr_1_i == `csr_mtvec_addr) ? mtvec_in : 
        (r_addr_1_i == `csr_mcycle_addr) ? mcycle : 
        (r_addr_1_i == `csr_mie_addr) ? mie : `csr_data_bus_width'b0
    );
    assign r_data_2_o = (
        (r_addr_2_i == `csr_mstatus_addr) ? mstatus_in :
        (r_addr_2_i == `csr_mepc_addr) ? mepc :
        (r_addr_2_i == `csr_mtvec_addr) ? mtvec_in : 
        (r_addr_2_i == `csr_mcycle_addr) ? mcycle :  
        (r_addr_1_i == `csr_mie_addr) ? mie : `csr_data_bus_width'b0
    );

    assign r_mepc_o = mepc;
    assign r_mtvec_o = mtvec;
    assign r_mstatus_o = mstatus;
    assign r_mie_o = mie;
    assign r_mip_o = mip;
    assign r_mcause_o = mcause;
    
endmodule