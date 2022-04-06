/** 
* Author: YangHui
* Date: 20220405
* File: tim.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

`ifdef __ISE__
`include "../core/define.v"
`endif

module tim (
    input wire                  clk,
    input wire                  rst_n,
    input wire [`mem_addr_bus]  tim_r_addr_i,
    input wire [`mem_addr_bus]  tim_w_addr_i,
    input wire [`data_bus]      tim_data_i,
    input wire                  tim_r_enable_i,
    input wire                  tim_w_enable_i,
    output reg [`data_bus]      tim_data_o,
    output reg                  tim_irq_o
);

    reg [`data_bus] tim_cnt_r; // read_only
    reg [`data_bus] tim_conf_r; // write_read

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tim_cnt_r <= `data_bus_width'b0;
        end else begin
            tim_cnt_r <= tim_cnt_r + `data_bus_width'b1;
        end
    end

    // read_data
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tim_data_o <= `data_zero;
        end else begin
            if (tim_r_enable_i) begin
                case (tim_r_addr_i)
                    `tim_cnt_addr: tim_data_o <= tim_cnt_r;
                    `tim_conf_addr: tim_data_o <= tim_conf_r;
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tim_conf_r <= `data_bus_width'b0;
        end else begin
            if (tim_w_enable_i) begin
                case (tim_w_addr_i)
                    `tim_conf_addr: tim_conf_r <= tim_data_i;
                endcase
            end
        end
    end

endmodule
