/**
* Author: YangHui
* Date: 20220328
* File: if_id.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

`ifdef __ISE__
`include "define.v"
`endif

module if_id (
    input wire                      clk,
    input wire                      rst_n,
    // stop
    input wire [`holdpip_bus]       hold_flag_i,
    // inst_i
    input wire [`inst_bus]          inst_i,
    input wire [`inst_addr_bus]     inst_addr_i,
    // predict_jump
    input wire                      predict_jump_enable_i,
    // inst_o
    output wire [`inst_bus]         inst_o,
    output wire [`inst_addr_bus]    inst_addr_o,

    output wire                     predict_jump_enable_o
);
    
    wire hold_en = (hold_flag_i == `hold_wait);
    wire flush_en = (hold_flag_i == `hold_flush);

    pipe_reg_s #(
        .dw (`inst_bus_width)
    ) pipe_inst (
    	.clk            (clk        ),
        .rst_n          (rst_n      ),
        .set_default    (flush_en   ),
        .hold_en        (hold_en    ),
        .default_data_i (`inst_nop  ),
        .data_i         (inst_i     ),
        .data_o         (inst_o     )
    );

    pipe_reg_s #(
        .dw (`inst_addr_bus_width)
    ) pipe_inst_addr (
        .clk            (clk            ),
        .rst_n          (rst_n          ),
        .set_default    (flush_en       ),
        .hold_en        (hold_en        ),
        .default_data_i (`data_zero     ),
        .data_i         (inst_addr_i    ),
        .data_o         (inst_addr_o    )
    );

    pipe_reg_s #(
        .dw (1)
    ) pipe_predict_jump_enable (
        .clk            (clk                    ),
        .rst_n          (rst_n                  ),
        .set_default    (flush_en               ),
        .hold_en        (hold_en                ),
        .default_data_i (`predict_jump_disable  ),
        .data_i         (predict_jump_enable_i  ),
        .data_o         (predict_jump_enable_o  )
    );

    `ifdef __DEBUG__
    always @(negedge clk) begin
        $display("-----------ifid-----------");
        $display("inst: 0x%x, inst_addr: 0x%x", inst_o, inst_addr_o);
    end
    `endif
    
endmodule
