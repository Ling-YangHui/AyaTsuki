`include "rtl/core/alu.v"

module tb_alu;

reg [`alu_inst_bus] alu_inst_i = 0;
reg signed [`data_bus] alu_src1_i = 0;
reg signed [11: 0] alu_src2 = -1;
wire [`data_bus] alu_result_o;
reg signed [`data_bus] alu_src2_i;

alu u_alu(
    .alu_inst_i(alu_inst_i),
    .alu_src1_i(alu_src1_i),
    .alu_src2_i(alu_src2_i),        
    .alu_result_o(alu_result_o)
);
    

initial begin
    #1;
    alu_inst_i = `alu_cmp_lessu;
    alu_src1_i = 32'h8FFFFF00;
    alu_src2_i = alu_src2;
    #1;
end

initial begin
    $dumpfile("./release/tb_alu.vcd");
    $dumpvars(0, tb_alu); 
end

endmodule