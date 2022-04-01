/**
* Author: YangHui
* Date: 20220330
* File: id_ex.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

module id_ex (
    input wire                          clk,
    input wire                          rst_n,
    input wire [`holdpip_bus]           hold_flag_i,

    input wire [`reg_addr_bus]          r_reg_addr_1_i,
    input wire [`reg_addr_bus]          r_reg_addr_2_i,
    input wire [`csr_addr_bus]          r_csr_addr_i,
    // resource data input
    input wire [`reg_data_bus]          r_reg_data_1_i,
    input wire [`reg_data_bus]          r_reg_data_2_i,
    input wire [`imm_data_bus]          imm_data_i,
    input wire [`csr_data_bus]          r_csr_data_i,
    input wire [`inst_addr_bus]         r_pc_data_i,

    // predict_jump
    input wire                          predict_jump_enable_i,
    
    // alu inst
    input wire [`alu_inst_bus]          alu_inst_i,
    
    // inst input
    input wire [`inst_bus]              r_inst_i,

    // result target input
    input wire [`reg_addr_bus]          w_reg_addr_i,
    input wire [`csr_addr_bus]          w_csr_addr_i,

    // for l/s inst
    input wire [`data_type_bus]         data_type_i,

    output wire [`reg_addr_bus]         r_reg_addr_1_o,
    output wire [`reg_addr_bus]         r_reg_addr_2_o,
    output wire [`csr_addr_bus]         r_csr_addr_o,
    // resource data input
    output wire [`reg_data_bus]         r_reg_data_1_o,
    output wire [`reg_data_bus]         r_reg_data_2_o,
    output wire [`imm_data_bus]         imm_data_o,
    output wire [`csr_data_bus]         r_csr_data_o,
    output wire [`inst_addr_bus]        r_pc_data_o,
    
    // alu inst
    output wire [`alu_inst_bus]         alu_inst_o,
    
    // inst input
    output wire [`inst_bus]             r_inst_o,

    // result target input
    output wire [`reg_addr_bus]         w_reg_addr_o,
    output wire [`csr_addr_bus]         w_csr_addr_o,

    // for l/s inst
    output wire [`data_type_bus]        data_type_o,

    // predict_jump
    output wire                         predict_jump_enable_o
);

    wire hold_flush = (hold_flag_i == `hold_flush);
    wire hold_wait = (hold_flag_i == `hold_wait);

    pipe_reg_s #(
        .dw (`reg_data_bus_width)
    ) pipe_r_reg_data_1 (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`data_zero     ),
        .data_i         (r_reg_data_1_i ),
        .data_o         (r_reg_data_1_o )
    );

    pipe_reg_s #(
        .dw (`reg_addr_bus_width)
    ) pipe_r_reg_addr_1 (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`reg_zero      ),
        .data_i         (r_reg_addr_1_i ),
        .data_o         (r_reg_addr_1_o )
    );

    pipe_reg_s #(
        .dw (`reg_data_bus_width)
    ) pipe_r_reg_data_2 (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`data_zero     ),
        .data_i         (r_reg_data_2_i ),
        .data_o         (r_reg_data_2_o )
    );

    pipe_reg_s #(
        .dw (`reg_addr_bus_width)
    ) pipe_r_reg_addr_2 (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`reg_zero      ),
        .data_i         (r_reg_addr_2_i ),
        .data_o         (r_reg_addr_2_o )
    );

    pipe_reg_s #(
        .dw (`csr_addr_bus_width)
    ) pipe_r_csr_addr (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`csr_zero      ),
        .data_i         (r_csr_addr_i   ),
        .data_o         (r_csr_addr_o   )
    );

    pipe_reg_s #(
        .dw (`csr_data_bus_width)
    ) pipe_r_csr_data (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`csr_zero      ),
        .data_i         (r_csr_data_i   ),
        .data_o         (r_csr_data_o   )
    );

    pipe_reg_s #(
        .dw (`data_bus_width)
    ) pipe_imm_data (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`data_zero     ),
        .data_i         (imm_data_i     ),
        .data_o         (imm_data_o     )
    );

    pipe_reg_s #(
        .dw (`inst_addr_bus_width)
    ) pipe_pc_data (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`inst_addr_zero),
        .data_i         (r_pc_data_i    ),
        .data_o         (r_pc_data_o    )
    );

    pipe_reg_s #(
        .dw (`alu_inst_bus_width)
    ) pipe_alu_inst (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`alu_no        ),
        .data_i         (alu_inst_i     ),
        .data_o         (alu_inst_o     )
    );

    pipe_reg_s #(
        .dw (`inst_bus_width)
    ) pipe_r_inst (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`inst_nop      ),
        .data_i         (r_inst_i       ),
        .data_o         (r_inst_o       )
    );

    pipe_reg_s #(
        .dw (`reg_addr_bus_width)
    ) pipe_w_reg_addr (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`reg_zero      ),
        .data_i         (w_reg_addr_i   ),
        .data_o         (w_reg_addr_o   )
    );

    pipe_reg_s #(
        .dw (`csr_addr_bus_width)
    ) pipe_w_csr_addr (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`csr_zero      ),
        .data_i         (w_csr_addr_i   ),
        .data_o         (w_csr_addr_o   )
    );

    pipe_reg_s #(
        .dw (`data_type_bus_width)
    ) pipe_data_type (
    	.clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (hold_flush     ),
        .hold_en        (hold_wait      ),
        .default_data_i (`datatype_no   ),
        .data_i         (data_type_i    ),
        .data_o         (data_type_o    )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_predict_jump_enable (
    	.clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .set_default    (hold_flush             ),
        .hold_en        (hold_wait              ),
        .default_data_i (`predict_jump_disable  ),
        .data_i         (predict_jump_enable_i  ),
        .data_o         (predict_jump_enable_o  )
    );

    
    
endmodule