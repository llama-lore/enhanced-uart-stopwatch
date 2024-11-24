`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 04:07:39 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(parameter DBIT=8, SB_TICK=16)(
    input clk, rst_n,
    input s_tick, tx_start,
    input[7:0] din,
    output reg tx_done_tick,
    output tx
);
  
    localparam[1:0] idle = 2'd0,
                    start = 2'd1,
                    data = 2'd2,
                    stop = 2'd3;
    reg[1:0] state_reg, state_nxt;
    reg[3:0] s_reg, s_nxt; 
    reg[2:0] n_reg, n_nxt; 
    reg[7:0] din_reg, din_nxt;
    reg tx_reg, tx_nxt;

    always @(posedge clk, negedge rst_n) 
        begin
            if(!rst_n) 
                begin
                    state_reg <= idle;
                    s_reg <= 0;
                    n_reg <= 0;
                    din_reg <= 0;
                    tx_reg <= 0;
                end
            else 
                begin
                    state_reg <= state_nxt;
                    s_reg <= s_nxt;
                    n_reg <= n_nxt;
                    din_reg <= din_nxt;
                    tx_reg <= tx_nxt;
                end
        end

    always @* 
        begin
            state_nxt = state_reg;
            s_nxt = s_reg;
            n_nxt = n_reg;
            din_nxt = din_reg;
            tx_nxt = tx_reg;
            tx_done_tick = 0;
            case(state_reg)
                idle: 
                    begin 
                        tx_nxt = 1;
                        if(tx_start == 0) 
                            begin 
                                din_nxt = din;
                                s_nxt = 0;
                                state_nxt = start;
                            end
                    end
                start: 
                    begin //wait to finish the start bit
                        tx_nxt = 0;
                        if(s_tick == 1) 
                            begin
                                if(s_reg == 15) 
                                    begin
                                        s_nxt = 0;
                                        n_nxt = 0;
                                        state_nxt = data;
                                    end
                                else 
                                    s_nxt = s_reg + 1;
                            end
                    end
                data: 
                    begin 
                        tx_nxt = din_reg[0];
                        if(s_tick == 1) 
                            begin
                                if(s_reg == 15) 
                                    begin
                                        din_nxt = din_reg >> 1;
                                        s_nxt = 0;
                                        if(n_reg == DBIT - 1) 
                                            state_nxt = stop;
                                        else 
                                            n_nxt = n_reg + 1;
                                    end
                                else 
                                    s_nxt = s_reg + 1;
                            end
                    end
                stop: 
                    begin 
                        tx_nxt = 1;
                        if(s_tick == 1) 
                            begin
                                if(s_reg == SB_TICK - 1) 
                                    begin
                                        tx_done_tick = 1;
                                        state_nxt = idle;
                                    end
                                else 
                                    s_nxt = s_reg + 1;
                            end
                    end
                default: 
                    state_nxt = idle;
            endcase
        end
    assign tx = tx_reg;

endmodule
