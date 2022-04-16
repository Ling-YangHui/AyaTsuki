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
    input wire                  ebreak_inst_i,
    input wire [`irq_bus]       irq_req_i,
    output wire [`irq_bus]      irq_respond_o,

    output wire                 irq_enable_to_ctrl_o,
    output wire [`irq_bus]      irq_addr_to_ctrl_o
);
    
    

endmodule