`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 03:49:34 AM
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx #(parameter DBIT=8,SB_TICK=16)( //DBIT=data bits , SB_TICK=ticks for stop bit (16 for 1 bit ,32 for 2 bits)
    input clk, rst_n,
    input rx,
    input s_tick,
    output reg rx_done_tick,
    output[7:0] dout
);

    localparam[1:0] idle = 2'b00,
					start = 2'b01,
					data = 2'b10,
					stop = 2'b11;
	reg[1:0] state_reg, state_nxt;
	reg[3:0] s_reg, s_nxt; 
	reg[2:0] n_reg, n_nxt; 
	reg[7:0] b_reg, b_nxt; 
	
    always @(posedge clk, negedge rst_n) 
        begin
            if(!rst_n) 
                begin
                    state_reg <= idle;
                    s_reg <= 0;
                    n_reg <= 0;
                    b_reg <= 0;
                end
            else 
                begin
                    state_reg<=state_nxt;
                    s_reg<=s_nxt;
                    n_reg<=n_nxt;
                    b_reg<=b_nxt;		
	           	end
	    end

    always @* 
        begin
            state_nxt = state_reg;
            s_nxt = s_reg;
            n_nxt = n_reg;
            b_nxt = b_reg;
            rx_done_tick = 0;
            case(state_reg)
                idle: if(rx == 0) 
                    begin 
                        s_nxt = 0;
                        state_nxt = start;
                    end						
                start: if(s_tick == 1) 
                    begin 
                        if(s_reg == 7) 
                            begin
                                s_nxt = 0;
                                n_nxt = 0;
                                state_nxt = data;
                            end
                        else 
                            s_nxt = s_reg + 1;
                    end
                data: if(s_tick == 1) 
                    begin 
                        if(s_reg == 15) 
                            begin
                                b_nxt = {rx, b_reg[7:1]};
                                s_nxt = 0;
                                if(n_reg == DBIT-1) 
                                    state_nxt = stop;
                                else n_nxt = n_reg + 1;
                            end
                        else 
                            s_nxt = s_reg + 1;
                    end
                stop: if(s_tick == 1) 
                    begin  
                        if(s_reg == SB_TICK - 1) 
                            begin
                                rx_done_tick = 1;
                                state_nxt = idle;
                            end
                        else 
                            s_nxt = s_reg + 1;
                    end	
                default: state_nxt = idle;
            endcase
        end
    assign dout = b_reg;
endmodule
