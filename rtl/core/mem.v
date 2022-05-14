/**
* Author: YangHui
* Date: 20220328
* File: ex_mem.v
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
module mem (
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

    input wire [`mem_addr_bus]  r_mem_addr_i,
    input wire                  r_mem_enable_i,

    // data type
    input wire [`data_type_bus] data_type_i,

    // mem_io
    input wire [`mem_data_bus]  r_mem_data_i, // read from mem

    output wire [`mem_addr_bus] w_mem_addr_o,
    output wire [`mem_data_bus] w_mem_data_o,
    output wire [`mem_addr_bus] r_mem_addr_o,
    output wire                 w_mem_enable_o,
    output wire                 r_mem_enable_o,

    output wire                 mem_enable_o,

    // reg
    output wire                  mem_w_reg_enable_o,
    output wire                  ex_w_reg_enable_o,
    output wire [`reg_addr_bus]  w_reg_addr_o,
    output wire [`reg_data_bus]  ex_w_reg_data_o,
    output wire [`reg_data_bus]  mem_w_reg_data_o,

    output wire [`data_type_bus] data_type_o,
    
    // csr
    input wire                  ex_w_csr_enable_i,
    input wire [`csr_addr_bus]  ex_w_csr_addr_i,
    input wire [`csr_data_bus]  ex_w_csr_data_i,
    output wire [`csr_addr_bus] ex_w_csr_addr_o,
    output wire [`csr_data_bus] ex_w_csr_data_o,
    output wire                 ex_w_csr_enable_o
    
);

    // enable and addr
    assign mem_enable_o = ((w_mem_enable_i == `write_enable) ? `mem_enable : `mem_disable);
    assign w_mem_addr_o = w_mem_addr_i;
    assign w_mem_enable_o = w_mem_enable_i;
    assign w_mem_data_o = w_mem_data_i;
    assign r_mem_addr_o = r_mem_addr_i;
    assign r_mem_enable_o = r_mem_enable_i;

    assign w_reg_addr_o = w_reg_addr_i;

    assign ex_w_csr_enable_o = ex_w_csr_enable_i;
    assign ex_w_csr_data_o = ex_w_csr_data_i;
    assign ex_w_csr_addr_o = ex_w_csr_addr_i;
    
    assign mem_w_reg_enable_o = mem_w_reg_enable_i;
    assign ex_w_reg_enable_o = ex_w_reg_enable_i;
    assign ex_w_reg_data_o = ex_w_reg_data_i;
    assign mem_w_reg_data_o = r_mem_data_i;
    assign data_type_o = data_type_i;

endmodule
