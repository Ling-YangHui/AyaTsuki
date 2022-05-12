module rom (
    input wire          clka,
    input wire          rsta,
    input wire [8: 0]   addra,
    output reg [31: 0]  douta
);

    reg [31: 0] rom_r [511: 0];
    initial begin
        $readmemb("D:/programming/verilog/AyaTsuki_RISC_V/rom/32rom.txt", rom_r);
    end

    always @(posedge clka) begin
        if (rsta) begin
            douta <= 32'h13;
        end else begin
            douta <= rom_r[addra];
        end
    end
    
endmodule