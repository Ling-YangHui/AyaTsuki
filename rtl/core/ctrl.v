/**
* Author: YangHui
* Date: 20220329
* File: ctrl.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif 

`ifdef __ISE__
`include "define.v"
`endif

module ctrl (
    input wire                      clk,
    input wire                      rst_n,

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
    // @ Deprecated
    input wire                      mem_wb_wr_wait_req_i,

    // when a clint_irq_flush happened, the cpu has to flush the pc(stop) if-id id-ex 
    // and let the ex_memwb continue to run in order to finish the last step
    input wire [`irq_bus]           irq_flush_req_addr_i,    
    output reg                      irq_acknowledge_o,
    // I DONT KNOW
    input wire                      jtag_halt_wait_req_i,
    
    output wire [`hold_ctrl_bus]    hold_ctrl_o,
    output reg [`jump_cause_bus]    jump_cause_o,
    output reg [`inst_addr_bus]     jump_from_addr_o,
    output reg [`inst_addr_bus]     jump_to_addr_o,

    input wire [`csr_data_bus]      r_mstatus_i,
    input wire [`csr_data_bus]      r_mepc_i,
    input wire [`csr_data_bus]      r_mtvec_i,
    output reg [`csr_data_bus]      w_mstatus_o,
    output reg [`csr_data_bus]      w_mepc_o,
    output reg                      w_mstatus_enable
);

    reg [`holdpip_bus] hold_pc;
    reg [`holdpip_bus] hold_if_id;
    reg [`holdpip_bus] hold_id_ex;
    reg [`holdpip_bus] hold_ex_mem;
    reg [`holdpip_bus] hold_mem_wb;

    reg ex_interrupt_req;
    reg next_ex_interrupt_req;
    reg extern_irq;
    reg next_extern_irq;
    reg [`irq_bus] extern_irq_addr;
    reg [`irq_bus] next_extern_irq_addr;

    always @(posedge clk) begin
        if (rst_n == `rst_enable) begin
            ex_interrupt_req <= 1'b0;
            extern_irq <= 1'b0;
            extern_irq_addr <= `irq_bus_width'b0;
        end else begin
            ex_interrupt_req <= next_ex_interrupt_req;
            extern_irq <= next_extern_irq;
            extern_irq_addr <= next_extern_irq_addr;
        end
    end

    assign hold_ctrl_o = {hold_mem_wb, hold_ex_mem, hold_id_ex, hold_if_id, hold_pc};

    // because the hold_req has pri, so we has to use if-else structure
    always @(*) begin
        jump_to_addr_o = `inst_addr_zero;
        jump_from_addr_o = `inst_addr_zero;
        jump_cause_o = `jump_cause_no;
        w_mstatus_enable = `write_disable;
        w_mstatus_o = r_mstatus_i;
        irq_acknowledge_o = `irq_nak;
        w_mepc_o = r_mepc_i;
        next_ex_interrupt_req = 1'b0;
        next_extern_irq = 1'b0;
        next_extern_irq_addr = `inst_addr_bus_width'b0;
        hold_mem_wb = `hold_no;

        // HOLD AND WAIT
        if (ex_multi_clock_wait_req_i == `req_enable) begin
            hold_pc = `hold_wait;
            hold_if_id = `hold_wait;
            hold_id_ex = `hold_wait;
            hold_ex_mem = `hold_flush;
            hold_mem_wb = `hold_no;
        end else if (ex_jump_cause_i == `jump_cause_interrupt || 
                    ex_interrupt_req ) begin 
            if (r_mstatus_i[31]) begin
                if (r_mstatus_i[`irq_bus] != 0)
                    next_ex_interrupt_req = 1'b1;
            end else begin
                next_ex_interrupt_req = 1'b0;

                jump_from_addr_o = ex_jump_from_addr_i;
                jump_to_addr_o = r_mtvec_i;
                jump_cause_o = ex_jump_cause_i;

                hold_pc = `hold_wait;
                hold_if_id = `hold_flush;
                hold_id_ex = `hold_flush;
                hold_ex_mem = `hold_no;
                hold_mem_wb = `hold_no;

                w_mstatus_o[31] = 1'b1;
                w_mepc_o = ex_jump_from_addr_i + 4;
                w_mstatus_enable = `write_enable;
                irq_acknowledge_o = `irq_ack;
            end
        end else if (ex_jump_cause_i == `jump_cause_exit_interrupt) begin
            if (r_mstatus_i[31]) begin
                w_mstatus_o[31] = 1'b0;
                w_mstatus_enable = `write_enable;

                next_ex_interrupt_req = 1'b0;

                jump_from_addr_o = ex_jump_from_addr_i;
                jump_to_addr_o = r_mepc_i;
                jump_cause_o = `jump_cause_exit_interrupt;

                hold_pc = `hold_wait;
                hold_if_id = `hold_flush;
                hold_id_ex = `hold_flush;
                hold_ex_mem = `hold_no;
                hold_mem_wb = `hold_no;
            end else begin
                w_mstatus_o[`irq_bus] = `irq_bus_width'hFF;
                w_mstatus_o[31] = 1'b1;

                next_ex_interrupt_req = 1'b0;

                jump_from_addr_o = ex_jump_from_addr_i;
                jump_to_addr_o = `exception_addr;
                jump_cause_o = `jump_cause_exception;

                hold_pc = `hold_wait;
                hold_if_id = `hold_flush;
                hold_id_ex = `hold_flush;
                hold_ex_mem = `hold_flush;
                hold_mem_wb = `hold_no;
            end
            

        end else if (irq_flush_req_addr_i || next_extern_irq) begin
            if (r_mstatus_i[31]) begin
                if (r_mstatus_i[`irq_bus] != (extern_irq) ? extern_irq_addr : irq_flush_req_addr_i)
                    next_extern_irq = 1'b1;
            end else begin
                next_extern_irq = 1'b0;

                jump_from_addr_o = ex_jump_from_addr_i;
                jump_to_addr_o = r_mtvec_i;
                jump_cause_o = `jump_cause_interrupt;

                hold_pc = `hold_wait;
                hold_if_id = `hold_flush;
                hold_id_ex = `hold_flush;
                hold_ex_mem = `hold_flush;
                hold_mem_wb = `hold_no;

                w_mstatus_o[31] = 1'b1;
                w_mstatus_o[`irq_bus] = (extern_irq) ? extern_irq_addr : irq_flush_req_addr_i;
                w_mstatus_enable = `write_enable;
                w_mepc_o = ex_jump_from_addr_i;
                irq_acknowledge_o = `irq_ack;
            end
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
            hold_ex_mem = `hold_no; // because the next step may has some operation to write register
            hold_mem_wb = `hold_no;
        end else if (mem_wb_wr_wait_req_i == `req_enable) begin
            hold_pc = `hold_wait;
            hold_if_id = `hold_wait;
            hold_id_ex = `hold_flush;
            hold_ex_mem = `hold_no;
            hold_mem_wb = `hold_no;
        end else begin
            hold_pc = `hold_no;
            hold_if_id = `hold_no;
            hold_id_ex = `hold_no;
            hold_ex_mem = `hold_no;
            hold_mem_wb = `hold_no;
        end
    end
    
endmodule
