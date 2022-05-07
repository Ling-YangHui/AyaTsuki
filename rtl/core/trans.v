/**
* Author: YangHui
* Date: 20220328
* File: trans.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

module trans (
    // write_req
    input wire                  w_reg_req_i,
    input wire [`reg_addr_bus]  w_reg_addr_i,
    input wire [`reg_data_bus]  w_reg_data_i,
    input wire                  w_csr_req_i,
    input wire [`csr_addr_bus]  w_csr_addr_i,
    input wire [`csr_data_bus]  w_csr_data_i,
    // read_req
    input wire [`reg_addr_bus]  r_reg_addr_1_i,
    input wire [`reg_addr_bus]  r_reg_addr_2_i,
    input wire [`reg_data_bus]  r_reg_data_1_i,
    input wire [`reg_data_bus]  r_reg_data_2_i,
    input wire [`csr_addr_bus]  r_csr_addr_i,
    input wire [`csr_data_bus]  r_csr_data_i,
    // read_reg_result
    output wire [`reg_data_bus] r_reg_data_1_o,
    output wire [`reg_data_bus] r_reg_data_2_o,
    output wire [`csr_data_bus] r_csr_data_o
);
    
    // replace(transmit) the register data
    assign r_reg_data_1_o = (
        (r_reg_addr_1_i == w_reg_addr_i && w_reg_req_i == `write_reg_req_enable && r_reg_addr_1_i != 0) ? 
        w_reg_data_i : r_reg_data_1_i 
    );

    assign r_reg_data_2_o = (
        (r_reg_addr_2_i == w_reg_addr_i && w_reg_req_i == `write_reg_req_enable && r_reg_addr_2_i != 0) ? 
        w_reg_data_i : r_reg_data_2_i 
    ); 

    assign r_csr_data_o = (
        (r_csr_addr_i == w_csr_addr_i && w_csr_req_i == `write_reg_req_enable) ? 
        w_csr_data_i : r_csr_data_i
    );

endmodule