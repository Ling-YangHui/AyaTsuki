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
    reg [`data_bus] tim_status_r; // tim_status

    wire tim_enable_irq = tim_conf_r[0];
    wire tim_prescaler = tim_conf_r[7: 1];
    wire tim_overflow = tim_conf_r[31: 16];

    // kernal clock
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tim_cnt_r <= `data_bus_width'b0;
        end else begin
            tim_cnt_r <= tim_cnt_r + `data_bus_width'b1;
        end
    end

    // pre-scaler
    reg [6: 0] prescaler_cnt;
    reg prescaler_clk;
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            prescaler_clk <= 7'b0;
        end else begin
            if (prescaler_clk == tim_prescaler) begin
                prescaler_cnt <= 7'b0;
                prescaler_clk <= 1'b1;
            end else begin
                prescaler_cnt <= prescaler_clk + 1'b1;
                prescaler_clk <= 1'b0;
            end
        end
    end

   // The divide clk should be reset by negedge edge of rst
    always @(posedge prescaler_clk or negedge rst_n) begin
        if (rst_n == `rst_enable) begin
            tim_status_r[7: 1] <= 7'b0;
        end else begin
            if (tim_status_r == tim_overflow) begin
                tim_status_r[7: 1] <= 7'b0;
                if (tim_enable_irq) begin
                    // TODO: Raise the irq
                end
            end else begin
                tim_status_r[7: 1] <= tim_status_r[7: 1] + 7'b1;
            end
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
                    `tim_status_addr: tim_data_o <= tim_status_r;
                endcase
            end
        end
    end

    // write data
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tim_conf_r <= `data_bus_width'b0;
            tim_status_r <= `data_bus_width'b0;
        end else begin
            if (tim_w_enable_i) begin
                case (tim_w_addr_i)
                    `tim_conf_addr: tim_conf_r <= tim_data_i;
                    `tim_status_addr: tim_status_r <= tim_data_i;
                endcase
            end
        end
    end

endmodule
