`timescale  1ns / 1ps

module tb_soc;

//~ `New testbench

// ayatsuki_soc Parameters
parameter PERIOD = 20;


// ayatsuki_soc Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;

// ayatsuki_soc Outputs


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2 * 6) rst_n  =  1;
end

ayatsuki_soc  u_ayatsuki_soc (
    .clk                     ( clk              ),
    .rst_n                   ( rst_n            )
);

initial
begin
    repeat(6 * 500) @(negedge clk); 
    $finish;
end

endmodule
    