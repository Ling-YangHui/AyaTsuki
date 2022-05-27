`timescale  1ns / 100ps
`include "rtl/soc/ayatsuki_soc.v"

module tb_soc;

//~ `New testbench

// ayatsuki_soc Parameters
parameter PERIOD = 20;


// ayatsuki_soc Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   rx = 1;

// ayatsuki_soc Outputs
initial
begin
    $dumpfile("./release/tb_soc.vcd");
    $dumpvars(0, tb_soc);
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2 * 5) rst_n  =  1;
end

ayatsuki_soc  u_ayatsuki_soc (
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            ),
    .uart_tx                 ( tx               ),
    .uart_rx                 ( rx               )
);

initial
begin
    repeat(6 * 200) @(negedge clk);
    
    rx = 0;
    #8680;
    rx = 1;
    #8680;
    rx = 0;
    #8680;
    rx = 1;
    #8680;
    rx = 0;
    #8680;
    rx = 1;
    #8680;
    rx = 0;
    #8680;
    rx = 1;
    #8680;
    rx = 0;
    #8680;
    rx = 1;

    repeat(6 * 1500) @(negedge clk);
    repeat(6 * 500) @(negedge clk);
    $finish;
end

endmodule
    