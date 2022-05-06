/**
* Author: YangHui
* Date: 20220406
* File: uart.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`include "rtl/utils/div_clk.v"
`endif 

`ifdef __ISE__
`include "../core/define.v"
`endif 

module uart (
    input wire                  clk,
    input wire                  rst_n,

    input wire [`mem_addr_bus]  uart_r_addr_i,
    input wire [`mem_addr_bus]  uart_w_addr_i,
    input wire [`data_bus]      uart_data_i,
    input wire                  uart_r_enable_i,
    input wire                  uart_w_enable_i,
    output reg [`data_bus]      uart_data_o,
    output reg                  uart_irq_o,

    output reg                  tx,
    input wire                  rx
);

    
    
endmodule