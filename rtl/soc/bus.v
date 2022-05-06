/** 
* Author: YangHui
* Date: 20220403
* File: bus.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

module bus (
    input wire [`mem_addr_bus]      cpu_addr_i,
    input wire [`data_bus]          cpu_data_i,
    output wire [`data_bus]         cpu_data_o,
    
    output wire [`mem_addr_bus]     per_addr_o,
    input wire [`data_bus]          tim_data_i,
    input wire [`data_bus]          uart_data_i,
    input wire [`data_bus]          fft_data_i
);


    
endmodule