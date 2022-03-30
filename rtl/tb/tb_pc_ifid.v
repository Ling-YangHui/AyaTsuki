//~ `New testbench
`timescale  1ns / 1ps
`include "rtl/cache/pc_ifid.v"

module tb_pc_ifid;

// pc_ifid Parameters
parameter PERIOD  = 10;

// pc_ifid Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg [7:0] inst_rom [512:0];
reg jump_flag_i = 0;
reg [`inst_addr_bus] jump_addr = 0;
reg [`hold_ctrl_bus] hold_i = 0;


// pc_ifid Outputs
wire [`inst_addr_bus] inst_addr_o;
reg [`inst_bus] inst_i;

always @(*) begin
    inst_i = {inst_rom[inst_addr_o], inst_rom[inst_addr_o+1], inst_rom[inst_addr_o+2], inst_rom[inst_addr_o+3]};
end

initial
begin
    $readmemb("rom/rom.txt", inst_rom);
    forever #(PERIOD/2)  begin 
        clk=~clk;
    end
end

always @(negedge clk) begin
    #1;
    $display("\n");
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
    repeat(1) @(negedge clk);

    hold_i = {`hold_flush, {3{`hold_wait}}};
    $display("hold_wait");
    repeat(2) @(negedge clk);

    $display("hold_no");
    hold_i = {4{`hold_no}};
    repeat(1) @(negedge clk);

    $display("hold_flush_jump\n");
    hold_i = {`hold_no, {3{`hold_flush}}};
    jump_flag_i = `jump_enable;
    jump_addr = 32'h00000100;
    repeat(1) @(negedge clk);

    $display("hold_no");
    hold_i = {4{`hold_no}};
    jump_flag_i = `jump_disable;
    repeat(10) @(negedge clk);
    $finish;
end

pc_ifid  u_pc_ifid (
    .clk                     ( clk     ),
    .rst_n                   ( rst_n   ),
    .inst_i (inst_i),
    .inst_addr_o(inst_addr_o),
    .jump_flag_i(jump_flag_i),
    .jump_addr_i(jump_addr),
    .hold_i(hold_i)
);

initial
begin
    $dumpfile("./release/tb_pc_ifid.vcd");
    $dumpvars(0, tb_pc_ifid);
end

endmodule