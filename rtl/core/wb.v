/**
* Author: YangHui
* Date: 20220514
* File: wb.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module wb (
    input wire                  mem_w_reg_enable_i,
    input wire                  ex_w_reg_enable_i,
    input wire [`reg_addr_bus]  w_reg_addr_i,
    input wire [`reg_data_bus]  ex_w_reg_data_i,
    input wire [`reg_data_bus]  mem_w_reg_data_i,

    input wire [`data_type_bus] data_type_i,

    // reg
    output wire [`reg_addr_bus] w_reg_addr_o,
    output wire [`reg_data_bus] w_reg_data_o,
    output wire                 w_reg_enable_o
);

    assign w_reg_addr_o = w_reg_addr_i;
    assign w_reg_data_o = (
        (ex_w_reg_enable_i == `write_enable ) ? ex_w_reg_data_i :
        (mem_w_reg_enable_i == `write_enable) ? (
            (data_type_i == `datatype_byte ) ? {{24{mem_w_reg_data_i[7]}}, mem_w_reg_data_i[7:0]} : 
            (data_type_i == `datatype_half ) ? {{16{mem_w_reg_data_i[15]}}, mem_w_reg_data_i[15:0]} : 
            (data_type_i == `datatype_word ) ? mem_w_reg_data_i :
            (data_type_i == `datatype_ubyte) ? {24'b0, mem_w_reg_data_i[7:0]} : 
            (data_type_i == `datatype_uhalf) ? {16'b0, mem_w_reg_data_i[15:0]} : `data_zero) :
        `data_zero 
    );
    
    assign w_reg_enable_o = (
        (ex_w_reg_enable_i == `write_enable || mem_w_reg_enable_i == `write_enable) ? 
        `write_enable : `write_disable
    );

    
endmodule