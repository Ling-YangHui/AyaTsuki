`ifndef __ISE__
`include "rtl/soc/memory.v"
`endif

module ram (
    input wire              clk,
    
    input wire              ena,
    input wire              wea,
    input wire [12: 0]      addra,
    input wire [31: 0]      dina,
    
    input wire              rstb,
    input wire              enb,
    input wire [12: 0]      addrb,
    output reg [31: 0]      doutb
);

    wire [10: 0] addra_3 = addra >> 2;
    wire [10: 0] addra_2 = (addra + 1) >> 2;
    wire [10: 0] addra_1 = (addra + 2) >> 2;
    wire [10: 0] addra_0 = (addra + 3) >> 2;

    wire [10: 0] addrb_3 = addrb >> 2;
    wire [10: 0] addrb_2 = (addrb + 1) >> 2;
    wire [10: 0] addrb_1 = (addrb + 2) >> 2;
    wire [10: 0] addrb_0 = (addrb + 3) >> 2;

    reg [7: 0] dina_0;
    reg [7: 0] dina_1;
    reg [7: 0] dina_2;
    reg [7: 0] dina_3;
    always @(*) begin
        case (addra[1: 0])
            0: begin
                dina_0 = dina[7: 0];
                dina_1 = dina[15: 8];
                dina_2 = dina[23: 16];
                dina_3 = dina[31: 24];
            end
            1: begin
                dina_1 = dina[7: 0];
                dina_2 = dina[15: 8];
                dina_3 = dina[23: 16];
                dina_0 = dina[31: 24];
            end
            2: begin
                dina_2 = dina[7: 0];
                dina_3 = dina[15: 8];
                dina_0 = dina[23: 16];
                dina_1 = dina[31: 24];
            end
            3: begin
                dina_3 = dina[7: 0];
                dina_0 = dina[15: 8];
                dina_1 = dina[23: 16];
                dina_2 = dina[31: 24];
            end
        endcase
    end

    wire [7: 0] doutb_0;
    wire [7: 0] doutb_1;
    wire [7: 0] doutb_2;
    wire [7: 0] doutb_3;
    always @(*) begin
        case (addrb[1: 0])
            0: doutb = {doutb_3, doutb_2, doutb_1, doutb_0};
            1: doutb = {doutb_0, doutb_3, doutb_2, doutb_1};
            2: doutb = {doutb_1, doutb_0, doutb_3, doutb_2};
            3: doutb = {doutb_2, doutb_1, doutb_0, doutb_3};
        endcase
    end


    memory u_memory_0(
    	.clka  (clk             ),
        .ena   (ena             ),
        .wea   (wea             ),
        .addra (addra_0         ),
        .dina  (dina_0          ),
        .clkb  (clk             ),
        .rstb  (rstb            ),
        .enb   (enb             ),
        .addrb (addrb_0         ),
        .doutb (doutb_0         )
    );

     memory u_memory_1(
    	.clka  (clk             ),
        .ena   (ena             ),
        .wea   (wea             ),
        .addra (addra_1         ),
        .dina  (dina_1          ),
        .clkb  (clk             ),
        .rstb  (rstb            ),
        .enb   (enb             ),
        .addrb (addrb_1         ),
        .doutb (doutb_1         )
    );

     memory u_memory_2(
    	.clka  (clk             ),
        .ena   (ena             ),
        .wea   (wea             ),
        .addra (addra_2         ),
        .dina  (dina_2          ),
        .clkb  (clk             ),
        .rstb  (rstb            ),
        .enb   (enb             ),
        .addrb (addrb_2         ),
        .doutb (doutb_2         )
    );

     memory u_memory_3(
    	.clka  (clk             ),
        .ena   (ena             ),
        .wea   (wea             ),
        .addra (addra_3         ),
        .dina  (dina_3          ),
        .clkb  (clk             ),
        .rstb  (rstb            ),
        .enb   (enb             ),
        .addrb (addrb_3         ),
        .doutb (doutb_3         )
    );
    
    
endmodule