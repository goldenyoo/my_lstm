`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/15 19:41:24
// Design Name: 
// Module Name: sigmoid
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


module sigmoid(clk, done, input_x, output_y);
    parameter bit_size = 10;
    
    
    input wire clk;
    input wire done;
    input wire signed [bit_size-1:0] input_x;
    output reg signed [bit_size-1:0] output_y;    
    
  
    reg signed [bit_size-1:0] x1, x2, x3, b;
    reg [3:0] seg;
   
    reg [bit_size-1:0] constant_b[0:8];
    
   
    
    initial begin
           constant_b[0]='b0000010000;
	       constant_b[1]='b0000010100;
	       constant_b[2]='b0000011001;
	       constant_b[3]='b0000011100;
	       constant_b[4]='b0000011101;
	       constant_b[5]='b0000011111;
	       constant_b[6]='b0000011111;
	       constant_b[7]='b0000100000;
	       constant_b[8]='b0000100000;
    end
    
   
    
     always @(*) begin
        if(done) begin 
            if (input_x < 0) begin
                x1 = -input_x;
            end
            else begin
                x1 = input_x;
            end
            
           if (x1<'b0000100010)
	           seg=1;
	       else if ( x1<'b0001000101)
	            seg=2;
	       else if (x1 <'b0001011111)
	           seg=3;
	       else if (x1<'b0001110111)
	           seg=4;
	       else if ( x1<'b0010001110)
	           seg=5;
	       else if ( x1<'b0010100101)
	           seg=6;
	       else if (x1<'b0010111011)
	           seg=7;
	       else if (x1<'b0011101000) 
	           seg=8;
	       else
	           seg=9;
	           
	       case(seg) 
	           'd1: x2 = x1 >>> 2;
               'd2: x2 = x1 >>> 3;
               'd3: x2 = x1 >>> 4;
               'd4: x2 = x1 >>> 5;
               'd5: x2 = x1 >>> 6;
               'd6: x2 = x1 >>> 7;
               'd7: x2 = x1 >>> 8;
               'd8: x2 = x1 >>> 9;
               'd9: x2 = 0;
               default: x2 = 0;
           endcase 
           b = constant_b[seg-1];
           
           x3 = x2 + b;
           if(input_x <0)
            output_y = 'b00001_00000 - x3;
           else
            output_y = x3;
        end // if (done)
        else begin
        
        end
    end // always
    
   
endmodule

