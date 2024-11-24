`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 04:21:39 AM
// Design Name: 
// Module Name: uart_stopwatch
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


module uart_stopwatch(
    input clk, rst_n,
    input rx,
    output [7:0] seg_out,
    output [7:0] sel_out,
    output tx
);

    reg rd_uart;
    wire rx_empty;
    wire [7:0] rd_data;
    reg clr; 
    reg up_reg = 1, up_nxt; 
    reg go_reg = 0, go_nxt; 
    reg wr_uart;
    reg [7:0] displaytime[9:0]; 
    reg [7:0] wr_data, wr_data_nxt;
    wire [4:0] in0, in1, in2, in3, in4, in5, in6, in7; 
    reg [3:0] index = 0, index_nxt; 
    reg lock = 0, lock_nxt;

    enhanced_stopwatch m0(
        .clk(clk),
        .rst_n(rst_n),
        .up(up_reg),
        .go(go_reg),
        .clr(clr),
        .in0(in0), 
        .in1(in1), 
        .in2(in2), 
        .in3(in3),
        .in4(in4), 
        .in5(in5),  
        .in6(in6), 
        .in7(in7) 
    );

    LED_mux m1(
        .clk(clk),
        .rst(rst_n),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .in3(in3),
        .in4(in4),
        .in5(in5),
        .in6(in6),
        .in7(in7),
        .seg_out(seg_out),
        .sel_out(sel_out)
    );

    uart #(.DBIT(8), .SB_TICK(16), .DVSR(326), .DVSR_WIDTH(9), .FIFO_W(4)) m2(
        .clk(clk),
        .rst_n(rst_n),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .wr_data(wr_data),
        .rx(rx),
        .tx(tx),
        .rd_data(rd_data),
        .rx_empty(rx_empty),
        .tx_full()
    );

    always @(posedge clk, negedge rst_n) 
        begin
            if (!rst_n) 
                begin
                    index <= 0;
                    up_reg <= 1;
                    go_reg <= 0;
                    lock <= 0;
                end
            else 
                begin
                    index <= index_nxt;
                    up_reg <= up_nxt;
                    go_reg <= go_nxt;
                    lock <= lock_nxt;
                end
        end

    always @* 
        begin
            up_nxt = up_reg;
            go_nxt = go_reg;
            lock_nxt = lock;
            index_nxt = index;
            wr_uart = 0;
            rd_uart = 0;
            clr = 0;

            if (!rx_empty) 
                begin
                    if (rd_data == 8'h43 || rd_data == 8'h63) 
                        begin // 'C' or 'c' clears stopwatch
                            clr = 1;
                            up_nxt = 1;
                        end
                    else if (rd_data == 8'h47 || rd_data == 8'h67) 
                        begin // 'G' or 'g' plays the stopwatch
                            go_nxt = 1;
                        end
                    else if (rd_data == 8'h50 || rd_data == 8'h70) 
                        begin // 'P' or 'p' pauses stopwatch
                            go_nxt = 0;
                        end
                    else if (rd_data == 8'h55 || rd_data == 8'h75) 
                        begin // 'U' or 'u' reverses stopwatch direction
                            up_nxt = !up_reg;
                        end
                    else if (rd_data == 8'h52 || rd_data == 8'h72) 
                        begin // 'R' or 'r' transmits current time
                            lock_nxt = 1;
                            index_nxt = 0;
                        end
                    rd_uart = 1;
                end
    
            if (lock) 
                begin
                    wr_data = displaytime[index];
                    wr_uart = 1;
                    if (index == 9) 
                        lock_nxt = 0; // finihs transmitting all 10 data bytes
                    else 
                        index_nxt = index + 1;
                end    
        end

    always @* 
        begin
            displaytime[0] = {4'h3, in6[3:0]}; // Tens of hours
            displaytime[1] = {4'h3, in5[3:0]}; // Units of hours
            displaytime[2] = 8'h3a;            // Colon separator ":"
            displaytime[3] = {4'h3, in4[3:0]}; // Tens of minutes
            displaytime[4] = {4'h3, in3[3:0]}; // Units of minutes
            displaytime[5] = 8'h3a;            // Colon separator ":"
            displaytime[6] = {4'h3, in2[3:0]}; // Tens of seconds
            displaytime[7] = {4'h3, in1[3:0]}; // Units of seconds
            displaytime[8] = 8'h2e;            // Decimal separator "."
            displaytime[9] = {4'h3, in0[3:0]}; // Units of milliseconds
        end

endmodule

