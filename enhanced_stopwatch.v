`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 03:34:07 AM
// Design Name: 
// Module Name: Enhanced_Stopwatch
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

module enhanced_stopwatch(   
    input clk, rst_n,
    input up, go, clr, 
    output [4:0] in0, in1, in2, in3, in4, in5, in6, in7
);

    reg [23:0] mod_10M = 0; // Counter for 0.1 second period (10M counts at 100MHz)
    reg [3:0] D0 = 0, S0 = 0, S1 = 0, M0 = 0, M1 = 0, H0 = 0, H1 = 0;
    reg [23:0] mod_10M_nxt = 0;
    reg [3:0] D0_nxt = 0, S0_nxt = 0, S1_nxt = 0, M0_nxt = 0, M1_nxt = 0, H0_nxt = 0, H1_nxt = 0;
    reg mod_10M_max = 0, D0_max = 0, S0_max = 0, S1_max = 0, M0_max = 0, M1_max = 0, H0_max = 0, H1_max = 0;

    always @(posedge clk, negedge rst_n) 
        begin
            if (!rst_n) 
                begin
                    mod_10M <= 0;
                    D0 <= 0;
                    S0 <= 0;
                    S1 <= 0;
                    M0 <= 0;
                    M1 <= 0;
                    H0 <= 0;
                    H1 <= 0;
                end
            else 
                begin
                    if (clr) 
                        begin
                            mod_10M <= 0;
                            D0 <= 0;
                            S0 <= 0;
                            S1 <= 0;
                            M0 <= 0;
                            M1 <= 0;
                            H0 <= 0;
                            H1 <= 0;    
                        end
                    else if (go) 
                        begin 
                            mod_10M <= mod_10M_nxt;
                            D0 <= D0_nxt;
                            S0 <= S0_nxt;
                            S1 <= S1_nxt;
                            M0 <= M0_nxt;
                            M1 <= M1_nxt;
                            H0 <= H0_nxt;
                            H1 <= H1_nxt;
                        end
                end
        end
     
    always @* 
        begin
            mod_10M_nxt = mod_10M;
            D0_nxt = D0;
            S0_nxt = S0;
            S1_nxt = S1;
            M0_nxt = M0;
            M1_nxt = M1;
            H0_nxt = H0;
            H1_nxt = H1;
            mod_10M_max = 0;
            D0_max = 0;
            S0_max = 0;
            S1_max = 0;
            M0_max = 0;
            M1_max = 0;
            H0_max = 0;
            H1_max = 0;

            mod_10M_nxt = up ? mod_10M + 1 : mod_10M - 1;  
            mod_10M_max = (mod_10M_nxt == 10_000_000 || mod_10M_nxt == {24{1'b1}}) ? 1 : 0; 
            mod_10M_nxt = (mod_10M_nxt == 10_000_000) ? 0 : mod_10M_nxt; 
            mod_10M_nxt = (mod_10M_nxt == {24{1'b1}}) ? 9_999_999 : mod_10M_nxt; 
         
            if (mod_10M_max) 
                begin // Decimal digit (D0)
                    D0_nxt = up ? D0 + 1 : D0 - 1;
                    D0_max = (D0_nxt == 10 || D0_nxt == 4'b1111) ? 1 : 0;
                    D0_nxt = (D0_nxt == 10) ? 0 : D0_nxt;
                    D0_nxt = (D0_nxt == 4'b1111) ? 9 : D0_nxt;
                end

            if (D0_max && mod_10M_max) 
                begin // Seconds unit (S0)
                    S0_nxt = up ? S0 + 1 : S0 - 1;
                    S0_max = (S0_nxt == 10 || S0_nxt == 4'b1111) ? 1 : 0;
                    S0_nxt = (S0_nxt == 10) ? 0 : S0_nxt;
                    S0_nxt = (S0_nxt == 4'b1111) ? 9 : S0_nxt;
                end
         
            if (S0_max && D0_max && mod_10M_max) 
                begin // Seconds tens (S1)
                    S1_nxt = up ? S1 + 1 : S1 - 1;
                    S1_max = (S1_nxt == 6 || S1_nxt == 3'b111) ? 1 : 0;
                    S1_nxt = (S1_nxt == 6) ? 0 : S1_nxt;
                    S1_nxt = (S1_nxt == 3'b111) ? 5 : S1_nxt;
                end
         
            if (S1_max && S0_max && D0_max && mod_10M_max) 
                begin // Minutes unit (M0)
                    M0_nxt = up ? M0 + 1 : M0 - 1;
                    M0_max = (M0_nxt == 10 || M0_nxt == 4'b1111) ? 1 : 0;
                    M0_nxt = (M0_nxt == 10) ? 0 : M0_nxt;
                    M0_nxt = (M0_nxt == 4'b1111) ? 9 : M0_nxt;
                end

            if (M0_max && S1_max && S0_max && D0_max && mod_10M_max) 
                begin // Minutes tens (M1)
                    M1_nxt = up ? M1 + 1 : M1 - 1;
                    M1_max = (M1_nxt == 6 || M1_nxt == 3'b111) ? 1 : 0;
                    M1_nxt = (M1_nxt == 6) ? 0 : M1_nxt;
                    M1_nxt = (M1_nxt == 3'b111) ? 5 : M1_nxt;
                end

            if (M1_max && M0_max && S1_max && S0_max && D0_max && mod_10M_max) 
                begin // Hours unit (H0)
                    H0_nxt = up ? H0 + 1 : H0 - 1;
                    H0_max = (H0_nxt == 10 || H0_nxt == 4'b1111) ? 1 : 0;
                    H0_nxt = (H0_nxt == 10) ? 0 : H0_nxt;
                    H0_nxt = (H0_nxt == 4'b1111) ? 9 : H0_nxt;
                end

            if (H0_max && M1_max && M0_max && S1_max && S0_max && D0_max && mod_10M_max) 
                begin // Hours tens (H1)
                    H1_nxt = up ? H1 + 1 : H1 - 1;
                    H1_max = (H1_nxt == 3 || H1_nxt == 3'b111) ? 1 : 0;
                    H1_nxt = (H1_nxt == 3) ? 0 : H1_nxt;
                end        
        
            if (H1_max == 1) 
                begin 
                    mod_10M_nxt = mod_10M;
                    D0_nxt = D0;
                    S0_nxt = S0;
                    S1_nxt = S1;
                    M0_nxt = M0;
                    M1_nxt = M1;
                    H0_nxt = H0;
                    H1_nxt = H1;
                end
        end

    assign in0 = {1'b0, D0},
           in1 = {1'b1, S0},
           in2 = {2'b0, S1},
           in3 = {1'b1, M0},
           in4 = {2'b0, M1},
           in5 = {1'b1, H0},
           in6 = {1'b1, H0},
           in7 = 0; // Unused
endmodule