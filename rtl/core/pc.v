/**
* Author: YangHui
* Date: 20220328
* File: pc.v
*/

`ifndef __ISE__
`include "rtl/core/define.v"
`endif

`ifdef __ISE__
`include "define.v"
`endif

module pc (
    // clk & rst
    input wire                      clk,
    input wire                      rst_n,
    // jump
    input wire [`jump_cause_bus]    jump_cause_i,
    input wire [`inst_addr_bus]     jump_from_addr_i,
    input wire [`inst_addr_bus]     jump_to_addr_i,
    // stop
    input wire [`holdpip_bus]       hold_flag_i,
    // jtag_reset
    input wire                      jtag_reset_i,
    input wire [`inst_addr_bus]     inst_i,
    output wire [`inst_bus]         pc_o,
    output reg                      predict_to_jump_o,
    output wire [`inst_addr_bus]    now_pc_o
);

    // Start Counter
    // FIXME 
    // this is an 'edge' action, and the reset time will affect the function
    // the solution is to use another register instead of a wire
    // maybe we can use a register to hold the past pc value
    // if a jump (predict or from ex) happened, we can change the output addr to the predict value
    // and the next step the past pcvalue register = the output addr and the now pcvalue = output addr + 4
    // this will be a good solution, i think

    reg [`inst_addr_bus] pc_pre;
    reg [`inst_addr_bus] n_pc_pre;
    reg [`inst_addr_bus] n_inst_addr;
    assign now_pc_o = pc_pre;

    parameter predict_random = 3'b000;
    parameter predict_jump_light = 3'b001;
    parameter predict_jump_strong = 3'b010; 
    parameter predict_nojump_light = 3'b011;
    parameter predict_nojump_strong = 3'b100;  

    // PC With Branch Prediction
    // FSM: 5 Status
    // Status: random, jump_light, jump_strong, nojump_light, nojump_strong

    reg [`inst_addr_bus] pc_r;
    reg [`inst_addr_bus] n_pc_r;

    reg [3 * `inst_addr_bus_width - 1 : 0] predict_inst_addr;
    reg [3 * `inst_addr_bus_width - 1 : 0] n_predict_inst_addr;
    reg [3 * 3 - 1 : 0] predict_inst_result;
    reg [3 * 3 - 1 : 0] n_predict_inst_result;

    wire is_inst_b = inst_i[6:0] == `inst_b;
    wire signed [12:0] imm_b = {inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};

    wire [1:0] jump_addr_pred_cache_pointer;
    wire [1:0] inst_addr_pred_cache_pointer;

    // To Find the location of jump_memory in the PC Cache
    assign jump_addr_pred_cache_pointer = (
        ({2{~|(predict_inst_addr[`inst_addr_bus_width - 1 : 0] ^ jump_from_addr_i)}} & 2'b01) | 
        ({2{~|(predict_inst_addr[`inst_addr_bus_width * 2 - 1 : `inst_addr_bus_width] ^ jump_from_addr_i)}} & 2'b10) | 
        ({2{~|(predict_inst_addr[`inst_addr_bus_width * 3 - 1 : `inst_addr_bus_width * 2] ^ jump_from_addr_i)}} & 2'b11)
    );

    assign inst_addr_pred_cache_pointer = (
        ({2{~|(predict_inst_addr[`inst_addr_bus_width - 1 : 0] ^ pc_pre)}} & 2'b01) | 
        ({2{~|(predict_inst_addr[`inst_addr_bus_width * 2 - 1 : `inst_addr_bus_width] ^ pc_pre)}} & 2'b10) | 
        ({2{~|(predict_inst_addr[`inst_addr_bus_width * 3 - 1 : `inst_addr_bus_width * 2] ^ pc_pre)}} & 2'b11)
    );
    /*
    always @(posedge clk) begin
        // reset
        if (rst_n == `rst_enable || jtag_reset_i == `jtag_rst_enable) begin
            pc_r <= `pc_reset;
        end else begin
            if (jump_flag_i == `jump_enable) begin
                pc_r <= jump_addr_i;
            end else if (hold_flag_i == `hold_no) begin
                pc_r <= pc_r + `inst_addr_bus_width 'b100;
            end
        end
    end
    */

    always @(posedge clk) begin
        if (rst_n == `rst_enable || jtag_reset_i == `jtag_rst_enable) begin
            pc_r <= `pc_reset;
            predict_inst_addr <= {(3 * `inst_addr_bus_width){1'b1}};
            predict_inst_result <= {9{1'b1}};
            pc_pre <= `pc_reset;
        end else begin
            predict_inst_addr <= n_predict_inst_addr;
            predict_inst_result <= n_predict_inst_result;
            pc_r <= n_pc_r;
            pc_pre <= n_pc_pre;
        end
    end

    function [2:0] next_result;
        input [2:0] now_result;
        input [`jump_cause_bus] jump_cause;
        case (now_result)
            predict_jump_light: next_result = predict_nojump_strong;
            predict_jump_strong: next_result = predict_random;
            predict_nojump_light: next_result = predict_jump_strong;
            predict_nojump_strong: next_result = predict_random;
            predict_random: begin
                if (jump_cause == `jump_cause_predict_no_but_yes) begin
                    next_result = predict_jump_strong;
                end else if (jump_cause == `jump_cause_predict_yes_but_no) begin
                    next_result = predict_nojump_strong;
                end else begin
                    next_result = predict_random;
                end
            end
            default: next_result = predict_random;
        endcase
    endfunction

    function inst_jump_ornot;
        input [2:0] now_result;
        input random_jump;
        case (now_result)
            predict_jump_light, predict_jump_strong: inst_jump_ornot = 1'b1;
            predict_nojump_light, predict_nojump_strong: inst_jump_ornot = 1'b0;
            predict_random: begin
                if (random_jump) begin
                    inst_jump_ornot = 1'b1;
                end else begin
                    inst_jump_ornot = 1'b0;
                end
            end
            default: inst_jump_ornot = 1'b0;
        endcase
    endfunction

    always @(*) begin
        n_predict_inst_addr = predict_inst_addr;
        n_predict_inst_result = predict_inst_result;

        n_pc_r = pc_r + `inst_addr_bus_width 'b100;
        n_pc_pre = pc_r;
        n_inst_addr = pc_r;

        predict_to_jump_o = `predict_jump_disable;

        // This branch is used for jump case
        if (jump_cause_i != `jump_cause_no) begin
            n_inst_addr = jump_to_addr_i;   
            n_pc_r = n_inst_addr + `inst_addr_bus_width 'b100;
            n_pc_pre = n_inst_addr;
            
            case (jump_cause_i)
                `jump_cause_predict_no_but_yes, `jump_cause_predict_yes_but_no: begin
                    if (jump_addr_pred_cache_pointer == 2'b01) begin
                        n_predict_inst_result[2:0] = next_result(predict_inst_result[2:0], jump_cause_i);
                    end else if (jump_addr_pred_cache_pointer == 2'b10) begin
                        n_predict_inst_result[5:3] = next_result(predict_inst_result[5:3], jump_cause_i);
                    end else if (jump_addr_pred_cache_pointer == 2'b11) begin
                        n_predict_inst_result[8:6] = next_result(predict_inst_result[8:6], jump_cause_i);
                    end
                end
                `jump_cause_nocondition: begin
                    
                end
                `jump_cause_interrupt: begin
                    n_predict_inst_addr = {(3 * `inst_addr_bus_width){1'b1}};
                    n_predict_inst_result = {9{1'b1}};
                end
                `jump_cause_exception: begin
                    n_predict_inst_addr = {(3 * `inst_addr_bus_width){1'b1}};
                    n_predict_inst_result = {9{1'b1}};
                end
                default: begin
                    
                end
            endcase

        end else if (hold_flag_i != `hold_no) begin
            n_pc_r = pc_r;
            n_pc_pre = pc_pre;
            n_inst_addr = pc_pre;
        end else begin
            if (is_inst_b) begin
                if (
                    (inst_addr_pred_cache_pointer==2'b01&&inst_jump_ornot(predict_inst_result[2:0], pc_pre[2])) 
                    ||(inst_addr_pred_cache_pointer==2'b10&&inst_jump_ornot(predict_inst_result[5:3], pc_pre[2])) 
                    ||(inst_addr_pred_cache_pointer==2'b11&&inst_jump_ornot(predict_inst_result[8:6], pc_pre[2])) 
                ) begin
                    n_inst_addr = $signed(pc_pre) + imm_b;
                    n_pc_r = n_inst_addr + `inst_addr_bus_width 'b100;
                    n_pc_pre = n_inst_addr;

                    predict_to_jump_o = `predict_jump_enable;

                end else if (inst_addr_pred_cache_pointer == 2'b00) begin          
                    n_predict_inst_addr = {pc_r, predict_inst_addr[3 * `inst_addr_bus_width - 1 : `inst_addr_bus_width]};
                    if (pc_r[2]) begin
                        n_inst_addr = $signed(pc_pre) + imm_b;
                        n_pc_r = n_inst_addr + `inst_addr_bus_width 'b100;
                        n_pc_pre = n_inst_addr;

                        n_predict_inst_result = {predict_jump_light, predict_inst_result[8: 3]};
                        predict_to_jump_o = `predict_jump_enable;                    
                    end else begin
                        n_pc_r = pc_r + `inst_addr_bus_width 'b100;
                        n_pc_pre = pc_r;
                        n_inst_addr = pc_r;

                        n_predict_inst_result = {predict_nojump_light, predict_inst_result[8: 3]};
                    end
                end
            end
        end
    end

    assign pc_o = n_inst_addr;

    `ifdef __DEBUG__
    always @(negedge clk) begin
        $display("------------pc------------");
        $display("pc: 0x%8x", pc_r);
        /*
        if (rst_n == `rst_disable && jtag_reset_i == `jtag_rst_disable) begin
            if (jump_addr_i === {`inst_bus_width{1'bx}}) begin
                $display("FATAL ERROR-> pc: jump_addr_i is x");
            end else if (jump_flag_i === 1'bx) begin
                $display("FATAL ERROR-> pc: jump_flag_i is x");
            end else if (jtag_reset_i === 1'bx) begin 
                $display("FATAL ERROR-> pc: jtag_reset_i is x");
            end
        end
        */
    end
    `endif
    
endmodule
