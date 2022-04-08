/**
* Author: YangHui
* Date: 20220406
* File: load.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "../core/define.v"
`endif

module load (
    input wire                      clk,
    input wire                      rst_n,

    input wire                      sclk_i, // default pull down, set in bitstearm configuration
    input wire                      sdin_i,
    output reg [`inst_addr_bus]     inst_addr_o,
    output reg [`inst_bus]          inst_data_o,
    output reg                      inst_w_enable_o
);

    reg last_sclk;
    wire sclk_up = (~last_sclk && sclk_i);
    reg [7: 0] clk_cnt;

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            last_sclk <= 0;
        end else begin
            last_sclk <= sclk_i;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            clk_cnt <= 0;
            inst_addr_o <= `inst_addr_zero;
            inst_data_o <= `inst_nop;
            inst_w_enable_o <= `write_disable;
        end else begin
            if (sclk_up) begin
                if (clk_cnt < 'd32) begin
                    inst_addr_o <= {inst_addr_o[30: 0], sdin_i};
                    clk_cnt <= clk_cnt + 'd1;
                    inst_w_enable_o <= `write_disable;
                end else if (clk_cnt < 'd63) begin
                    inst_data_o <= {inst_data_o[30: 0], sdin_i};
                    clk_cnt <= clk_cnt + 'd1;
                    inst_w_enable_o <= `write_disable;
                end else if (clk_cnt == 'd63) begin
                    clk_cnt <= 'd0;
                    inst_data_o <= {inst_data_o[30: 0], sdin_i};
                    inst_w_enable_o <= `write_enable;
                end
            end else begin
                inst_w_enable_o <= `write_disable;
            end
        end
    end
    
endmodule