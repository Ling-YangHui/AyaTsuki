//~ `New testbench
`timescale  1ns / 1ps
`include "rtl/core/ayatsuki_core.v"

module tb_core;

// pc_ifid Parameters
parameter PERIOD  = 10;

// pc_ifid Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg [7:0] inst_rom [2048:0];
reg [7:0] data_ram [2048:0];
reg jump_flag_i = 0;
reg [`inst_addr_bus] jump_addr = 0;
reg [`hold_ctrl_bus] hold_i = 0;


// pc_ifid Outputs
wire [`inst_addr_bus] inst_addr_o;
reg [`inst_bus] inst_i;

always @(*) begin
    inst_i = {inst_rom[inst_addr_o], inst_rom[inst_addr_o+1], inst_rom[inst_addr_o+2], inst_rom[inst_addr_o+3]};
end

integer i;
initial
begin
    for (i = 0;i < 2048; i ++) begin
        inst_rom[i] = 8'b0;
        data_ram[i] = 8'b0;
    end
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
    repeat(50) @(negedge clk);
    $finish;
end

ayatsuki_core core(
    .clk (clk),
    .rst_n (rst_n),
    .inst_i (inst_i),
    .inst_addr_o (inst_addr_o)
);

initial
begin
    $dumpfile("./release/tb_core.vcd");
    $dumpvars(0, tb_core);
end

endmodule