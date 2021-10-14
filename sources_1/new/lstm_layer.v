`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Peter222
// Engineer: 
// 
// Create Date: 2021/09/24 21:05:28
// Design Name: 
// Module Name: lstm_layer
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


module lstm_layer(  );

   reg clk, load, reset;
   reg [9:0] input_x_1, input_x_2,a_prev,c_prev;
   
   wire signed  [9:0] c_next[1:2];
   wire signed  [9:0] a_next[1:2]; 
    
   reg signed  [9:0] c_out[1:301];
   reg signed  [9:0] a_out[1:301]; 
   
   reg signed [1:96320] input_Weights [1:1];
   reg signed [1:3624040] recur_Weights [1:1];
   reg signed [1:12040] Bias [1:1];
   
   wire [1:2] output_done;
   wire [1:2] done;
    
    wire total_done; wire total_output_done;
    
    wire signed  [9:0] check_c;
    wire signed  [9:0] check_a;

    assign total_done = done[2];
    assign total_output_done = output_done[2];
    assign check_c = c_next[2];
    assign check_a = a_next[2];

    lstm_unit_new i0(clk, input_Weights [1],recur_Weights [1],  Bias [1], load, reset, input_x_1, a_prev, c_prev, done[1], output_done[1], c_next[1], a_next[1]);
    generate 
        //for (genvar h = 1; h < 301; h = h + 1) begin
        for (genvar h = 1; h < 2; h = h + 1) begin
            lstm_unit_new i1(clk,input_Weights [1],recur_Weights [1],  Bias [1], done[h], reset, input_x_2, a_next[h] , c_next[h], done[h+1], output_done[h+1], c_next[h+1], a_next[h+1]);
        end
    endgenerate 
    
    
    always begin
     #5 clk=~clk; // �ֱ�� 10
    end
   integer clk_count; 
    always @(posedge clk) begin
        if(done[2] == 1) begin
            if (output_done[2]==0) begin
                a_out[clk_count] = a_next[2];
                c_out[clk_count] = c_next[2];
                clk_count <= clk_count + 1;
            end
            else begin
                a_out[clk_count] = 'b11111_11111;
                c_out[clk_count] = 'b11111_11111;
            end
        end
    end
    
    initial begin
        $readmemb("layer2_input_weights.txt",input_Weights );
        $readmemb("layer2_recur_weights.txt",recur_Weights );
        $readmemb("layer2_bias.txt",Bias );
        
    clk = 1; load = 0; c_prev = 0; a_prev = 0; input_x_1 = 0; input_x_2 = 0;
    reset = 0; clk_count =1;    
    
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
    
    #3020;
    $finish;
    end
    
    
    
endmodule
