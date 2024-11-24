`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2024 03:26:02 AM
// Design Name: 
// Module Name: LED_mux
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


module LED_mux #(parameter N=20)( 
    input clk, rst,
    input [4:0] in0, in1, in2, in3, in4, in5, in6, in7, 
    output reg [7:0] seg_out,
    output reg [7:0] sel_out
);
	
	reg [N-1:0] r_reg = 0;
	reg [4:0] hex_out = 0;
	wire [N-1:0] r_nxt;
	wire [2:0] out_counter; // last 3 bits to be usde as output signal
	
	always @(posedge clk or negedge rst)
	if (!rst) 
		r_reg <= 0;
	else 
		r_reg <= r_nxt;
	 
	assign r_nxt = (r_reg == {3'd7, {(N-3){1'b1}}}) ? {N{1'b0}} : r_reg + 1'b1; 
	assign out_counter = r_reg[N-1:N-3];
	 
	always @(out_counter) 
	   begin
	       sel_out = 8'b1111_1111; 
	       sel_out[out_counter] = 1'b0;
	   end

	always @* 
	   begin
	       hex_out = 0;
	       case(out_counter)
	           3'b000: hex_out = in0;
	           3'b001: hex_out = in1;
	           3'b010: hex_out = in2;
	           3'b011: hex_out = in3;
	           3'b100: hex_out = in4;
	           3'b101: hex_out = in5;
	           3'b110: hex_out = in6;
	           3'b111: hex_out = in7;
	       endcase
       end

	always @* 
	   begin
	       seg_out = 0;
	       case(hex_out[3:0])
	           4'h0: seg_out[6:0] = 7'b1000_000;
	           4'h1: seg_out[6:0] = 7'b1111_001;
	           4'h2: seg_out[6:0] = 7'b0100_100;
	           4'h3: seg_out[6:0] = 7'b0110_000;
	           4'h4: seg_out[6:0] = 7'b0011_001;
	           4'h5: seg_out[6:0] = 7'b0010_010;
	           4'h6: seg_out[6:0] = 7'b0000_010;
	           4'h7: seg_out[6:0] = 7'b1111_000;
	           4'h8: seg_out[6:0] = 7'b0000_000;
	           4'h9: seg_out[6:0] = 7'b0011_000;
	       endcase
	       seg_out[7] = !hex_out[4];
	   end

endmodule
