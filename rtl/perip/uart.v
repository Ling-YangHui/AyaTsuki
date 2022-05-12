/**
* Author: YangHui
* Date: 20220406
* File: uart.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
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
    
    output reg                  tx,
    input wire                  rx,

    output reg [`irq_bus]       uart_tx_irq,
    output reg [`irq_bus]       uart_rx_irq
);

    reg [7: 0] uart_tx_w;
    reg [7: 0] uart_rx_r;
    reg [`data_bus] uart_ctrl_rw;
    reg [`data_bus] uart_status_r;
    reg [`data_bus] uart_baud_rw;

    `define tx_sending uart_status_r[0]
    `define rx_valid uart_status_r[1] // if read rx, it will be reset

    wire uart_tx_enable = uart_ctrl_rw[0];
    wire uart_rx_enable = uart_ctrl_rw[1];
    wire uart_tx_irq_enable = uart_ctrl_rw[2];
    wire uart_rx_irq_enable = uart_ctrl_rw[3];
    
    parameter baud_115200 = 'd10_000_000 / 115200;
    
    /* RAM Interface: Read and Write */
    wire w_tx_enable = uart_w_enable_i == `write_enable && uart_w_addr_i == `uart_tx_addr;
    wire w_ctrl_enable = uart_w_enable_i == `write_enable && uart_w_addr_i == `uart_ctrl_addr;
    wire w_baud_enable = uart_w_enable_i == `write_enable && uart_w_addr_i == `uart_baud_addr;
    wire r_rx_enable = uart_r_enable_i == `read_enable && uart_r_addr_i == `uart_rx_addr;

    // write tx
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_tx_w <= 0;
        end else if (w_tx_enable) begin
            uart_tx_w <= uart_data_i[7: 0];
        end
    end

    // write ctrl
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_ctrl_rw <= 0;
        end else if (w_ctrl_enable) begin
            uart_ctrl_rw <= uart_data_i;
        end
    end

    // write baud
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_baud_rw <= baud_115200;
        end else if (w_baud_enable) begin
            uart_baud_rw <= uart_data_i;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_data_o <= 0;
        end else if (uart_r_enable_i) begin
            case (uart_r_addr_i)
                `uart_rx_addr: uart_data_o <= uart_rx_r;
                `uart_ctrl_addr: uart_data_o <= uart_ctrl_rw;
                `uart_baud_addr: uart_data_o <= uart_baud_rw;
                `uart_status_addr: uart_data_o <= uart_status_r[1: 0]; 
                default: uart_data_o <= 0;
            endcase
        end else begin
            uart_data_o <= 0;
        end
    end

    /* IRQ */
    reg n_tx_irq;
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_tx_irq <= 0;
        end else begin
            uart_tx_irq <= n_tx_irq;
        end
    end

    reg n_rx_irq;
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_rx_irq <= 0;
        end else begin
            uart_rx_irq <= n_rx_irq;
        end
    end

    /* TX Send Block */
    // regs
    reg [7: 0] tx_reg; // protect_reg, send data in this reg
    reg [1: 0] tx_status;
    reg [1: 0] n_tx_status;
    reg [15: 0] tx_cnt;
    reg [4: 0] tx_bit_cnt; 

    parameter TX_IDLE = 2'b00;
    parameter TX_START = 2'b01;
    parameter TX_DATA = 2'b11;
    parameter TX_END = 2'b10;

    // signals
    wire tx_start = w_tx_enable && uart_tx_enable && (`tx_sending == 1'b0);

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tx_reg <= 0;
        end else begin
            tx_reg <= uart_tx_w;
        end
    end
    
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tx_status <= TX_IDLE;
        end else begin
            tx_status <= n_tx_status;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            `tx_sending <= 0;
        end else begin
            if (tx_start) begin
                `tx_sending <= 1;
            end else if (tx_status == TX_IDLE) begin
                `tx_sending <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable || tx_status == TX_IDLE) begin
            tx_cnt <= 0;
        end else begin
            if (tx_cnt == uart_baud_rw[15: 0]) begin
                tx_cnt <= 0;
            end else begin
                tx_cnt <= tx_cnt + 16'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable || tx_status != TX_DATA) begin
            tx_bit_cnt <= 0;
        end else begin
            if (tx_cnt == uart_baud_rw[15: 0]) begin
                tx_bit_cnt <= tx_bit_cnt + 4'b1;
            end
        end
    end

    always @(*) begin
        case(tx_status)
            TX_IDLE: begin
                if (tx_start) begin
                    n_tx_status = TX_START;
                end else begin
                    n_tx_status = TX_IDLE;
                end
            end
            TX_START: begin
                if (tx_cnt == uart_baud_rw[15: 0]) begin
                    n_tx_status = TX_DATA;
                end else begin
                    n_tx_status = TX_START;
                end
            end
            TX_DATA: begin
                if (tx_cnt == uart_baud_rw[15: 0] && tx_bit_cnt == 4'd7) begin
                    n_tx_status = TX_END;
                end else begin
                    n_tx_status = TX_DATA;
                end
            end
            TX_END: begin
                if (tx_cnt == uart_baud_rw[15: 0]) begin
                    n_tx_status = TX_IDLE;
                end else begin
                    n_tx_status = TX_END;
                end
            end
        endcase
    end

    always @(*) begin
        if (tx_status == TX_END) begin
            if (tx_cnt == uart_baud_rw[15: 0] && uart_tx_irq_enable) begin
                n_tx_irq = 1;
            end else begin
                n_tx_irq = 0;
            end
        end else begin
            n_tx_irq = 0;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            tx <= 1'b1;
        end else begin
            case (tx_status)
                TX_IDLE, TX_END: tx <= 1'b1; 
                TX_START: tx <= 1'b0;
                TX_DATA: tx <= tx_reg[tx_bit_cnt];
                default: tx <= 1'b1;
            endcase
        end
    end

    /* RX Receive Block */
    // regs
    reg [7: 0] rx_reg;
    reg past_rx;
    reg [1: 0] rx_status;
    reg [1: 0] n_rx_status;
    reg [15: 0] rx_cnt;
    reg [3: 0] rx_bit_cnt;

    parameter RX_IDLE = 2'b00;
    parameter RX_START = 2'b01;
    parameter RX_DATA = 2'b11;
    parameter RX_END = 2'b10;

    // signals
    wire rx_start = past_rx && (~rx);

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            rx_status <= RX_IDLE;
        end else begin
            rx_status <= n_rx_status;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            `rx_valid <= 0;
        end else begin
            if (rx_status == RX_END && rx_cnt == uart_baud_rw[15: 0]) begin
                `rx_valid <= 1;
            end else if (r_rx_enable) begin
                `rx_valid <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            past_rx <= 1'b1;
        end else begin
            past_rx <= rx;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable || rx_status == RX_IDLE) begin
            rx_cnt <= 0;
        end else begin
            if (rx_status == RX_START && rx_cnt == (uart_baud_rw[15: 0] >> 1)) begin
                rx_cnt <= 0;
            end else if (rx_cnt == uart_baud_rw) begin
                rx_cnt <= 0;
            end else begin
                rx_cnt <= rx_cnt + 1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable || rx_status != RX_DATA) begin
            rx_bit_cnt <= 0;
        end else begin
            if (rx_cnt == uart_baud_rw[15: 0]) begin
                rx_bit_cnt <= tx_bit_cnt + 1;
            end
        end
    end

    always @(*) begin
        case (rx_status)
            RX_IDLE: begin
                if (rx_start && uart_rx_enable) begin
                    n_rx_status = RX_START;
                end else begin
                    n_rx_status = RX_IDLE;
                end
            end 
            RX_START: begin
                if (rx_cnt == (uart_baud_rw[15: 0] >> 1)) begin
                    n_rx_status = RX_DATA;
                end else begin
                    n_rx_status = RX_START;
                end
            end
            RX_DATA: begin
                if (rx_cnt == uart_baud_rw && rx_bit_cnt == 'd7) begin
                    n_rx_status = RX_END;
                end else begin
                    n_rx_status = RX_DATA;
                end
            end
            RX_END: begin
                if (rx_cnt == uart_baud_rw) begin
                    n_rx_status = RX_IDLE;
                end else begin
                    n_rx_status = RX_END;
                end
            end
        endcase
    end

    always @(*) begin
        if (rx_status == RX_END) begin
            if (rx_cnt == uart_baud_rw[15: 0] && uart_rx_irq_enable) begin
                n_rx_irq = 1;
            end else begin
                n_rx_irq = 0;
            end
        end else begin
            n_rx_irq = 0;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            rx_reg <= 0;
        end else begin
            if (tx_status == RX_DATA && rx_cnt == uart_baud_rw[15: 0]) begin
                rx_reg[rx_bit_cnt] <= rx;
            end 
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_rx_r <= 0;
        end else begin
            if (rx_status == RX_END && rx_cnt == uart_baud_rw[15: 0]) begin
                uart_rx_r <= rx_reg;
            end
        end
    end

endmodule