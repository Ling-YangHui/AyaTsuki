/** 
* Author: YangHui
* Date: 20220404
* File: ayatsuki_soc.v
*/

`ifndef __ISE__
`include "rtl/core/ayatsuki_core.v"
`include "rtl/utils/digit_tube.v"
`include "rtl/utils/div_clk.v"
`include "AyaTsuki_ISE/ipcore_dir/memory.v"
`include "AyaTsuki_ISE/ipcore_dir/rom.v"
`include "rtl/perip/tim.v"
`include "rtl/perip/uart.v"
`endif

`ifdef __ISE__
`include "../core/define.v"
`endif

module ayatsuki_soc (
    input wire          clk,
    input wire          rst_n,
    output wire [1: 0]  data_sel,
    output wire [7: 0]  data_driver
);

    reg [1:0] cnt;
    reg div_clk;
    reg div_rst_n;
    always @(posedge clk) begin
        if (~rst_n) begin
            cnt <= 0;
            div_clk <= 0;
            div_rst_n <= 0;
        end else begin
            if (cnt == 2'b11) begin
                cnt <= 0;
                div_clk <= ~div_clk;
                if (div_rst_n == 0 && div_clk) begin
                    div_rst_n <= 1;
                end
            end else begin
                cnt <= cnt + 2'b1;
            end
        end
    end

    wire [`inst_bus] inst;
    wire [`inst_addr_bus] inst_addr;
    wire bus_w_enable;
    wire bus_r_enable;
    wire bus_enable;
    wire [`mem_addr_bus] bus_w_addr;
    wire [`mem_addr_bus] bus_r_addr;
    wire [`data_bus] bus_w_data;
    reg [`data_bus] bus_r_data;
	 
	assign mem_w_enable_o = bus_r_enable;

    wire [`data_bus] mem_r_data;
    wire [`data_bus] tim_r_data;
    wire [`data_bus] uart_r_data;

    reg [`mem_addr_bus] past_r_addr_r;
    always @(posedge div_clk) begin
        if (div_rst_n == `rst_enable) begin
            past_r_addr_r <= `mem_addr_bus_width'b0;
        end else begin
            past_r_addr_r <= bus_r_addr;
        end
    end

    always @(*) begin
        bus_r_data = `data_bus_width'b0;
        if (past_r_addr_r >= `tim_addr_start && past_r_addr_r <= `tim_addr_end)
            bus_r_data = tim_r_data;
        else if (past_r_addr_r >= `uart_addr_start && past_r_addr_r <= `uart_addr_start) begin
            bus_r_data = uart_r_data;
        end else 
            bus_r_data = mem_r_data;
    end

    ayatsuki_core u_ayatsuki_core(
		.clk            (div_clk        ),
        .rst_n          (div_rst_n      ),
        .inst_i         (inst           ),
        .inst_addr_o    (inst_addr      ),
        .mem_w_enable_o (bus_w_enable   ),
        .mem_r_enable_o (bus_r_enable   ),
        .mem_enable_o   (bus_enable     ),
        .mem_w_addr_o   (bus_w_addr     ),
        .mem_r_addr_o   (bus_r_addr     ),
        .mem_data_i     (bus_r_data     ),
        .mem_data_o     (bus_w_data     )
        // .irq_req_i      (irq_req_i      )
    );
	 
    tim u_tim(
    	.clk            (div_clk        ),
        .rst_n          (div_rst_n      ),
        .tim_r_addr_i   (bus_r_addr     ),
        .tim_w_addr_i   (bus_w_addr     ),
        .tim_data_i     (bus_w_data     ),
        .tim_r_enable_i (bus_r_enable   ),
        .tim_w_enable_i (bus_w_enable   ),

        .tim_data_o     (tim_r_data     )
        // .tim_irq_o      (tim_irq_o      )
    );

    uart u_uart(
    	.clk             (div_clk       ),
        .rst_n           (div_rst_n     ),
        .uart_r_addr_i   (bus_r_addr    ),
        .uart_w_addr_i   (bus_w_addr    ),
        .uart_data_i     (bus_w_data    ),
        .uart_r_enable_i (bus_r_enable  ),
        .uart_w_enable_i (bus_w_enable  ),

        .uart_data_o     (uart_r_data   )
        // .uart_irq_o      (uart_irq_o    )
    );
    
    

	memory u_memory (
        .clka		(div_clk	        ), // input clka
        .ena		(bus_enable		    ), // input ena
        .wea		(bus_w_enable	    ), // input [0 : 0] wea
        .addra		(bus_w_addr >> 2    ), // input [8 : 0] addra
        .dina		(bus_w_data		    ), // input [31 : 0] dina
        .clkb		(div_clk			), // input clkb
        .rstb		(~div_rst_n			), // input rstb
        .enb		(bus_r_enable	    ), // input enb
        .addrb		(bus_r_addr >> 2	), // input [8 : 0] addrb
        .doutb		(mem_r_data		    )  // output [31 : 0] doutb
	);
    
	rom u_rom (
        .clka		(div_clk		    ), // input clka
        .rsta		(~div_rst_n			), // input rsta
        .addra		(inst_addr >> 2		), // input [8 : 0] addra
        .douta		(inst			    )  // output [31 : 0] douta
    );
	 

    wire per_clk;
    div_clk  u_div_clk(
    	.sys_clk (div_clk ),
        .rst_n   (div_rst_n   ),
        .div_clk (per_clk )
    );
    
    reg [7: 0] mem_data_out_r;
    always @(posedge div_clk) begin
        if (~div_rst_n) begin
            mem_data_out_r <= 0;
        end else begin
            if (bus_w_enable) begin
                mem_data_out_r <= bus_w_data[7: 0];
            end
        end
    end
	

    digit_tube u_digit_tube(
    	.per_clk (per_clk ),
        .rst_n   (div_rst_n   ),
        .data_A  ({1'b0, mem_data_out_r[7: 4]}  ),
        .data_B  ({1'b0, mem_data_out_r[3: 0]}  ),
        .bright  (3'b101  ),
        .sel     (data_sel     ),
        .driver  (data_driver  )
    );
    
    
endmodule