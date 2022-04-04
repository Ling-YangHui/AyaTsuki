`ifndef __DIGIT_TUBE__
`define __DIGIT_TUBE__

module digit_tube (
    input wire per_clk,
    input wire rst_n,
    input wire [4: 0] data_A,
    input wire [4: 0] data_B,
    input wire [2: 0] bright,
    output wire [1: 0] sel,
    output wire [7: 0] driver
);

    `define Display_0 8'b11111100
    `define Display_1 8'b01100000
    `define Display_2 8'b11011010
    `define Display_3 8'b11110010
    `define Display_4 8'b01100110
    `define Display_5 8'b10110110
    `define Display_6 8'b10111110
    `define Display_7 8'b11100000
    `define Display_8 8'b11111110
    `define Display_9 8'b11110110
    `define Display_A 8'b11101110
    `define Display_B 8'b00111110
    `define Display_C 8'b10011100
    `define Display_D 8'b01111010
    `define Display_E 8'b10011110
    `define Display_F 8'b10001110
    `define Display_H 8'b01101111
    `define Display_DP 8'b00000001


    reg sel_reg;
    reg [7: 0] driver_reg;
    reg [2: 0] bright_cnt;

    assign driver = driver_reg;
    assign sel = {sel_reg, ~sel_reg};

    always @(posedge per_clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_reg <= 0;
            driver_reg <= 0;
            bright_cnt <= 0;
        end
        else begin
            bright_cnt <= bright_cnt + 1'b1;
            if (bright_cnt <= bright) begin
                sel_reg <= ~sel_reg;
                if (sel_reg) begin
                    case (data_A)
                        5'b00000:
                            driver_reg <= `Display_0;
                        5'b00001:
                            driver_reg <= `Display_1;
                        5'b00010:
                            driver_reg <= `Display_2;
                        5'b00011:
                            driver_reg <= `Display_3;
                        5'b00100:
                            driver_reg <= `Display_4;
                        5'b00101:
                            driver_reg <= `Display_5;
                        5'b00110:
                            driver_reg <= `Display_6;
                        5'b00111:
                            driver_reg <= `Display_7;
                        5'b01000:
                            driver_reg <= `Display_8;
                        5'b01001:
                            driver_reg <= `Display_9;
                        5'b01010:
                            driver_reg <= `Display_A;
                        5'b01011:
                            driver_reg <= `Display_B;
                        5'b01100:
                            driver_reg <= `Display_C;
                        5'b01101:
                            driver_reg <= `Display_D;
                        5'b01110:
                            driver_reg <= `Display_E;
                        5'b01111:
                            driver_reg <= `Display_F;
                        5'b10000: 
                            driver_reg <= `Display_H;
                        default: 
                            driver_reg <= `Display_DP;
                    endcase
                end
                else begin
                    case (data_B)
                        5'b00000:
                            driver_reg <= `Display_0;
                        5'b00001:
                            driver_reg <= `Display_1;
                        5'b00010:
                            driver_reg <= `Display_2;
                        5'b00011:
                            driver_reg <= `Display_3;
                        5'b00100:
                            driver_reg <= `Display_4;
                        5'b00101:
                            driver_reg <= `Display_5;
                        5'b00110:
                            driver_reg <= `Display_6;
                        5'b00111:
                            driver_reg <= `Display_7;
                        5'b01000:
                            driver_reg <= `Display_8;
                        5'b01001:
                            driver_reg <= `Display_9;
                        5'b01010:
                            driver_reg <= `Display_A;
                        5'b01011:
                            driver_reg <= `Display_B;
                        5'b01100:
                            driver_reg <= `Display_C;
                        5'b01101:
                            driver_reg <= `Display_D;
                        5'b01110:
                            driver_reg <= `Display_E;
                        5'b01111:
                            driver_reg <= `Display_F;
                        5'b10000: 
                            driver_reg <= `Display_H;
                        default: 
                            driver_reg <= `Display_DP;
                    endcase
                end
            end else begin
                driver_reg <= 0;
            end
        end
    end
    
endmodule

`endif
