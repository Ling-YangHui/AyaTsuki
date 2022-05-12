/**
* Author: YangHui
* Date: 20220401
* File: clint.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module clint (
    input wire                  clk,
    input wire                  rst_n,

    output wire [`irq_bus]      irq_o,
    input wire                  irq_ack,

    input wire                  tim_irq,
    input wire                  uart_tx_irq,
    input wire                  uart_rx_irq,
    input wire                  fft_irq,

    input wire [`mem_addr_bus]  clint_addr_i,
    input wire [`data_bus]      clint_data_i
);
    reg [`data_bus] irq_enable;

    reg tim_irq_pend;
    reg uart_tx_irq_pend;
    reg uart_rx_irq_pend;
    reg fft_irq_pend;

    reg n_tim_irq_pend;
    reg n_uart_tx_irq_pend;
    reg n_uart_rx_irq_pend;
    reg n_fft_irq_pend;

    always @(posedge clk) begin
        if (~rst_n) begin
            tim_irq_pend <= 0;
            uart_tx_irq_pend <= 0;
            uart_rx_irq_pend <= 0;
            fft_irq_pend <= 0;
        end else begin
            tim_irq_pend <= n_tim_irq_pend;
            uart_tx_irq_pend <= n_uart_tx_irq_pend;
            uart_rx_irq_pend <= n_uart_rx_irq_pend;
            fft_irq_pend <= n_fft_irq_pend;
        end
    end

    always @(*) begin
        if ((tim_irq || tim_irq_pend) && irq_enable[0]) begin
            
        end
    end


endmodule