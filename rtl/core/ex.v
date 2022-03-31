/**
* Author: YangHui
* Date: 20220330
* File: ex.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`include "rtl/core/alu.v"
`endif

module ex (
    // resource data input
    input wire [`reg_data_bus]          r_reg_data_1_i,
    input wire [`reg_data_bus]          r_reg_data_2_i,
    input wire [`imm_data_bus]          r_imm_data_i,
    input wire [`csr_data_bus]          r_csr_data_i,
    input wire [`inst_addr_bus]         r_pc_data_i,
    
    // alu inst
    input wire [`alu_inst_bus]          alu_inst_i,
    
    // inst input
    input wire [`inst_bus]              r_inst_i,

    // result target input
    input wire [`reg_addr_bus]          w_reg_addr_i,
    input wire [`csr_addr_bus]          w_csr_addr_i,

    // for l/s inst
    input wire [`data_type_bus]         data_type_i,

    // Out
    // jump
    output reg                          jump_enable_o,
    output reg [`inst_addr_bus]         jump_addr_o,               

    // connect to trans: ex_w-ex_data mem_w-read_mem_data
    output reg                          ex_w_reg_enable_o,
    output reg                          mem_w_reg_enable_o,
    output reg [`reg_addr_bus]          w_reg_addr_o,
    output reg [`reg_data_bus]          ex_w_reg_data_o,

    // mem
    // write_mem
    output reg [`mem_addr_bus]          w_mem_addr_o,
    output reg                          w_mem_enable_o,
    output reg [`mem_data_bus]          w_mem_data_o,
    // read_mem
    output reg [`mem_addr_bus]          r_mem_addr_o,
    output reg                          r_mem_enable_o,

    // data type
    output reg [`data_type_bus]         data_type_o,

    output reg [`csr_addr_bus]          ex_w_csr_addr_o,
    output reg [`csr_data_bus]          ex_w_csr_data_o,
    output reg                          ex_w_csr_enable_o
);

    reg [`data_bus] alu_src1;
    reg [`data_bus] alu_src2;
    wire [`data_bus] alu_result;

    reg signed [`data_bus] inst_add_src1;
    reg signed [`data_bus] inst_add_src2;
    wire [`data_bus] inst_add_result = inst_add_src1 + inst_add_src2;

    // first step: allocate the data to alu_src
    wire [6:0] opcode_i = r_inst_i[6:0];
    
    always @(*) begin
        inst_add_src1 = `data_zero;
        inst_add_src2 = `data_zero;
        case (opcode_i)
            `inst_r: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_reg_data_2_i;
            end
            `inst_i: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_imm_data_i;
            end
            `inst_b: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_reg_data_2_i;
                inst_add_src1 = r_pc_data_i;
                inst_add_src2 = r_imm_data_i;
            end
            `inst_l: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_imm_data_i;
            end
            `inst_s: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_imm_data_i;
            end
            `inst_jal: begin
                alu_src1 = r_pc_data_i;
                alu_src2 = r_imm_data_i;
                inst_add_src1 = r_pc_data_i;
                inst_add_src2 = 32'h4;
            end
            `inst_jalr: begin
                alu_src1 = r_reg_data_1_i;
                alu_src2 = r_imm_data_i;
                inst_add_src1 = r_pc_data_i;
                inst_add_src2 = 32'h4;
            end
            `inst_lui: begin
                alu_src1 = r_imm_data_i << 12;
                alu_src2 = 32'b0; // Use ADD
            end
            `inst_auipc: begin
                alu_src1 = r_pc_data_i;
                alu_src1 = r_imm_data_i << 12;
            end
            default: begin
                alu_src1 = 32'b0;
                alu_src2 = 32'b0;
            end 
        endcase
    end

    alu u_alu(
        .alu_inst_i   (alu_inst_i   ),
        .alu_src1_i   (alu_src1     ),
        .alu_src2_i   (alu_src2     ),
        .alu_result_o (alu_result   )
    );

    // third step: allocate output
    always @(*) begin

        jump_enable_o = `jump_disable;
        jump_addr_o = `inst_addr_zero;
        ex_w_reg_enable_o = `write_disable;
        mem_w_reg_enable_o = `write_disable;
        w_reg_addr_o = `reg_zero;
        ex_w_reg_data_o = `data_zero;
        w_mem_addr_o = `mem_addr_zero;
        w_mem_enable_o = `mem_disable;
        w_mem_data_o = `data_zero;
        r_mem_addr_o = `mem_addr_zero;
        r_mem_enable_o = `mem_disable;
        data_type_o = `datatype_no;
        ex_w_csr_addr_o = `csr_zero;
        ex_w_csr_data_o = `data_zero;
        ex_w_csr_enable_o = `csr_disable;

        case (opcode_i)
            `inst_r: begin
                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = alu_result;
                data_type_o = `datatype_word;
            end
            `inst_i: begin
                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = alu_result;
                data_type_o = `datatype_word;
            end
            `inst_b: begin
                jump_enable_o = (alu_result) ? `jump_enable : `jump_disable;
                jump_addr_o = inst_add_result; // FIXME
            end
            `inst_l: begin
                mem_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                r_mem_enable_o = `read_enable;
                r_mem_addr_o = alu_result;
                data_type_o = data_type_i;
            end
            `inst_s: begin
                w_mem_addr_o = alu_result;
                w_mem_enable_o = `write_enable;
                w_mem_data_o = r_reg_data_2_i;
                r_mem_enable_o = `read_enable;
                r_mem_addr_o = alu_result;
                data_type_o = data_type_i;
            end
            `inst_jal: begin
                jump_enable_o = `jump_enable;
                jump_addr_o = alu_result;

                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = inst_add_result;

                data_type_o = `datatype_word;
            end
            `inst_jalr: begin
                jump_enable_o = `jump_enable;
                jump_addr_o = alu_result;

                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = inst_add_result;

                data_type_o = `datatype_word;
            end
            `inst_lui: begin
                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = alu_result;
                
                data_type_o = `datatype_word;
            end
            `inst_auipc: begin
                ex_w_reg_enable_o = `write_enable;
                w_reg_addr_o = w_reg_addr_i;
                ex_w_reg_data_o = alu_result;
                
                data_type_o = `datatype_word;
            end
            default: begin
                
            end 
        endcase
    end

    
endmodule