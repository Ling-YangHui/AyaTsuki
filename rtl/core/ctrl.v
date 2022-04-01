/**
* Author: YangHui
* Date: 20220329
* File: ctrl.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

module ctrl (
    // when an inst need multi-clock to finish, we need to let pc if_id id_ex to wait
    // but the ex_mem can flush because the read & write will not impact the multi_clock inst
    input wire                      ex_multi_clock_wait_req_i,
    
    // when a jump inst is executed, ex send a req to ctrl
    // because the pipeline has to jump, so all of the data is wrong, flush if_id id_ex
    // but ex_mem has to continue because the next step is write some callback register
    input wire [`jump_cause_bus]    ex_jump_cause_i,
    input wire [`inst_addr_bus]     ex_jump_from_addr_i,
    input wire [`inst_addr_bus]     ex_jump_to_addr_i,

    // when a mem_wr block happened, mem_wb send a req to wait
    // because this is the last step, so the whole pipeline has to wait
    input wire                      mem_wb_wr_wait_req_i,

    // I DONT KNOW
    input wire                      clint_irq_flush_req_i,
    
    // I DONT KNOW
    input wire                      jtag_halt_wait_req_i,
    
    output wire [`hold_ctrl_bus]    hold_ctrl_o,
    output reg [`jump_cause_bus]    jump_cause_o,
    output reg [`inst_addr_bus]     jump_from_addr_o,
    output reg [`inst_addr_bus]     jump_to_addr_o
);

    reg [`holdpip_bus] hold_pc;
    reg [`holdpip_bus] hold_if_id;
    reg [`holdpip_bus] hold_id_ex;
    reg [`holdpip_bus] hold_ex_memwb;


    assign hold_ctrl_o = {hold_ex_memwb, hold_id_ex, hold_if_id, hold_pc};

    // because the hold_req has pri, so we has to use if-else structure
    always @(*) begin
        jump_to_addr_o = `inst_addr_zero;
        jump_from_addr_o = `inst_addr_zero;
        jump_cause_o = `jump_cause_no;

        // HOLD AND WAIT
        if (mem_wb_wr_wait_req_i == `req_enable) begin
            hold_pc = `hold_wait;
            hold_if_id = `hold_wait;
            hold_id_ex = `hold_wait;
            hold_ex_memwb = `hold_wait;
        end else if (ex_multi_clock_wait_req_i == `req_enable) begin
            hold_pc = `hold_wait;
            hold_if_id = `hold_wait;
            hold_id_ex = `hold_wait;
            hold_ex_memwb = `hold_flush;
            
        // JUMP AND FLUSH
        // Jump for normal reason
        end else if (ex_jump_cause_i == `jump_cause_predict_yes_but_no ||
                    ex_jump_cause_i == `jump_cause_predict_no_but_yes ||
                    ex_jump_cause_i == `jump_cause_nocondition ) begin
            
            jump_from_addr_o = ex_jump_from_addr_i;
            jump_to_addr_o = ex_jump_to_addr_i;
            jump_cause_o = ex_jump_cause_i;

            hold_pc = `hold_wait;
            hold_if_id = `hold_flush;
            hold_id_ex = `hold_flush;
            hold_ex_memwb = `hold_no; // because the next step may has some operation to write register
        /*
        end else if (clint_irq_flush_req_i == `req_enable) begin 
            
        end else if (jtag_halt_wait_req_i == `req_enable) begin
        */
        end else begin
            hold_pc = `hold_no;
            hold_if_id = `hold_no;
            hold_id_ex = `hold_no;
            hold_ex_memwb = `hold_no;
        end
    end
    
endmodule