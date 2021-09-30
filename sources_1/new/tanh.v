`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/21 13:26:55
// Design Name: 
// Module Name: tanh
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


module tanh(clk, done, input_x, output_y);
parameter bit_size = 10;
    
    
    input wire clk;
    input wire done;
    input wire signed [bit_size-1:0] input_x;
    output reg signed [bit_size-1:0] output_y;    
    
  
    reg signed [bit_size-1:0] x1, x2, x3, b;
    reg [2:0] seg;
   
    reg [bit_size-1:0] constant_b[0:8];
    
   
    
    initial begin
           constant_b[0]='b0000000000;
	       constant_b[1]='b0000100000;
	       constant_b[2]='b0000110000;
	       constant_b[3]='b0001010000;
    end
    
   
    
     always @(*) begin
        if(done) begin 
            if (input_x < 0) begin
                x1 = -input_x;
            end
            else begin
                x1 = input_x;
            end
            
           if (x1<'b0000100000)
	           seg=1;
	       else if ( x1<'b0000110000)
	            seg=2;
	       else if (x1 <'b0001010000)
	           seg=3;
	       else
	           seg=4;
	           
	       case(seg) 
	           'd1: x2 = x1 >>> 1 + x1 >>> 2;
               'd2: x2 = x1 >>> 2;
               'd3: x2 = x1 >>> 3;
               'd4: x2 = 0;
               default: x2 = 0;
           endcase 
           b = constant_b[seg-1];
           
           x3 = x2 + b;
           if(input_x <0)
            output_y = -x3;
           else
            output_y = x3;
        end // if (done)
        else begin
        
        end
    end // always
    
   
endmodule
