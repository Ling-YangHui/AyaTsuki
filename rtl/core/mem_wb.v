/**
* Author: YangHui
* Date: 20220514
* File: ex_memwb.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module mem_wb (
    input wire                  clk,
    input wire                  rst_n,

    input wire [`holdpip_bus]   hold_flag_i,

    input wire                  mem_w_reg_enable_i,
    input wire                  ex_w_reg_enable_i,
    input wire [`reg_addr_bus]  w_reg_addr_i,
    input wire [`reg_data_bus]  ex_w_reg_data_i,
    input wire [`reg_data_bus]  mem_w_reg_data_i,

    input wire [`data_type_bus] data_type_i,

    output wire                  mem_w_reg_enable_o,
    output wire                  ex_w_reg_enable_o,
    output wire [`reg_addr_bus]  w_reg_addr_o,
    output wire [`reg_data_bus]  ex_w_reg_data_o,
    output wire [`reg_data_bus]  mem_w_reg_data_o,

    output wire [`data_type_bus] data_type_o

);

    wire hold_flush = (hold_flag_i == `hold_flush);
    wire hold_wait = (hold_flag_i == `hold_wait);

    pipe_reg_s #(
        .dw (1 )
    ) u_memw_reg_enable(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`write_disable     ),
        .data_i         (mem_w_reg_enable_i     ),
        .data_o         (mem_w_reg_enable_o     )
    );

    pipe_reg_s #(
        .dw (1 )
    ) u_exw_reg_enable(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`write_disable     ),
        .data_i         (ex_w_reg_enable_i     ),
        .data_o         (ex_w_reg_enable_o     )
    );

    pipe_reg_s #(
        .dw (`reg_addr_bus_width )
    ) u_w_reg_addr(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`reg_zero          ),
        .data_i         (w_reg_addr_i       ),
        .data_o         (w_reg_addr_o       )
    );

    pipe_reg_s #(
        .dw (`data_bus_width )
    ) u_memw_reg_data(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`data_zero         ),
        .data_i         (ex_w_reg_data_i       ),
        .data_o         (ex_w_reg_data_o       )
    );

    pipe_reg_s #(
        .dw (`data_bus_width )
    ) u_exw_reg_data(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`data_zero         ),
        .data_i         (mem_w_reg_data_i       ),
        .data_o         (mem_w_reg_data_o       )
    );

    pipe_reg_s #(
        .dw (`data_type_bus_width )
    ) u_data_type(
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`datatype_word     ),
        .data_i         (data_type_i       ),
        .data_o         (data_type_o       )
    );
    
    
endmodule