module memory (
    input wire          clka,
    input wire          ena,
    input wire          wea,
    input wire [10: 0]   addra,
    input wire [7: 0]  dina,
    input wire          clkb,
    input wire          rstb,
    input wire          enb,
    input wire [10: 0]   addrb,
    output reg [7: 0]  doutb
);
    
    reg [7: 0] ram [511: 0];
    integer init_i = 0;
    initial begin
        for (init_i = 0; init_i <= 511; init_i = init_i + 1) begin
            ram[init_i] = 0;
        end
    end
    
    always @(posedge clka) begin
        if (ena && wea) begin
            ram[addra] <= dina;
        end
    end

    always @(posedge clkb) begin
        if (rstb) begin
            doutb <= 0;
        end else begin
            if (enb) begin
                if (ena && wea && addra == addrb) begin
                    doutb <= dina;
                end else begin
                    doutb <= ram[addrb];
                end
            end else begin
                doutb <= 0;
            end
        end
    end

endmodule