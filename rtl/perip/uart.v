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
`include "../rtl/core/define.v"
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

    reg [`data_bus] uart_tx_r;
    reg [`data_bus] uart_rx_r; // It will not be reset to zero
    reg tx_busy;

    reg [7: 0] tx_cnt;
    reg [7: 0] rx_cnt;

    // write tx
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_tx_r <= `data_zero;
            tx_busy <= 1'b0;
        end else begin
            if (uart_w_enable_i == `write_enable && uart_w_addr_i == `uart_tx_addr && ~tx_busy) begin
                uart_tx_r <= uart_data_i;
                tx_busy <= 1'b1;
            end else if (tx_cnt == 8'd176) begin
                tx_busy <= 1'b0;
            end          
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            uart_data_o <= `data_zero;
        end else begin
            if (uart_r_enable_i) begin
                case (uart_r_addr_i)
                    `uart_tx_addr: uart_data_o <= uart_tx_r;
                    `uart_status_addr: uart_data_o <= {31'b0, tx_busy};
                endcase
            end
        end
    end

    wire uart_clk;
    div_clk #(
        .Frequency (15_4300 )    
    ) u_div_clk(
    	.sys_clk (clk       ),
        .rst_n   (rst_n     ),
        .div_clk (uart_clk  )
    );
    
    reg tx_parity;
    always @(posedge uart_clk, negedge rst_n) begin
        if (rst_n == `rst_enable) begin
            tx_cnt <= 0;
            tx_parity <= 0;
            tx <= 1;
        end else begin
            if (tx_busy) begin
                case (tx_cnt)
                    8'd0: begin
                        tx <= 1'b0;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 0th bit */
                    8'd16: begin
                        tx <= uart_tx_r[0];
                        tx_parity <= uart_tx_r[0];
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 1st bit */			
                    8'd32: begin
                        tx <= uart_tx_r[1]; 
                        tx_parity <= uart_tx_r[1] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 2nd bit */			
                    8'd48: begin
                        tx <= uart_tx_r[2];
                        tx_parity <= uart_tx_r[2] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 3rd bit */
                    8'd64: begin
                        tx <= uart_tx_r[3];
                        tx_parity <= uart_tx_r[3] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 4th bit */
                    8'd80: begin 
                        tx <= uart_tx_r[4];
                        tx_parity <= uart_tx_r[4] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 5th bit */
                    8'd96: begin
                        tx <= uart_tx_r[5];
                        tx_parity <= uart_tx_r[5] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 6th bit */
                    8'd112: begin
                        tx <= uart_tx_r[6]; 
                        tx_parity <= uart_tx_r[6] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    /* the 7th bit */
                    8'd128: begin 
                        tx <= uart_tx_r[7];
                        tx_parity <= uart_tx_r[7] ^ tx_parity;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    8'd144: begin
                        tx <= tx_parity;
                        tx_parity <= 1'b0;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    8'd160: begin
                        tx <= 1'b1;
                        tx_parity <= 1'b0;
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    8'd176: begin
                        tx <= 1'b1;             
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                    default: begin
                        tx_cnt <= tx_cnt + 8'd1;
                    end
                endcase
            end
        end
    end
    
endmodule