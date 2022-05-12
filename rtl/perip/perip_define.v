// Perip Addr
`define tim_addr_start 32'h1000_0000
`define tim_cnt_addr 32'h1000_0000
`define tim_conf_addr 32'h1000_0004
`define tim_status_addr 32'h1000_0008
`define tim_addr_end 32'h1000_0008

`define uart_addr_start 32'h1000_0100
`define uart_tx_addr 32'h1000_0100
`define uart_rx_addr 32'h1000_0104
`define uart_status_addr 32'h1000_0108
`define uart_baud_addr 32'h1000_010C
`define uart_ctrl_addr 32'h1000_0110
`define uart_addr_end 32'h1000_0110

// IRQ Cause
`define irq_bus 7:0
`define irq_bus_width 8

`define irq_none 8'b0000_0000
`define irq_ebreak 8'b0000_0001
`define irq_tim 8'b0000_0010
`define irq_uart_tx 8'b0000_0011
`define irq_uart_rx 8'b0000_0100
`define irq_fft 8'b0000_0101
