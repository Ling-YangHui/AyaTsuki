/**
* Author: YangHui
* Date: 20220328
* File: ex_memwb.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

// FIXME 
// The inst of load/store byte/halfword need to be support
// The inst of unsigned expansion need to be support
module mem_wb (
    // write_reg
    // connect to trans: ex_w-ex_data mem_w-read_mem_data
    input wire                  ex_w_reg_enable_i,
    input wire                  mem_w_reg_enable_i,
    input wire [`reg_addr_bus]  w_reg_addr_i,
    input wire [`reg_data_bus]  ex_w_reg_data_i,

    // mem
    // write_mem
    input wire [`mem_addr_bus]  w_mem_addr_i,
    input wire                  w_mem_enable_i,
    input wire [`mem_data_bus]  w_mem_data_i,
    // read_mem
    // Because of the feature of BRAM, the read req is sent on ex
    // input wire [`mem_addr_bus]  r_mem_addr_i,
    // input wire                  r_mem_enable_i,

    // data type
    input wire [`data_type_bus] data_type_i,

    // mem_io
    input wire [`mem_data_bus]  r_mem_data_i, // read from mem
    output wire [`mem_addr_bus] w_mem_addr_o,
    output wire [`mem_data_bus] w_mem_data_o,
    // output wire [`mem_addr_bus] r_mem_addr_o,
    output wire                 w_mem_enable_o,
    // output wire                 r_mem_enable_o,

    // output wire                 mem_enable_o,

    // reg
    output wire [`reg_addr_bus] w_reg_addr_o,
    output wire [`reg_data_bus] w_reg_data_o,
    output wire                 w_reg_enable_o
    
    // csr
    /*
    input wire                  ex_w_csr_enable_i,
    input wire [`csr_addr_bus]  ex_w_csr_addr_i,
    input wire [`csr_data_bus]  ex_w_csr_data_i,
    output wire [`csr_addr_bus] ex_w_csr_addr_o,
    output wire [`csr_data_bus] ex_w_csr_data_o,
    output wire                 ex_w_csr_enable_o
    */
);

    // enable and addr
    // assign mem_enable_o = ((w_mem_enable_i == `write_enable) ? `mem_enable : `mem_disable);
    assign w_mem_addr_o = w_mem_addr_i;
    assign w_mem_enable_o = w_mem_enable_i;
    // assign r_mem_addr_o = r_mem_addr_i;
    // assign r_mem_enable_o = r_mem_enable_i;

    assign w_reg_enable_o = (
        (ex_w_reg_enable_i == `write_enable || mem_w_reg_enable_i == `write_enable) ? 
        `write_enable : `write_disable
    );
    assign w_reg_addr_o = w_reg_addr_i;
    
    // data
    assign w_mem_data_o = (
        (data_type_i == `datatype_byte) ? {r_mem_data_i[31:8], w_mem_data_i[7:0]} : 
        (data_type_i == `datatype_half) ? {r_mem_data_i[31:16], w_mem_data_i[15:0]} : 
        (data_type_i == `datatype_word) ? w_mem_data_i : `data_zero
    );
    assign w_reg_data_o = (
        (ex_w_reg_enable_i == `write_enable ) ? ex_w_reg_data_i :
        (mem_w_reg_enable_i == `write_enable) ? (
            (data_type_i == `datatype_byte ) ? {{24{r_mem_data_i[8]}}, r_mem_data_i[7:0]} : 
            (data_type_i == `datatype_half ) ? {{16{r_mem_data_i[16]}}, r_mem_data_i[7:0]} : 
            (data_type_i == `datatype_word ) ? r_mem_data_i :
            (data_type_i == `datatype_ubyte) ? {24'b0, r_mem_data_i[7:0]} : 
            (data_type_i == `datatype_uhalf) ? {16'b0, r_mem_data_i[15:0]} : `data_zero) :
        `data_zero 
    );

    /*
    assign ex_w_csr_enable_o = ex_w_csr_enable_i;
    assign ex_w_csr_data_o = ex_w_csr_data_i;
    assign ex_w_csr_addr_o = ex_w_csr_addr_i;
    */

endmodule
