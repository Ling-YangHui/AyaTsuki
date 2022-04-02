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

module ex_memwb (
    input wire                  clk,
    input wire                  rst_n,

    input wire [`holdpip_bus]   hold_flag_i,
    // In
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

    // Out
    // connect to trans: ex_w-ex_data mem_w-read_mem_data
    output wire                 ex_w_reg_enable_o,
    output wire                 mem_w_reg_enable_o,
    output wire [`reg_addr_bus] w_reg_addr_o,
    output wire [`reg_data_bus] ex_w_reg_data_o,

    // mem
    // write_mem
    output wire [`mem_addr_bus] w_mem_addr_o,
    output wire                 w_mem_enable_o,
    output wire [`mem_data_bus] w_mem_data_o,
    // read_mem
    output wire [`mem_addr_bus] r_mem_addr_o,
    output wire                 r_mem_enable_o,

    // data type
    output wire [`data_type_bus] data_type_o

    /*
    input wire                  ex_w_csr_enable_i,
    input wire [`csr_addr_bus]  ex_w_csr_addr_i,
    input wire [`csr_data_bus]  ex_w_csr_data_i,
    output wire [`csr_addr_bus] ex_w_csr_addr_o,
    output wire [`csr_data_bus] ex_w_csr_data_o,
    output wire                 ex_w_csr_enable_o
    */
);

    wire hold_flush = (hold_flag_i == `hold_flush);
    wire hold_wait = (hold_flag_i == `hold_wait);

    pipe_reg_s #(
        .dw (1)
    ) pipe_ex_w_reg_enable (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`write_disable     ),
        .data_i         (ex_w_reg_enable_i  ),
        .data_o         (ex_w_reg_enable_o  )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_mem_w_reg_enable (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`write_disable     ),
        .data_i         (mem_w_reg_enable_i ),
        .data_o         (mem_w_reg_enable_o )
    );

    pipe_reg_s #(
        .dw (`reg_addr_bus_width)
    ) pipe_w_reg_addr (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`reg_zero          ),
        .data_i         (w_reg_addr_i       ),
        .data_o         (w_reg_addr_o       )
    );

    pipe_reg_s #(
        .dw (`reg_data_bus_width)
    ) pipe_ex_w_reg_data (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`data_zero         ),
        .data_i         (ex_w_reg_data_i    ),
        .data_o         (ex_w_reg_data_o    )
    );

    pipe_reg_s #(
        .dw (`mem_addr_bus_width)
    ) pipe_w_mem_addr (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`mem_addr_zero     ),
        .data_i         (w_mem_addr_i       ),
        .data_o         (w_mem_addr_o       )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_w_mem_enable (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`mem_disable       ),
        .data_i         (w_mem_enable_i     ),
        .data_o         (w_mem_enable_o     )
    );

    pipe_reg_s #(
        .dw (`mem_data_bus_width)
    ) pipe_w_mem_data (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`data_zero         ),
        .data_i         (w_mem_data_i       ),
        .data_o         (w_mem_data_o       )
    );

    pipe_reg_s #(
        .dw (`mem_addr_bus_width)
    ) pipe_r_mem_addr (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`mem_addr_zero     ),
        .data_i         (r_mem_addr_i       ),
        .data_o         (r_mem_addr_o       )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_r_mem_enable (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`mem_disable       ),
        .data_i         (r_mem_enable_i     ),
        .data_o         (r_mem_enable_o     )
    );
    
    pipe_reg_s #(
        .dw (`data_type_bus_width)
    ) pipe_data_type (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`datatype_no       ),
        .data_i         (data_type_i        ),
        .data_o         (data_type_o        )
    );

    /*
    pipe_reg_s #(
        .dw (`csr_addr_bus_width)
    ) pipe_ex_w_csr_addr (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`csr_zero          ),
        .data_i         (ex_w_csr_addr_i    ),
        .data_o         (ex_w_csr_addr_o    )
    );

    pipe_reg_s #(
        .dw (`csr_data_bus_width)
    ) pipe_ex_w_csr_data (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`data_zero         ),
        .data_i         (ex_w_csr_data_i    ),
        .data_o         (ex_w_csr_data_o    )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_ex_w_csr_enable (
    	.clk            (clk                ),
        .rst_n          (rst_n              ),
        .set_default    (hold_flush         ),
        .hold_en        (hold_wait          ),
        .default_data_i (`write_disable     ),
        .data_i         (ex_w_csr_enable_i  ),
        .data_o         (ex_w_csr_enable_o  )
    );
    */

    
    `ifdef __DEBUG__
    /*
    always @(negedge clk) begin
        $display("---------ex_memwb---------");
        $display("ex_w_reg_enable: 0x%x, mem_w_reg_enable: 0x%x, w_reg_addr: 0x%x, ex_w_reg_data: 0x%x", 
            ex_w_reg_enable_o, mem_w_reg_enable_o, w_reg_addr_o, ex_w_reg_data_o);
        $display("w_mem_addr: 0x%x, w_mem_enable: 0x%x, w_mem_data: 0x%x", 
            w_mem_addr_o, w_mem_enable_o, w_mem_data_o);
        $display("r_mem_addr: 0x%x, r_mem_enable: 0x%x", 
            r_mem_addr_o, r_mem_enable_o);
        
        $display("ex_w_csr_enable: 0x%x, ex_w_csr_data: 0x%x, ex_w_csr_addr: 0x%x", 
            ex_w_csr_enable_o, ex_w_csr_data_o, ex_w_csr_addr_o);
        */
    //end
    `endif
    
endmodule