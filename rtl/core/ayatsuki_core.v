/**
* Author: YangHui
* Date: 20220328
* File: ayatsuki_core.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`include "rtl/core/pc.v"
`include "rtl/core/if_id.v"
`include "rtl/core/id.v"
`include "rtl/core/regs.v"
`include "rtl/core/ex.v"
`include "rtl/core/ctrl.v"
`include "rtl/core/trans.v"
`include "rtl/core/id_ex.v"
`include "rtl/core/mem_wb.v"
`include "rtl/core/ex_mem.v"
`include "rtl/core/mem.v"
`include "rtl/core/wb.v"
`include "rtl/core/csr.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module ayatsuki_core (
    input wire                      clk,
    input wire                      rst_n,
    
    input wire [`inst_bus]          inst_i,
    output wire [`inst_addr_bus]    inst_addr_o,

    output wire                     mem_w_enable_o,
    output wire                     mem_r_enable_o,
    output wire                     mem_enable_o,
    output wire [`mem_addr_bus]     mem_w_addr_o,
    output wire [`mem_addr_bus]     mem_r_addr_o,
    input wire [`mem_data_bus]      mem_data_i,
    output wire [`mem_data_bus]     mem_data_o,

    input wire [`irq_bus]           irq_req_i,
    output wire                     irq_response_o
);

    wire [`hold_ctrl_bus] hold_bus;
    wire [`holdpip_bus] hold_pc = hold_bus[1:0];
    wire [`holdpip_bus] hold_if_id = hold_bus[3:2];
    wire [`holdpip_bus] hold_id_ex = hold_bus[5:4];
    wire [`holdpip_bus] hold_ex_mem = hold_bus[7:6];
    wire [`holdpip_bus] hold_mem_wb = hold_bus[9:8];

    wire [`jump_cause_bus] jump_cause;
    wire [`inst_addr_bus] jump_from_addr;
    wire [`inst_addr_bus] jump_to_addr;
    wire [`inst_addr_bus] pc_pre_inst_addr;
    wire [`inst_addr_bus] pc_inst_addr;
    wire pc_predict_jump_enable;

    assign inst_addr_o = pc_pre_inst_addr;

    /*
    pc u_pc(
    	.clk          (clk          ),
        .rst_n        (rst_n        ),
        .jump_flag_i  (jump_flag    ),
        .jump_addr_i  (jump_addr    ),
        .hold_flag_i  (hold_pc      ),
        .pc_o         (pc_inst_addr )
        .jtag_reset_i (jtag_reset_i ),
    );
    */

    pc u_pc(
    	.clk               (clk                     ),
        .rst_n             (rst_n                   ),
        .jump_cause_i      (jump_cause              ),
        .jump_from_addr_i  (jump_from_addr          ),
        .jump_to_addr_i    (jump_to_addr            ),
        .hold_flag_i       (hold_pc                 ),
        //.jtag_reset_i      (jtag_reset_i      ),
        .inst_i            (inst_i                  ),
        .pc_o              (pc_pre_inst_addr        ),
        .predict_to_jump_o (pc_predict_jump_enable  ),
        .now_pc_o          (pc_inst_addr            )
    );
    

    wire [`inst_addr_bus] if_id_inst_addr;
    wire [`inst_bus] if_id_inst;
    wire if_id_predict_jump_enable;
    if_id u_if_id(
    	.clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .hold_flag_i            (hold_if_id                 ),
        .inst_i                 (inst_i                     ),
        .inst_addr_i            (pc_inst_addr               ),
        .predict_jump_enable_i  (pc_predict_jump_enable     ),
        .inst_o                 (if_id_inst                 ),
        .inst_addr_o            (if_id_inst_addr            ),
        .predict_jump_enable_o  (if_id_predict_jump_enable  )
    );
    

    wire w_reg_enable;
    wire [`reg_addr_bus] w_reg_addr;
    wire [`reg_data_bus] w_reg_data;
    wire [`reg_addr_bus] r_reg_addr1;
    wire [`reg_data_bus] r_reg_data1;
    wire [`reg_addr_bus] r_reg_addr2;
    wire [`reg_data_bus] r_reg_data2;

    regs u_regs(
    	.clk             (clk               ),
        .rst_n           (rst_n             ),
        .w_enable_i      (w_reg_enable      ),
        .w_addr_i        (w_reg_addr        ),
        .w_data_i        (w_reg_data        ),
        .r_addr_1_i      (r_reg_addr1       ),
        .r_data_1_o      (r_reg_data1       ),
        .r_addr_2_i      (r_reg_addr2       ),
        .r_data_2_o      (r_reg_data2       )
        /*
        .jtag_r_data_o   (jtag_r_data_o     )
        .jtag_w_enable_i (jtag_w_enable_i   ),
        .jtag_addr_i     (jtag_addr_i       ),
        .jtag_w_data_i   (jtag_w_data_i     ),
        */
    );

    wire w_memwb_csr_enable;
    wire w_ctrl_csr_enable;
    wire w_csr_enable = w_memwb_csr_enable | w_ctrl_csr_enable;
    wire [`csr_addr_bus] w_csr_addr;
    wire [`csr_data_bus] w_csr_data;
    wire [`csr_addr_bus] r_csr_addr;
    wire [`csr_data_bus] r_csr_data;

    wire [`csr_data_bus] w_ctrl_mstatus;
    wire [`csr_data_bus] w_ctrl_mepc;
    wire [`csr_data_bus] r_ctrl_mstatus;
    wire [`csr_data_bus] r_ctrl_mepc;
    wire [`csr_data_bus] r_ctrl_mtvec;

    csr u_csr(
    	.clk             (clk               ),
        .rst_n           (rst_n             ),
        .w_enable_i      (w_csr_enable      ),
        .w_ctrl_enable_i (w_ctrl_csr_enable ),
        .w_addr_i        (w_csr_addr        ),
        .w_data_i        (w_csr_data        ),
        /*
        .jtag_w_enable_i (jtag_w_enable_i   ),
        .jtag_addr_i     (jtag_addr_i       ),
        .jtag_w_data_i   (jtag_w_data_i     ),
        */
        .r_addr_1_i      (r_csr_addr        ),
        .r_data_1_o      (r_csr_data        ),
        /*
        .jtag_r_data_o   (jtag_r_data_o     ),
        */
        .w_mstatus_i     (w_ctrl_mstatus    ),
        .w_mepc_i        (w_ctrl_mepc       ),
        .r_mstatus_o     (r_ctrl_mstatus    ),
        .r_mepc_o        (r_ctrl_mepc       ),
        .r_mtvec_o       (r_ctrl_mtvec      )
    );
    

    wire [`reg_data_bus] id_reg_data1;
    wire [`reg_data_bus] id_reg_data2;
    wire [`data_bus] id_imm_data;
    wire [`inst_addr_bus] id_pc_inst_addr;
    wire [`alu_inst_bus] id_alu_inst;
    wire [`inst_bus] id_inst;
    wire [`reg_addr_bus] id_w_reg_addr;
    wire [`data_type_bus] id_datatype;

    wire [`csr_data_bus] id_csr_data;
    wire [`csr_addr_bus] id_w_csr_addr;

    id u_id(
    	.inst_i         (if_id_inst         ),
        .inst_addr_i    (if_id_inst_addr    ),
        .r_reg_data_1_i (r_reg_data1        ),
        .r_reg_data_2_i (r_reg_data2        ),
        .r_reg_addr_1_o (r_reg_addr1        ),
        .r_reg_addr_2_o (r_reg_addr2        ),
        
        .r_csr_data_i   (r_csr_data         ),
        .r_csr_addr_o   (r_csr_addr         ),
        
        .r_reg_data_1_o (id_reg_data1       ),
        .r_reg_data_2_o (id_reg_data2       ),
        .imm_data_o     (id_imm_data        ),
        
        .r_csr_data_o   (id_csr_data        ),
        
        .r_pc_data_o    (id_pc_inst_addr    ),
        .alu_inst_o     (id_alu_inst        ),
        .r_inst_o       (id_inst            ),
        .w_reg_addr_o   (id_w_reg_addr      ),
        
        .w_csr_addr_o   (id_w_csr_addr      ),
        
        .data_type_o    (id_datatype        )
    );

    wire [`reg_addr_bus] id_ex_reg_addr1;
    wire [`reg_addr_bus] id_ex_reg_addr2;
    wire [`reg_data_bus] id_ex_r_reg_data1;
    wire [`reg_data_bus] id_ex_r_reg_data2;
    wire [`data_bus] id_ex_imm_data;
    wire [`inst_addr_bus] id_ex_pc_data;
    wire [`alu_inst_bus] id_ex_alu_inst;
    wire [`inst_bus] id_ex_inst;
    wire [`reg_addr_bus] id_ex_w_reg_addr;
    wire [`data_type_bus] id_ex_datatype;
    wire id_ex_predict_jump_enable;
    wire [`csr_addr_bus] id_ex_csr_addr;
    wire [`csr_data_bus] id_ex_csr_data;
    wire [`csr_addr_bus] id_ex_w_csr_addr;

    id_ex u_id_ex(
    	.clk                    (clk                        ),
        .rst_n                  (rst_n                      ),
        .hold_flag_i            (hold_id_ex                 ),
        .r_reg_addr_1_i         (r_reg_addr1                ),
        .r_reg_addr_2_i         (r_reg_addr2                ),
        .r_csr_addr_i           (r_csr_addr                 ),
        .r_reg_data_1_i         (id_reg_data1               ),
        .r_reg_data_2_i         (id_reg_data2               ),
        .imm_data_i             (id_imm_data                ),
        .r_csr_data_i           (r_csr_data                 ),
        .r_pc_data_i            (id_pc_inst_addr            ),
        .alu_inst_i             (id_alu_inst                ),
        .r_inst_i               (id_inst                    ),
        .w_reg_addr_i           (id_w_reg_addr              ),
        .w_csr_addr_i           (id_w_csr_addr              ),
        .data_type_i            (id_datatype                ),

        .predict_jump_enable_i  (if_id_predict_jump_enable  ),

        .r_reg_addr_1_o         (id_ex_reg_addr1            ),
        .r_reg_addr_2_o         (id_ex_reg_addr2            ),
        .r_csr_addr_o           (id_ex_csr_addr             ),
        .r_reg_data_1_o         (id_ex_r_reg_data1          ),
        .r_reg_data_2_o         (id_ex_r_reg_data2          ),
        .imm_data_o             (id_ex_imm_data             ),
        .r_csr_data_o           (id_ex_csr_data             ),
        .r_pc_data_o            (id_ex_pc_data              ),
        .alu_inst_o             (id_ex_alu_inst             ),
        .r_inst_o               (id_ex_inst                 ),
        .w_reg_addr_o           (id_ex_w_reg_addr           ),
        .w_csr_addr_o           (id_ex_w_csr_addr           ),
        .data_type_o            (id_ex_datatype             ),
        .predict_jump_enable_o  (id_ex_predict_jump_enable  )
    );
    

    wire [`reg_data_bus] trans_reg_data_1;
    wire [`reg_data_bus] trans_reg_data_2;
    wire [`csr_data_bus] trans_csr_data;

    wire ex_jump_flag;
    wire [`inst_addr_bus] ex_jump_from_addr;
    wire [`inst_addr_bus] ex_jump_to_addr;
    wire ex_exw_reg_enable;
    wire ex_memw_reg_enable;
    wire [`reg_addr_bus] ex_w_reg_addr;
    wire [`reg_data_bus] ex_w_reg_data;
    wire [`mem_addr_bus] ex_w_mem_addr;
    wire [`data_bus] ex_w_mem_data;
    wire ex_w_mem_enable;
    wire [`mem_addr_bus] ex_r_mem_addr;
    wire ex_r_mem_enable;
    wire [`data_type_bus] ex_datatype;
    wire [`jump_cause_bus] ex_jump_cause;

    wire [`csr_addr_bus] ex_w_csr_addr;
    wire [`csr_data_bus] ex_w_csr_data;
    wire ex_w_csr_enable;

    ex u_ex(
    	.r_reg_data_1_i         (trans_reg_data_1   ),
        .r_reg_data_2_i         (trans_reg_data_2   ),
        .r_imm_data_i           (id_ex_imm_data     ),
        .r_csr_data_i           (trans_csr_data     ),
        .r_pc_data_i            (id_ex_pc_data      ),
        .alu_inst_i             (id_ex_alu_inst     ),
        .r_inst_i               (id_ex_inst         ),
        .w_reg_addr_i           (id_ex_w_reg_addr   ),
        .w_csr_addr_i           (id_ex_w_csr_addr   ),
        .data_type_i            (id_ex_datatype     ),

        .predict_jump_enable_i  (id_ex_predict_jump_enable),

        .jump_cause_o           (ex_jump_cause      ),
        .jump_from_addr_o       (ex_jump_from_addr  ),
        .jump_to_addr_o         (ex_jump_to_addr    ),

        .ex_w_reg_enable_o      (ex_exw_reg_enable    ),
        .mem_w_reg_enable_o     (ex_memw_reg_enable   ),
        .w_reg_addr_o           (ex_w_reg_addr      ),
        .ex_w_reg_data_o        (ex_w_reg_data      ),
        .w_mem_addr_o           (ex_w_mem_addr      ),
        .w_mem_enable_o         (ex_w_mem_enable    ),
        .w_mem_data_o           (ex_w_mem_data      ),
        .r_mem_addr_o           (ex_r_mem_addr      ),
        .r_mem_enable_o         (ex_r_mem_enable    ),
        .data_type_o            (ex_datatype        ),
        
        .ex_w_csr_addr_o        (ex_w_csr_addr      ),
        .ex_w_csr_data_o        (ex_w_csr_data      ),
        .ex_w_csr_enable_o      (ex_w_csr_enable    )
        
    );

    wire ex_mem_exw_reg_enable;
    wire ex_mem_memw_reg_enable;
    wire [`reg_addr_bus] ex_mem_w_reg_addr;
    wire [`data_bus] ex_mem_w_reg_data;
    wire [`mem_addr_bus] ex_mem_w_mem_addr;
    wire ex_mem_w_mem_enable;
    wire [`data_bus] ex_mem_w_mem_data;
    wire [`data_type_bus] ex_mem_datatype;
    wire [`csr_addr_bus] ex_mem_w_csr_addr;
    wire [`csr_data_bus] ex_mem_w_csr_data;
    wire [`mem_addr_bus] ex_mem_r_mem_addr;
    wire ex_mem_r_mem_enable;
    wire ex_mem_w_csr_enable;

    ex_mem u_ex_mem(
    	.clk                (clk                ),
        .rst_n              (rst_n              ),
        .hold_flag_i        (hold_ex_mem      ),

        .ex_w_reg_enable_i  (ex_exw_reg_enable  ),
        .mem_w_reg_enable_i (ex_memw_reg_enable ),
        .w_reg_addr_i       (ex_w_reg_addr      ),
        .ex_w_reg_data_i    (ex_w_reg_data      ),
        .w_mem_addr_i       (ex_w_mem_addr      ),
        .w_mem_enable_i     (ex_w_mem_enable    ),
        .w_mem_data_i       (ex_w_mem_data      ),
        .r_mem_addr_i       (ex_r_mem_addr      ),
        .r_mem_enable_i     (ex_r_mem_enable    ),
        .data_type_i        (ex_datatype        ),

        .ex_w_reg_enable_o  (ex_mem_exw_reg_enable   ),
        .mem_w_reg_enable_o (ex_mem_memw_reg_enable  ),
        .w_reg_addr_o       (ex_mem_w_reg_addr       ),
        .ex_w_reg_data_o    (ex_mem_w_reg_data       ),
        .w_mem_addr_o       (ex_mem_w_mem_addr       ),
        .w_mem_enable_o     (ex_mem_w_mem_enable     ),
        .w_mem_data_o       (ex_mem_w_mem_data       ),
        .r_mem_addr_o       (ex_mem_r_mem_addr       ),
        .r_mem_enable_o     (ex_mem_r_mem_enable     ),
        .data_type_o        (ex_mem_datatype         ),

        .ex_w_csr_enable_i  (ex_w_csr_enable         ),
        .ex_w_csr_addr_i    (ex_w_csr_addr           ),
        .ex_w_csr_data_i    (ex_w_csr_data           ),
        .ex_w_csr_addr_o    (ex_mem_w_csr_addr       ),
        .ex_w_csr_data_o    (ex_mem_w_csr_data       ),
        .ex_w_csr_enable_o  (ex_mem_w_csr_enable     )

    );
    
    wire [`reg_addr_bus] mem_w_reg_addr;
    wire mem_memw_reg_enable;
    wire mem_exw_reg_enable;
    wire [`data_bus] mem_memw_reg_data;
    wire [`data_bus] mem_exw_reg_data;
    wire [`data_type_bus] mem_data_type;

    mem u_mem(
    	.ex_w_reg_enable_i  (ex_mem_exw_reg_enable   ),
        .mem_w_reg_enable_i (ex_mem_memw_reg_enable  ),
        .w_reg_addr_i       (ex_mem_w_reg_addr       ),
        .ex_w_reg_data_i    (ex_mem_w_reg_data       ),
        .w_mem_addr_i       (ex_mem_w_mem_addr       ),
        .w_mem_enable_i     (ex_mem_w_mem_enable     ),
        .w_mem_data_i       (ex_mem_w_mem_data       ),
        .r_mem_addr_i       (ex_mem_r_mem_addr       ),
        .r_mem_enable_i     (ex_mem_r_mem_enable     ),
        .data_type_i        (ex_mem_datatype         ),

        .r_mem_data_i       (mem_data_i             ),
        .w_mem_addr_o       (mem_w_addr_o           ),
        .w_mem_data_o       (mem_data_o             ),
        .w_mem_enable_o     (mem_w_enable_o         ),

        .mem_w_reg_enable_o (mem_memw_reg_enable    ),
        .ex_w_reg_enable_o  (mem_exw_reg_enable     ),
        .w_reg_addr_o       (mem_w_reg_addr         ),
        .ex_w_reg_data_o    (mem_exw_reg_data       ),
        .mem_w_reg_data_o   (mem_memw_reg_data      ),

        .data_type_o        (mem_data_type          ),

        .r_mem_addr_o       (mem_r_addr_o           ),
        .r_mem_enable_o     (mem_r_enable_o         ),
        .mem_enable_o       (mem_enable_o           ),

        .ex_w_csr_enable_i  (ex_mem_w_csr_enable     ),
        .ex_w_csr_addr_i    (ex_mem_w_csr_addr       ),
        .ex_w_csr_data_i    (ex_mem_w_csr_data       ),

        .ex_w_csr_addr_o    (w_csr_addr             ),
        .ex_w_csr_data_o    (w_csr_data             ),
        .ex_w_csr_enable_o  (w_memwb_csr_enable     )
    );

    wire mem_wb_wr_wait_req_i = (ex_memw_reg_enable && (ex_w_reg_addr == r_reg_addr1 || ex_mem_w_reg_addr == r_reg_addr2));

    trans u_trans(
        // supply by mem wb
    	.mem_w_reg_req_i    (ex_mem_exw_reg_enable  ),
        .mem_w_reg_addr_i   (ex_mem_w_reg_addr      ),
        .mem_w_reg_data_i   (ex_mem_w_reg_data      ),

        .wb_w_reg_req_i     (w_reg_enable           ),
        .wb_w_reg_addr_i    (w_reg_addr             ),
        .wb_w_reg_data_i    (w_reg_data             ),
        
        .w_csr_req_i        (w_csr_enable           ),
        .w_csr_addr_i       (w_csr_addr             ),
        .w_csr_data_i       (w_csr_data             ),
        
        // supply by id_ex
        .r_reg_addr_1_i     (id_ex_reg_addr1        ),
        .r_reg_addr_2_i     (id_ex_reg_addr2        ),
        .r_reg_data_1_i     (id_ex_r_reg_data1      ),
        .r_reg_data_2_i     (id_ex_r_reg_data2      ),
        
        .r_csr_addr_i       (id_ex_csr_addr         ),
        .r_csr_data_i       (id_ex_csr_data         ),
        

        // output
        .r_reg_data_1_o (trans_reg_data_1   ),
        .r_reg_data_2_o (trans_reg_data_2   ),
        
        .r_csr_data_o   (trans_csr_data     )
        
    );

    ctrl u_ctrl(
        .clk                        (clk                    ),
        .rst_n                      (rst_n                  ),
        //.ex_multi_clock_wait_req_i (ex_multi_clock_wait_req_i ),
        .ex_jump_cause_i            (ex_jump_cause          ),
        .mem_wb_wr_wait_req_i       (mem_wb_wr_wait_req_i      ),
        .irq_flush_req_addr_i       (irq_req_i              ),
        .irq_acknowledge_o          (irq_response_o         ),
        //.jtag_halt_wait_req_i      (jtag_halt_wait_req_i      ),
        .ex_jump_to_addr_i          (ex_jump_to_addr        ),
        .ex_jump_from_addr_i        (ex_jump_from_addr      ),
        .hold_ctrl_o                (hold_bus               ),
        .jump_cause_o               (jump_cause             ),
        .jump_from_addr_o           (jump_from_addr         ),
        .jump_to_addr_o             (jump_to_addr           ),

        .r_mstatus_i                (r_ctrl_mstatus         ),
        .r_mepc_i                   (r_ctrl_mepc            ),
        .r_mtvec_i                  (r_ctrl_mtvec           ),

        .w_mstatus_o                (w_ctrl_mstatus         ),
        .w_mepc_o                   (w_ctrl_mepc            ),
        .w_mstatus_enable           (w_ctrl_csr_enable      )
    );

    wire mem_wb_memw_reg_enable;
    wire mem_wb_exw_reg_enable;
    wire [`reg_addr_bus] mem_wb_w_reg_addr;
    wire [`data_bus] mem_wb_memw_reg_data;
    wire [`data_bus] mem_wb_exw_reg_data;
    wire [`data_type_bus] mem_wb_data_type;

    mem_wb u_mem_wb(
    	.clk                (clk                    ),
        .rst_n              (rst_n                  ),
        .hold_flag_i        (hold_mem_wb            ),

        .mem_w_reg_enable_i (mem_memw_reg_enable    ),
        .ex_w_reg_enable_i  (mem_exw_reg_enable     ),
        .w_reg_addr_i       (mem_w_reg_addr         ),
        .ex_w_reg_data_i    (mem_exw_reg_data       ),
        .mem_w_reg_data_i   (mem_memw_reg_data      ),
        .data_type_i        (mem_data_type          ),

        .mem_w_reg_enable_o (mem_wb_memw_reg_enable ),
        .ex_w_reg_enable_o  (mem_wb_exw_reg_enable  ),
        .w_reg_addr_o       (mem_wb_w_reg_addr      ),
        .ex_w_reg_data_o    (mem_wb_exw_reg_data    ),
        .mem_w_reg_data_o   (mem_wb_memw_reg_data   ),
        .data_type_o        (mem_wb_data_type       )
    );
    

    wb u_wb(
    	.mem_w_reg_enable_i (mem_wb_memw_reg_enable ),
        .ex_w_reg_enable_i  (mem_wb_exw_reg_enable  ),
        .w_reg_addr_i       (mem_wb_w_reg_addr      ),
        .ex_w_reg_data_i    (mem_wb_exw_reg_data    ),
        .mem_w_reg_data_i   (mem_data_i             ),
        .data_type_i        (mem_wb_data_type       ),
        .w_reg_addr_o       (w_reg_addr             ),
        .w_reg_data_o       (w_reg_data             ),
        .w_reg_enable_o     (w_reg_enable           )
    );
    

    // Because of the feature of BRAM, the read req is sent on ex
    // assign mem_r_addr_o = ex_r_mem_addr;
    // assign mem_r_enable_o = ex_r_mem_enable;
    // assign mem_enable_o =  (mem_w_enable_o == `write_enable || mem_r_enable_o == `read_enable) ?
    //      `mem_enable : `mem_disable;
    
endmodule

