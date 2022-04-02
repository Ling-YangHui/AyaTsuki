/**
* Author: YangHui
* Date: 20220328
* File: pipe_reg_s.v
*/
`ifndef __PIPE_REG_S__
`define __PIPE_REG_S__

module pipe_reg_s
#(
    parameter dw = 32
)(
    input wire              clk,
    input wire              rst_n,
    input wire              set_default,
    input wire              hold_en,
    // default_data
    input wire [dw-1: 0]    default_data_i,
    // input_data
    input wire [dw-1: 0]    data_i,
    // output_data
    output wire [dw-1: 0]   data_o
);

    reg [dw-1: 0] data_r;

    always @(posedge clk) begin
        if (~rst_n || set_default) begin
            data_r <= default_data_i;
        end else if (~hold_en) begin
            data_r <= data_i;
        end
    end

    assign data_o = data_r;

endmodule

`endif