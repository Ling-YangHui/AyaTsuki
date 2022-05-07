/**
* Author: YangHui
* Date: 20220328
* File: id.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module id (
    //TODO
    input wire [`inst_bus]              inst_i,
    input wire [`inst_addr_bus]         inst_addr_i,

    // read regs
    input wire [`reg_data_bus]          r_reg_data_1_i,
    input wire [`reg_data_bus]          r_reg_data_2_i,
    output reg [`reg_addr_bus]          r_reg_addr_1_o,
    output reg [`reg_addr_bus]          r_reg_addr_2_o,

    input wire [`csr_data_bus]          r_csr_data_i,
    output reg [`csr_addr_bus]          r_csr_addr_o,                   

    // resource data input
    output wire [`reg_data_bus]         r_reg_data_1_o,
    output wire [`reg_data_bus]         r_reg_data_2_o,
    output reg [`imm_data_bus]          imm_data_o,
    output wire [`csr_data_bus]         r_csr_data_o,
    output reg [`inst_addr_bus]         r_pc_data_o,
    
    // alu inst
    output reg [`alu_inst_bus]          alu_inst_o,
    
    // inst input
    output reg [`inst_bus]              r_inst_o,

    // result target input
    output reg [`reg_addr_bus]          w_reg_addr_o,
    output reg [`csr_addr_bus]          w_csr_addr_o,

    // for l/s inst
    output reg [`data_type_bus]         data_type_o
);

    wire [6:0] opcode = inst_i[6:0];
    wire [2:0] func3 = inst_i[14:12];
    wire [6:0] func7 = inst_i[31:25];
    wire signed [11:0] imm_i = inst_i[31:20];
    wire signed [11:0] imm_l = imm_i;
    wire signed [11:0] imm_s = {inst_i[31:25], inst_i[11:7]};
    wire signed [12:0] imm_b = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire signed [19:0] imm_u = inst_i[31:12];
    wire signed [20:0] imm_j = {inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    wire [4:0] rs1 = inst_i[19:15];
    wire [4:0] rs2 = inst_i[24:20];
    wire [4:0] rd = inst_i[11:7];
    // support for csr
    wire csr = imm_i;
    wire csr_i = rs2;

    assign r_reg_data_1_o = r_reg_data_1_i;
    assign r_reg_data_2_o = r_reg_data_2_i;
    assign r_csr_data_o = r_csr_data_i;

    always @(*) begin
        r_reg_addr_1_o = `reg_zero;
        r_reg_addr_2_o = `reg_zero;
        r_csr_addr_o = `csr_zero;
        imm_data_o = `data_zero;
        r_pc_data_o = inst_addr_i;
        alu_inst_o = `alu_no;
        r_inst_o = inst_i;
        w_reg_addr_o = `reg_zero;
        w_csr_addr_o = `csr_zero;
        data_type_o = `datatype_no;

        case (opcode)
            `inst_r: begin
                r_reg_addr_1_o = rs1;
                r_reg_addr_2_o = rs2;
                w_reg_addr_o = rd;
                data_type_o = `datatype_word;
                case (func3)
                    `inst_add_sub: begin
                        if (func7 == 7'h00) begin
                            // ADD
                            alu_inst_o = `alu_add;
                        end else begin
                            // SUB
                            alu_inst_o = `alu_sub;
                        end
                    end
                    `inst_xor: alu_inst_o = `alu_xor;
                    `inst_or: alu_inst_o = `alu_or;
                    `inst_and: alu_inst_o = `alu_and;
                    `inst_sll: alu_inst_o = `alu_ll;
                    `inst_srl_sra: begin
                        if (func7 == 7'h00) begin
                            // ADD
                            alu_inst_o = `alu_rl;
                        end else begin
                            // SUB
                            alu_inst_o = `alu_arl;
                        end
                    end
                    `inst_slt: alu_inst_o = `alu_cmp_less;
                    `inst_sltu: alu_inst_o = `alu_cmp_lessu;
                    default: alu_inst_o = `alu_no;
                endcase
            end
            `inst_i: begin
                r_reg_addr_1_o = rs1;
                imm_data_o = $signed(imm_i);
                w_reg_addr_o = rd;
                data_type_o = `datatype_word;
                case (func3)
                    `inst_addi: alu_inst_o = `alu_add;
                    `inst_xori: alu_inst_o = `alu_xor;
                    `inst_ori: alu_inst_o = `alu_or;
                    `inst_andi: alu_inst_o = `alu_and;
                    `inst_slli: alu_inst_o = `alu_ll;
                    `inst_srli_srai: begin
                        if (imm_i[11: 5] == 7'h00) begin
                            // ADD
                            alu_inst_o = `alu_rl;
                        end else begin
                            // SUB
                            alu_inst_o = `alu_arl;
                        end
                    end
                    `inst_slti: alu_inst_o = `alu_cmp_less;
                    `inst_sltiu: alu_inst_o = `alu_cmp_lessu;
                    default: alu_inst_o = `alu_no;
                endcase
            end
            `inst_b: begin
                r_reg_addr_1_o = rs1;
                r_reg_addr_2_o = rs2;
                imm_data_o = $signed(imm_b);
                case (func3)
                    `inst_beq: alu_inst_o = `alu_cmp_eq;
                    `inst_bne: alu_inst_o = `alu_cmp_neq;
                    `inst_blt: alu_inst_o = `alu_cmp_less;
                    `inst_bge: alu_inst_o = `alu_cmp_more_eq;
                    `inst_bltu: alu_inst_o = `alu_cmp_lessu;
                    `inst_bgeu: alu_inst_o = `alu_cmp_more_equ;
                    default: alu_inst_o = `alu_no;
                endcase
            end
            `inst_l: begin
                r_reg_addr_1_o = rs1;
                imm_data_o = $signed(imm_l);
                w_reg_addr_o = rd;
                alu_inst_o = `alu_add;
                case (func3)
                    `inst_lb: data_type_o = `datatype_byte;
                    `inst_lh: data_type_o = `datatype_half;
                    `inst_lw: data_type_o = `datatype_word;
                    `inst_lbu: data_type_o = `datatype_ubyte;
                    `inst_lhu: data_type_o = `datatype_uhalf;
                    default: data_type_o = `datatype_no;
                endcase
            end
            `inst_s: begin
                r_reg_addr_1_o = rs1;
                r_reg_addr_2_o = rs2;
                imm_data_o = $signed(imm_s);
                alu_inst_o = `alu_add;
                case (func3)
                    `inst_sb: data_type_o = `datatype_byte;
                    `inst_sh: data_type_o = `datatype_half;
                    `inst_sw: data_type_o = `datatype_word;
                    default: data_type_o = `datatype_no;
                endcase
            end
            `inst_jal: begin
                imm_data_o = $signed(imm_j);
                w_reg_addr_o = rd;
                alu_inst_o = `alu_add;
            end
            `inst_jalr: begin
                imm_data_o = $signed(imm_i);
                r_reg_addr_1_o = rs1;
                w_reg_addr_o = rd;
                alu_inst_o = `alu_add;
            end
            `inst_lui: begin
                alu_inst_o = `alu_add;
                w_reg_addr_o = rd;
                imm_data_o = $signed(imm_u);
            end
            `inst_auipc: begin
                alu_inst_o = `alu_add;
                w_reg_addr_o = rd;
                imm_data_o = $signed(imm_u);
            end
            `inst_csr: begin
                w_reg_addr_o = rd;
                r_csr_addr_o = csr;
                w_csr_addr_o = csr;
                if (func3[2]) begin
                    imm_data_o = $unsigned(rs1);
                end else begin
                    r_reg_addr_1_o = rs1;
                end
                case (func3) 
                    `inst_csrrw: alu_inst_o = `alu_add;
                    `inst_csrrs: alu_inst_o = `alu_or;
                    `inst_csrrc: alu_inst_o = `alu_and;
                    `inst_csrrwi: alu_inst_o = `alu_add;
                    `inst_csrrsi: alu_inst_o = `alu_or;
                    `inst_csrrci: alu_inst_o = `alu_and;
                    default: begin
                        
                    end
                endcase
            end
            default: begin
                
            end 
        endcase

    end

endmodule
