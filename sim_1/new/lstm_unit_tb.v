`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/15 17:29:23
// Design Name: 
// Module Name: lstm_unit_tb
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


module lstm_unit_tb();
reg clk, load, reset;
reg [9:0] input_x_1, input_x_2,a_prev,c_prev;
wire signed  [9:0] c_next[1:301];
wire signed  [9:0] a_next[1:301]; 

wire [1:301] output_done;
wire [1:301] done;

wire total_done;

assign total_done = output_done[301];

lstm_unit i0(clk, load, reset, input_x_1, a_prev, c_prev, done[1], output_done[1], c_next[1], a_next[1]);
generate 
    for (genvar h = 1; h < 301; h = h + 1) begin
        lstm_unit i1(clk, output_done[h], reset, input_x_2, a_next[h] , c_next[h], done[h+1], output_done[h+1], c_next[h+1], a_next[h+1]);
    end
endgenerate 

always begin
     #5 clk=~clk; // ÁÖ±â´Â 10
end

initial begin
    clk = 1; load = 0; c_prev = 0; a_prev = 0; input_x_1 = 0; input_x_2 = 0;
    reset = 0;
    
    
    #30;
    load = 1;
    input_x_1 = 'b1110000111; input_x_2 = 'b1110000111;
    
    #10;
    input_x_1 = 'b1110000001; input_x_2 = 'b1110000001;
    
    #10;
    input_x_1 = 'b1100000111; input_x_2 = 'b1100000111;
    
    #10;
    input_x_1 = 'b0001000011; input_x_2 = 'b0001000011;
    
    #10;
    input_x_1 = 'b0000000010; input_x_2 = 'b0000000010;
    
    #10;
    input_x_1 = 'b0000100110; input_x_2 = 'b0000100110;
    
    #10;
    input_x_1 = 'b1111100001; input_x_2 = 'b1111100001;
    
    #10;
    input_x_1 = 'b1101000010; input_x_2 = 'b1101000010;
    
    #2940;
    #3020;        
    #10;
    //$finish;
    
    #1812000;
    $finish;
    
end



endmodule
