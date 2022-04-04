//~ `New testbench
`timescale  1ns / 1ps
`ifndef __ISE__
`include "rtl/core/ayatsuki_core.v"
`endif
`ifdef __ISE__
`include "../core/define.v"
`endif

module tb_core;

// pc_ifid Parameters
parameter PERIOD  = 40;

// pc_ifid Inputs
reg clk = 0 ;
reg rst_n = 0 ;
reg [7:0] inst_rom [2047:0];
reg [7:0] data_ram [2047:0];

wire [`inst_addr_bus] inst_addr_o;
reg [`inst_bus] inst_i = `inst_nop;
wire mem_w_enable;
wire mem_r_enable;
wire mem_enable;
wire [`mem_addr_bus] mem_w_addr;
wire [`mem_addr_bus] mem_r_addr;
wire [`data_bus] mem_w_data;
reg [`data_bus] mem_r_data = `data_zero;

always @(posedge clk) begin
    if (~rst_n) begin
        inst_i <= `inst_nop;
    end else begin
        if (inst_addr_o <= 2044)
            inst_i <= {inst_rom[inst_addr_o], inst_rom[inst_addr_o+1], inst_rom[inst_addr_o+2], inst_rom[inst_addr_o+3]};
        else 
            inst_i <= `inst_nop;    
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        mem_r_data <= `data_zero;
    end else begin
        if (mem_r_addr <= 2044) 
            mem_r_data <= {data_ram[mem_r_addr], data_ram[mem_r_addr+1], data_ram[mem_r_addr+2], data_ram[mem_r_addr+3]};
        else
            mem_r_data <= `data_zero;
    end
    
end

always @(posedge clk) begin
    if (mem_w_addr <= 2044 && mem_enable && mem_w_enable) begin
        data_ram[mem_w_addr] <= mem_w_data[31:24];
        data_ram[mem_w_addr+1] <= mem_w_data[23:16];
        data_ram[mem_w_addr+2] <= mem_w_data[15:8];
        data_ram[mem_w_addr+3] <= mem_w_data[7:0];
    end
end

ayatsuki_core core(
    .clk (clk),
    .rst_n (rst_n),
    .inst_i (inst_i),
    .inst_addr_o (inst_addr_o),

    .mem_w_enable_o (mem_w_enable),
    .mem_r_enable_o (mem_r_enable),
    .mem_enable_o (mem_enable),
    .mem_w_addr_o (mem_w_addr),
    .mem_r_addr_o (mem_r_addr),
    .mem_data_i (mem_r_data),
    .mem_data_o (mem_w_data)
);

integer i;
initial
begin
    for (i = 0;i < 2048; i = i + 1) begin
        inst_rom[i] = 8'b0;
        data_ram[i] = 8'b0;
    end
    $readmemb("D:/programming/verilog/AyaTsuki_RISC_V/rom/rom.txt", inst_rom);
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
    repeat(150) @(negedge clk);
    $display("0x%x 0x%x 0x%x 0x%x", data_ram[0], data_ram[1], data_ram[2], data_ram[3]);
    $finish;
end

initial
begin
    $dumpfile("./release/tb_core.vcd");
    $dumpvars(0, tb_core);
end

endmodule