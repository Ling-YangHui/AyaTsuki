module div_clk (
    input wire sys_clk,
    input wire rst_n,
    output wire div_clk
);
    
    parameter Frequency = 5_000;
    localparam Cnt_Max = 50_000_000 / Frequency / 6;

    reg [31: 0] div_cnt;
    reg per_clk;


    assign div_clk = per_clk;

    always @(posedge sys_clk or negedge rst_n) begin
        if (!rst_n) begin
            div_cnt <= 0;
            per_clk <= 0;
        end else begin
            if (div_cnt == Cnt_Max) begin
                div_cnt <= 0;
                per_clk <= ~per_clk;
            end else begin
                div_cnt <= div_cnt + 1; 
            end
        end
    end

endmodule