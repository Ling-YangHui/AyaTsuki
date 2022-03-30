/**
* Author: YangHui
* Date: 20220328
* File: pc.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

module pc (
    // clk & rst
    input wire                  clk,
    input wire                  rst_n,
    // jump
    input wire                  jump_flag_i,
    input wire [`inst_addr_bus] jump_addr_i,
    // stop
    input wire [`holdpip_bus]   hold_flag_i,
    // jtag_reset
    input wire                  jtag_reset_i,
    output wire [`inst_bus]     pc_o
);

    reg [`inst_addr_bus] pc_r;

    always @(posedge clk) begin
        // reset
        if (rst_n == `rst_enable || jtag_reset_i == `jtag_rst_enable) begin
            pc_r <= `pc_reset;
        end else begin
            if (jump_flag_i == `jump_enable) begin
                pc_r <= jump_addr_i;
            end else if (hold_flag_i == `hold_no) begin
                pc_r <= pc_r + `inst_addr_bus_width 'b100;
            end
        end
    end

    assign pc_o = pc_r;

    `ifdef __DEBUG__
    always @(negedge clk) begin
        $display("------------pc------------");
        $display("pc: 0x%8x", pc_r);
        if (rst_n == `rst_disable && jtag_reset_i == `jtag_rst_disable) begin
            if (jump_addr_i === {`inst_bus_width{1'bx}}) begin
                $display("FATAL ERROR-> pc: jump_addr_i is x");
            end else if (jump_flag_i === 1'bx) begin
                $display("FATAL ERROR-> pc: jump_flag_i is x");
            end else if (jtag_reset_i === 1'bx) begin 
                $display("FATAL ERROR-> pc: jtag_reset_i is x");
            end
        end
    end
    `endif
    
endmodule
