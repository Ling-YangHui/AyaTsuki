`ifndef __ISE__
`include "rtl/core/define.v"
`include "rtl/core/pc.v"
`include "rtl/core/if_id.v"
`include "rtl/core/id.v"
`endif 

module pc_ifid (
    input wire                      clk,
    input wire                      rst_n,
    // to inst_rom
    input wire [`inst_bus]          inst_i,
    output wire [`inst_addr_bus]    inst_addr_o,
    // for debug
    input wire jump_flag_i,
    input wire [`inst_addr_bus] jump_addr_i,
    input wire [`hold_ctrl_bus] hold_i,
    output wire [`inst_bus] inst_o
);

    wire [`holdpip_bus] hold_pc_i = hold_i[1:0];
    wire [`holdpip_bus] hold_if_id_i = hold_i[3:2];

    wire [`inst_addr_bus] ifid_pc_o;

    pc u_pc(
    	.clk          (clk          ),
        .rst_n        (rst_n        ),
        .jump_flag_i  (jump_flag_i  ),
        .jump_addr_i  (jump_addr_i  ),
        .hold_flag_i  (hold_pc_i    ),
        .jtag_reset_i (jtag_reset_i ),
        .pc_o         (inst_addr_o  )
    );
    
    if_id u_if_id(
    	.clk         (clk         ),
        .rst_n       (rst_n       ),
        .hold_flag_i (hold_if_id_i),
        .inst_i      (inst_i      ),
        .inst_addr_i (inst_addr_o ),
        .inst_o      (inst_o      ),
        .inst_addr_o (ifid_pc_o   )
    );

    id u_id(
    	.inst_i         (inst_o         ),
        .inst_addr_i    (ifid_pc_o      )
    );
    
    
    
endmodule