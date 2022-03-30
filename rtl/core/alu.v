/**
* Author: YangHui
* Date: 20220330
* File: alu.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

module alu (
    input wire [`alu_inst_bus]      alu_inst_i,
    input wire signed [`data_bus]   alu_src1_i,
    input wire signed [`data_bus]   alu_src2_i,        
    output wire [`data_bus]         alu_result_o
);

    wire [`data_bus] u_alu_src1_i = alu_src1_i;
    wire [`data_bus] u_alu_src2_i = alu_src2_i;
    
    wire [`data_bus] arl_mask = {32{1'b1}} >> alu_src2_i[4:0];

    assign alu_result_o = (
        (alu_inst_i == `alu_add) ? alu_src1_i + alu_src2_i :
        (alu_inst_i == `alu_sub) ? alu_src1_i - alu_src2_i :
        (alu_inst_i == `alu_or) ? alu_src1_i | alu_src2_i :
        (alu_inst_i == `alu_and) ? alu_src1_i & alu_src2_i :
        (alu_inst_i == `alu_xor) ? alu_src1_i ^ alu_src2_i :
        (alu_inst_i == `alu_ll) ? alu_src1_i << alu_src2_i[4:0] :
        (alu_inst_i == `alu_rl) ? alu_src1_i >> alu_src2_i[4:0] :
        (alu_inst_i == `alu_arl) ? 
            (alu_src1_i >>> alu_src2_i) | ({32{alu_src1_i[31]}} & ~arl_mask) :
        (alu_inst_i == `alu_cmp_less) ? (alu_src1_i < alu_src2_i) :
        (alu_inst_i == `alu_cmp_lessu) ? (u_alu_src1_i < u_alu_src2_i) : 
        (alu_inst_i == `alu_cmp_eq) ? (alu_src1_i == alu_src2_i) : 
        (alu_inst_i == `alu_cmp_neq) ? (alu_src1_i != alu_src2_i) : 
        (alu_inst_i == `alu_cmp_less_eq) ? (alu_src1_i <= alu_src2_i) :
        (alu_inst_i == `alu_cmp_more) ? (alu_src1_i > alu_src2_i) :
        (alu_inst_i == `alu_cmp_more_eq) ? (alu_src1_i >= alu_src2_i) : 
        (alu_inst_i == `alu_cmp_more_equ) ? (u_alu_src1_i >= u_alu_src2_i) : 32'b0
    );
    
endmodule