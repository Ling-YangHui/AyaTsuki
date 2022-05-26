/**
* Author: YangHui
* Date: 20220526
* File: uart.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

`ifdef __ISE__
`include "../core/define.v"
`endif 

module crc32 (
    input wire                  clk,
    input wire                  rst_n,

    input wire [`mem_addr_bus]  crc_r_addr_i,
    input wire [`mem_addr_bus]  crc_w_addr_i,
    input wire [`data_bus]      crc_data_i,
    input wire                  crc_r_enable_i,
    input wire                  crc_w_enable_i,

    output reg [`data_bus]      crc_data_o
);

    reg [7: 0] crc_data_wr;
    reg [`data_bus] crc_status_r;
    reg [`data_bus] crc_ctrl_wr;
    reg [`data_bus] crc_result_r;
    
    `define crc_complete crc_status_r[0]
    wire crc_continue = crc_ctrl_wr[0];

    wire w_data_enable = crc_w_enable_i == `write_enable && crc_w_addr_i == `crc_data_addr;
    wire w_ctrl_enable = crc_w_enable_i == `write_enable && crc_w_addr_i == `crc_ctrl_addr;
    wire r_result_r = crc_r_enable_i == `read_enable && crc_r_addr_i == `crc_result_addr;
    wire r_status_r = crc_r_enable_i == `read_enable && crc_r_addr_i == `crc_status_addr;

    /* RAM Interface: Read and Write */
    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_data_wr <= 0;
        end else if (w_data_enable) begin
            crc_data_wr <= crc_data_i;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_ctrl_wr <= `datatype_word;
        end else if (w_ctrl_enable) begin
            crc_ctrl_wr <= crc_data_i;
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_data_o <= `data_zero;
        end else begin
            case (crc_r_addr_i)
                `crc_data_addr: crc_data_o <= crc_data_wr;
                `crc_status_addr: crc_data_o <= {31'b0, `crc_complete}; 
                `crc_result_addr: crc_data_o <= crc_result_r;
                default: crc_data_o <= `data_zero;
            endcase
        end
    end

    /* CRC Kernel */
    localparam CRC_STATUS_IDLE = 1'b0;
    localparam CRC_STATUS_BUSY = 1'b1;
    localparam BYTE_LEN = 8;

    reg [31: 0] crc_shift;
    reg crc_status;
    reg n_crc_status;
    reg [3: 0] crc_cnt;

    wire data_back = crc_shift[0];
    wire crc_start = w_data_enable && (crc_status == CRC_STATUS_IDLE);

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_status <= CRC_STATUS_IDLE;
        end else begin
            crc_status <= n_crc_status;
        end
    end

    always @(*) begin
        case(crc_status)
            CRC_STATUS_IDLE: begin
                if (crc_start) begin
                    n_crc_status = CRC_STATUS_BUSY;
                end else begin
                    n_crc_status = CRC_STATUS_IDLE;
                end
            end
            CRC_STATUS_BUSY: begin
                if (crc_cnt) begin
                    n_crc_status = CRC_STATUS_BUSY;
                end else begin
                    n_crc_status = CRC_STATUS_IDLE;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_cnt <= 0;
        end else begin
            if (crc_start) begin
                crc_cnt <= BYTE_LEN;
            end else begin
                if (crc_cnt > 0) begin
                    crc_cnt <= crc_cnt - 1;
                end 
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            crc_shift <= 32'hFFFFFFFF;
        end else begin
            if (crc_start) begin
                crc_shift <= crc_shift ^ (crc_data_i[7: 0] << 24);
            end else if (crc_cnt) begin
                crc_shift <= (crc_shift << 1) ^ (32'h04C11DB7 & {32{crc_shift[31]}});
            end else if (~crc_continue) begin
                crc_shift <= 32'hFFFFFFFF;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            `crc_complete <= 0;
            crc_result_r <= `data_zero;
        end else begin
            if (crc_status == CRC_STATUS_BUSY && crc_cnt == 0) begin
                crc_result_r <= crc_shift;
                `crc_complete <= 1;
            end else if (r_status_r) begin
                `crc_complete <= 0;
            end
        end
    end
    
    
endmodule