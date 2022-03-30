//~ `New testbench
`timescale  1ns / 1ps
`include "rtl/core/pc.v"

module tb_pc;

// pc Parameters
parameter PERIOD  = 10;


// pc Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   jump_flag_i                          = 0 ;
reg   [`inst_addr_bus] jump_addr_i         = 0 ;
reg   [`holdpip_bus]   hold_flag_i         = 0 ;
reg   jtag_reset_i                         = 0 ;

// pc Outputs
wire  [`inst_bus]     pc_o                 ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
    repeat(10) @(negedge clk);
    hold_flag_i = `hold_wait;
    repeat(2) @(negedge clk);
    hold_flag_i = `hold_no;
    repeat(10) @(negedge clk);
    hold_flag_i = `hold_flush;
    jump_flag_i = `jump_enable;
    jump_addr_i = 32'h02000000;
    repeat(1) @(negedge clk);
    hold_flag_i = `hold_no;
    jump_flag_i = `jump_disable;
    repeat(10) @(negedge clk);
    $finish;
end

pc  u_pc (
    .clk                            ( clk                            ),
    .rst_n                          ( rst_n                          ),
    .jump_flag_i                    ( jump_flag_i                    ),
    .jump_addr_i                    ( jump_addr_i                    ),
    .hold_flag_i                    ( hold_flag_i                    ),
    .jtag_reset_i                   ( jtag_reset_i                   ),

    .pc_o                           ( pc_o                           )
);

initial
begin
    $dumpfile("./release/tb_pc.vcd");
    $dumpvars(0, tb_pc);
end

endmodule