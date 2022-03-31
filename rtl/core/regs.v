/**
* Author: YangHui
* Date: 20220328
* File: reg.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

module regs (
    input wire                  clk,
    input wire                  rst_n,
    // write_reg from mem_wb
    input wire                  w_enable_i,
    input wire [`reg_addr_bus]  w_addr_i,
    input wire [`reg_data_bus]  w_data_i,
    // write_reg from jtag
    input wire                  jtag_w_enable_i,
    input wire [`reg_addr_bus]  jtag_addr_i,
    input wire [`reg_data_bus]  jtag_w_data_i,
    // read_reg from id
    input wire [`reg_addr_bus]  r_addr_1_i,
    output wire [`reg_data_bus] r_data_1_o,
    input wire [`reg_addr_bus]  r_addr_2_i,
    output wire [`reg_data_bus] r_data_2_o,
    // read_reg from jtag
    output wire [`reg_data_bus] jtag_r_data_o
);

    reg[`reg_data_bus] regs [`reg_num-1: 0];

    // write_reg
    always @(posedge clk) begin
        if (rst_n == `rst_disable) begin
            if (w_enable_i == `write_enable && w_addr_i != `reg_zero) begin
                regs[w_addr_i] <= w_data_i;
            end else if (jtag_w_enable_i == `write_enable && jtag_addr_i != `reg_zero) begin
                regs[jtag_addr_i] <= jtag_w_data_i;
            end
        end else begin
            regs[0] <= `data_zero;
            regs[1] <= `data_zero;
            regs[2] <= `sp_init;
            regs[3] <= `data_zero;
            regs[4] <= `data_zero;
            regs[5] <= `data_zero;
            regs[6] <= `data_zero;
            regs[7] <= `data_zero;
            regs[8] <= `data_zero;
            regs[9] <= `data_zero;
            regs[10] <= `data_zero;
            regs[11] <= `data_zero;
            regs[12] <= `data_zero;
            regs[13] <= `data_zero;
            regs[14] <= `data_zero;
            regs[15] <= `data_zero;
            regs[16] <= `data_zero;
            regs[17] <= `data_zero;
            regs[18] <= `data_zero;
            regs[19] <= `data_zero;
            regs[20] <= `data_zero;
            regs[21] <= `data_zero;
            regs[22] <= `data_zero;
            regs[23] <= `data_zero;
            regs[24] <= `data_zero;
            regs[25] <= `data_zero;
            regs[26] <= `data_zero;
            regs[27] <= `data_zero;
            regs[28] <= `data_zero;
            regs[29] <= `data_zero;
            regs[30] <= `data_zero;
            regs[31] <= `data_zero;
        end
    end

    `ifdef __DEBUG__
    integer i;
    always @(negedge clk) begin
        $display("-----------regs-----------");
        for (i = 0; i < 32; i = i + 4) begin
            $display("reg%3d: 0x%x, reg%3d: 0x%x, reg%3d: 0x%x, reg%3d: 0x%x", i, regs[i], i+1, regs[i+1], i+2, regs[i+2], i+3, regs[i+3]);
        end
    end
    `endif
    
    // read_reg 1
    assign r_data_1_o = (
        (r_addr_1_i == `reg_zero) ? `data_zero : 
        (r_addr_1_i == w_addr_i) ? w_data_i : regs[r_addr_1_i]
    );
    // read_reg 2
    assign r_data_2_o = (
        (r_addr_2_i == `reg_zero) ? `data_zero : 
        (r_addr_2_i == w_addr_i) ? w_data_i : regs[r_addr_2_i]
    );
    // jtag_reg 
    assign jtag_r_data_o = ((jtag_addr_i == `reg_zero) ? `data_zero : regs[jtag_addr_i]);

endmodule
