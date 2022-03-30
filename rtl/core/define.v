/**
* Author: YangHui
* Date: 20220328
* File: define.v
*/
`ifndef __ISE__
`include "rtl/core/global_conf.v"
`endif

// Global utils
`ifndef __ISE__
`include "rtl/utils/pipe_reg_s.v"
`endif


// Bus line width
`define inst_bus 31:0
`define inst_bus_width 32

`define inst_addr_bus 31:0
`define inst_addr_bus_width 32

`define data_bus 31:0
`define data_bus_width 32

`define hold_ctrl_bus 7:0
`define holdpip_bus 1:0
`define holdpip_bus_width 2

`define reg_addr_bus 4:0
`define reg_addr_bus_width 5
`define reg_num 32

`define reg_data_bus 31:0
`define reg_data_bus_width 32

`define mem_data_bus 31:0
`define mem_data_bus_width 32

`define mem_addr_bus 31:0
`define mem_addr_bus_width 32

`define csr_addr_bus 31:0
`define csr_addr_bus_width 32

`define csr_data_bus 31:0
`define csr_data_bus_width 32

`define imm_data_bus 31:0
`define imm_data_bus_width 32

`define alu_inst_bus 3:0
`define alu_inst_bus_width 4

`define opcode_bus  6:0
`define opcode_bus_width 7

`define alu_inst_src_bus 2:0
`define alu_inst_src_bus_width 3

`define data_type_bus 2:0
`define data_type_bus_width 3

// Default data
`define pc_reset 32'b0

// Enable flag
`define rst_enable 1'b0
`define rst_disable 1'b1

`define jump_enable 1'b1
`define jump_disable 1'b0

`define jtag_rst_enable 1'b1
`define jtag_rst_disable 1'b0

`define write_enable 1'b1
`define write_disable 1'b0

`define read_enable 1'b1
`define read_disable 1'b0

`define write_reg_req_enable 1'b1
`define write_reg_req_disable 1'b0

`define mem_enable 1'b1
`define mem_disable 1'b0

`define req_enable 1'b1
`define req_disable 1'b0

`define csr_enable 1'b1
`define csr_disable 1'b0

// Mem
`define mem_write 1'b1
`define mem_read 1'b0

// Hold level
// This CPU has 2 level of pipeline stoping
// The level hold_flush will set the pipeline register to default value, which is used in condition of IRQ or Branch
// The level hold_wait will hold the register value, which is used in condition of BUS waiting or multi-clock inst
`define hold_no 2'b00
`define hold_flush 2'b01
`define hold_wait 2'b10

// Default
`define datatype_no 3'b000
`define reg_zero 5'b0
`define data_zero 32'b0
`define inst_nop 32'b0
`define mem_addr_zero 32'b0
`define csr_zero 32'b0
`define inst_addr_zero 32'b0

// Mirco Instructure
`define datatype_byte 3'b001
`define datatype_half 3'b010
`define datatype_word 3'b011
`define datatype_ubyte 3'b100
`define datatype_uhalf 3'b101

// ALU
`define alu_no 4'b0000
`define alu_add 4'b0001
`define alu_sub 4'b0010
`define alu_or 4'b0011
`define alu_and 4'b0100
`define alu_xor 4'b0101
`define alu_ll 4'b0110
`define alu_rl 4'b0111
`define alu_arl 4'b1000
`define alu_cmp_less 4'b1001
`define alu_cmp_lessu 4'b1010
`define alu_cmp_eq 4'b1011
`define alu_cmp_neq 4'b0000
`define alu_cmp_less_eq 4'b1100
`define alu_cmp_more 4'b1101
`define alu_cmp_more_eq 4'b1110
`define alu_cmp_more_equ 4'b1111

`define alu_src_1_no 3'b000
`define alu_src_1_reg 3'b001
`define alu_src_1_pc 3'b010
`define alu_src_1_csr 3'b011
`define alu_src_1_imm 3'b100

`define alu_src_2_no 3'b000
`define alu_src_2_reg 3'b001
`define alu_src_2_pc 3'b010
`define alu_src_2_csr 3'b011
`define alu_src_2_imm 3'b100

`define mem_byte 2'b01
`define mem_half 2'b10
`define mem_word 2'b11

// Instruction

// L Type
`define inst_l 7'b0000011
`define inst_lb 3'b000 // load byte
`define inst_lh 3'b001 // load half-word
`define inst_lw 3'b010 // load word
`define inst_lbu 3'b100 // load unsigned-byte
`define inst_lhu 3'b101 // load unsigned-half-word

// S Type
`define inst_s 7'b0100011
`define inst_sb 3'b000 // save byte
`define inst_sh 3'b001 // save half-word
`define inst_sw 3'b010 // save word

// I Type
`define inst_i 7'b0010011
`define inst_addi 3'b000
`define inst_xori 3'b100
`define inst_ori 3'b110
`define inst_andi 3'b111
`define inst_slli 3'b001
`define inst_srli_srai 3'b101
`define inst_slti 3'b010
`define inst_sltiu 3'b011
`define inst_srli_immu7 7'b0000000
`define inst_srai_immu7 7'b0100000

// R Type
`define inst_r 7'b0110011
`define inst_add_sub 3'b000
`define inst_xor 3'b100
`define inst_or 3'b110
`define inst_and 3'b111
`define inst_sll 3'b001
`define inst_srl_sra 3'b101
`define inst_slt 3'b010
`define inst_sltu 3'b011
`define inst_sra_f7 7'b01000000
`define inst_srl_f7 7'b00000000

// B Type
`define inst_b 7'b1100011
`define inst_beq 3'b000
`define inst_bne 3'b001
`define inst_blt 3'b100
`define inst_bge 3'b101
`define inst_bltu 3'b110
`define inst_bgeu 3'b111

// J Type
`define inst_jal 7'b1101111
`define inst_jalr 7'b1100111

// U Type
`define inst_lui 7'b0110111
`define inst_auipc 7'b0010111

// IE Type
`define inst_ie 7'b1110011
`define inst_ecall_imm 12'b0
`define inst_ebreak_imm 12'b1
