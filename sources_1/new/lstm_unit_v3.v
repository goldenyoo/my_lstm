`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/14 13:13:48
// Design Name: 
// Module Name: lstm_unit
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


module lstm_unit_v2(clk, input_Weights,  recur_Weights,  Bias, load, reset, xt, a_prev, c_prev, done, output_done, c_next, a_next);
   parameter total_bit = 10;
   parameter fraction_bit = 5;
   
   input wire clk;
   input wire load, reset;
   input wire signed [total_bit-1:0] xt;
   input wire signed [total_bit-1:0] a_prev, c_prev;
   input wire signed [1:96320] input_Weights;
   input wire signed [1:3624040] recur_Weights;
   input wire signed [1:12040] Bias;
   output reg output_done;
   output reg done;
   output reg signed [total_bit-1:0] c_next;
   output reg signed [total_bit-1:0] a_next;
   

   
//   reg [4:0] clk_count_x;
//   reg [8:0] clk_count_ac;
//   reg [8:0] clk_count_out;

   integer clk_count_x, clk_count_ac, clk_count_out;
   
   reg signed [total_bit-1:0] x_matrix [1:8];
   reg signed [total_bit-1:0] a_matrix [1:301];
   reg signed [total_bit-1:0] c_matrix [1:301];
   
   reg signed [total_bit-1:0] tmp_Wux_xt [1:301];
   reg signed [total_bit-1:0] tmp_Wfx_xt [1:301];
   reg signed [total_bit-1:0] tmp_Wcx_xt [1:301];
   reg signed [total_bit-1:0] tmp_Wox_xt [1:301];
   
   reg signed [total_bit-1:0] tmp_Wua_aprev [1:301];
   reg signed [total_bit-1:0] tmp_Wfa_aprev [1:301];
   reg signed [total_bit-1:0] tmp_Wca_aprev [1:301];
   reg signed [total_bit-1:0] tmp_Woa_aprev [1:301];
  
   reg signed [total_bit-1:0] sigmoid_input_u [1:301];
   reg signed [total_bit-1:0] sigmoid_input_f [1:301];
   reg signed [total_bit-1:0] tanh_input_c [1:301];
   reg signed [total_bit-1:0] sigmoid_input_o [1:301];
   
  
   
   integer i; integer j; integer k;
   
   wire signed [total_bit-1:0] sigmoid_output_u [1:301];
   wire signed [total_bit-1:0] sigmoid_output_f [1:301];
   wire signed [total_bit-1:0] sigmoid_output_o [1:301];
   wire signed [total_bit-1:0] tanh_output_c [1:301];
      
   reg signed [total_bit*2 -1 + 8:0] tmp_c_next;
   
   ////////////////////////////////////////////////////////////
   generate 
   for (genvar h = 1; h < 302; h = h + 1) begin
        sigmoid Gate_u(clk, done, sigmoid_input_u[h], sigmoid_output_u[h] );
        sigmoid Gate_f(clk, done, sigmoid_input_f[h], sigmoid_output_f[h] );
        sigmoid Gate_o(clk, done, sigmoid_input_o[h], sigmoid_output_o[h] );
        tanh candidate_c(clk, done, tanh_input_c[h], tanh_output_c[h]);
   end
   endgenerate 
   ////////////////////////////////////////////////////////////
function [9:0] my_mul;
    input signed [9:0] a,b;
    reg signed [19:0] tmp_mul;  
    begin
        tmp_mul  = a*b;
        
        if (tmp_mul < 0) begin
            if (& tmp_mul[19:14] == 0) begin //첫번째 bit 포함해야하나봥 
                my_mul = {1'b1,{(10 -1){1'b0}}};
            end
            else begin
                my_mul = tmp_mul[14:5];
            end
        end
        else  begin
            if (| tmp_mul[19:14] == 1) begin
                my_mul = {1'b0,{(10 -1){1'b1}}};
            end
            else begin
                my_mul = tmp_mul[14:5];
            end
        end
    end
endfunction 

function [9:0] my_add;
    input signed [9:0] a,b;
    reg signed [10:0] tmp_add;  
    begin
        tmp_add  = a + b;
        
        if (tmp_add < 0) begin
            if (& tmp_add[10:9] == 0) begin //첫번째 bit 포함해야하나봥 
                my_add = {1'b1,{(10 -1){1'b0}}};
            end
            else begin
                my_add = tmp_add[9:0];
            end
        end
        else  begin
            if (| tmp_add[10:9] == 1) begin
                my_add = {1'b0,{(10 -1){1'b1}}};
            end
            else begin
                my_add = tmp_add[9:0];
            end
        end
    end
endfunction 

function [9:0] my_mac;
    input signed [9:0] a,b,c;
    reg signed [9:0] tmp_mul;  
    begin
        tmp_mul  = my_mul(a,b);
        my_mac = my_add (tmp_mul ,c);
       
    end
endfunction 
   ////////////////////////////////////////////////////////////
   function [9:0] find_W_ux;
        input integer m,n;
        input signed [1:96320] input_Weights;
        
        find_W_ux = input_Weights[m:n];
   endfunction 
   
   function [9:0] find_W_fx;
        input integer m,n;
        input signed [1:96320] input_Weights;
        find_W_fx = input_Weights[m:n];
   endfunction 
   
   function [9:0] find_W_cx;
        input integer m,n;
        input signed [1:96320] input_Weights;
        find_W_cx = input_Weights[m:n];
   endfunction 
   
   function [9:0] find_W_ox;
        input integer m,n;
        input signed [1:96320] input_Weights;
        find_W_ox = input_Weights[m:n];
   endfunction
   
   function [9:0] find_W_ua;
        input integer m,n;
        input signed [1:3624040] recur_Weights;
        find_W_ua = recur_Weights[m:n];
   endfunction
   
   function [9:0] find_W_fa;
        input integer m,n;
        input signed [1:3624040] recur_Weights;
        find_W_fa = recur_Weights[m:n];
   endfunction
   
   function [9:0] find_W_ca;
        input integer m,n;
        input signed [1:3624040] recur_Weights;
        find_W_ca = recur_Weights[m:n];
   endfunction
   
   function [9:0] find_W_oa;
        input integer m,n;
        input signed [1:3624040] recur_Weights;
        find_W_oa = recur_Weights[m:n];
   endfunction
   
   function [9:0] find_b_u;
        input integer m,n;
        input  signed [1:12040] Bias;
        find_b_u = Bias[m:n];
   endfunction 
   
   function [9:0] find_b_f;
        input integer m,n;
        input  signed [1:12040] Bias;
        find_b_f = Bias[m:n];
   endfunction 
   
   function [9:0] find_b_c;
        input integer m,n;
        input  signed [1:12040] Bias;
        find_b_c = Bias[m:n];
   endfunction 
   
   function [9:0] find_b_o;
        input integer m,n;
        input  signed [1:12040] Bias;
        find_b_o = Bias[m:n];
   endfunction 

   
   ////////////////////////////////////////////////////////////
   
   
   initial begin

    for (j = 1; j < 302; j = j + 1) begin
            
            tmp_Wux_xt[j] = 0; tmp_Wua_aprev[j] = 0;
            tmp_Wfx_xt[j] = 0; tmp_Wfa_aprev[j] = 0;
            tmp_Wcx_xt[j] = 0; tmp_Wca_aprev[j] = 0;
            tmp_Wox_xt[j] = 0; tmp_Woa_aprev[j] = 0;
            
    end

    done = 0; output_done = 0;
    clk_count_x = 1;
    clk_count_ac = 1;
    clk_count_out = 1;
    
    tmp_c_next = 0;
    c_next = 0; a_next = 0;
   end
   
   always @(posedge clk) begin
    if (reset == 1) begin
        for (j = 1; j < 302; j = j + 1) begin
                        
            tmp_Wux_xt[j] = 0; tmp_Wua_aprev[j] = 0;
            tmp_Wfx_xt[j] = 0; tmp_Wfa_aprev[j] = 0;
            tmp_Wcx_xt[j] = 0; tmp_Wca_aprev[j] = 0;
            tmp_Wox_xt[j] = 0; tmp_Woa_aprev[j] = 0;
            
            x_matrix[j] = 0; a_matrix[j] = 0; c_matrix[j] = 0; 
            
            sigmoid_input_u[j] = 0; sigmoid_input_f[j] = 0; tanh_input_c[j] = 0; sigmoid_input_o[j] = 0;
            
            clk_count_x = 1; clk_count_ac = 1; done = 0; tmp_c_next = 0;
            clk_count_out = 1;
            c_next = 0; a_next = 0;
        end
    end
    else begin
        if ( load == 1) begin
            if (clk_count_x < 9) begin
                x_matrix[clk_count_x] = xt;
                a_matrix[clk_count_ac] = a_prev;
                c_matrix[clk_count_ac] = c_prev;
            
                for (k = 1; k < 302; k = k + 1) begin
                
                    tmp_Wux_xt[k]  <= my_mac(find_W_ux(80*(k-1)+10*(clk_count_x-1)+1,80*(k-1)+10*(clk_count_x),input_Weights), xt, tmp_Wux_xt[k]);
                    tmp_Wfx_xt[k]  <= my_mac(find_W_fx(24080+80*(k-1)+10*(clk_count_x-1)+1,24080+80*(k-1)+10*(clk_count_x),input_Weights), xt, tmp_Wfx_xt[k]);
                    tmp_Wcx_xt[k]  <= my_mac(find_W_cx(24080*2+80*(k-1)+10*(clk_count_x-1)+1,24080*2+80*(k-1)+10*(clk_count_x),input_Weights), xt, tmp_Wcx_xt[k]);
                    tmp_Wox_xt[k]  <= my_mac(find_W_ox(24080*3+80*(k-1)+10*(clk_count_x-1)+1,24080*3+80*(k-1)+10*(clk_count_x),input_Weights), xt, tmp_Wox_xt[k]);
               
                    tmp_Wua_aprev[k] <= my_mac(find_W_ua(3010*(k-1)+10*(clk_count_x-1)+1,3010*(k-1)+10*(clk_count_x),recur_Weights ), a_prev, tmp_Wua_aprev[k]);
                    tmp_Wfa_aprev[k] <= my_mac(find_W_fa(906010+3010*(k-1)+10*(clk_count_x-1)+1,906010+3010*(k-1)+10*(clk_count_x),recur_Weights), a_prev, tmp_Wfa_aprev[k]);
                    tmp_Wca_aprev[k] <= my_mac(find_W_ca(906010*2+3010*(k-1)+10*(clk_count_x-1)+1,906010*2+3010*(k-1)+10*(clk_count_x),recur_Weights), a_prev, tmp_Wca_aprev[k]);
                    tmp_Woa_aprev[k] <= my_mac(find_W_oa(906010*3+3010*(k-1)+10*(clk_count_x-1)+1,906010*3+3010*(k-1)+10*(clk_count_x),recur_Weights), a_prev, tmp_Woa_aprev[k]);
                end        
            
                clk_count_x <= clk_count_x + 1;
                clk_count_ac <= clk_count_ac + 1;
            end
            else if(clk_count_ac < 302) begin
                a_matrix[clk_count_ac] = a_prev;
                c_matrix[clk_count_ac] = c_prev;
            
                for (k = 1; k < 302; k = k + 1) begin
                
                    tmp_Wua_aprev[k] <= my_mac(find_W_ua(3010*(k-1)+10*(clk_count_ac-1)+1,3010*(k-1)+10*(clk_count_ac),recur_Weights), a_prev, tmp_Wua_aprev[k]);
                    tmp_Wfa_aprev[k] <= my_mac(find_W_fa(906010+3010*(k-1)+10*(clk_count_ac-1)+1,906010+3010*(k-1)+10*(clk_count_ac),recur_Weights), a_prev, tmp_Wfa_aprev[k]);
                    tmp_Wca_aprev[k] <= my_mac(find_W_ca(906010*2+3010*(k-1)+10*(clk_count_ac-1)+1,906010*2+3010*(k-1)+10*(clk_count_ac),recur_Weights), a_prev, tmp_Wca_aprev[k]);
                    tmp_Woa_aprev[k] <= my_mac(find_W_oa(906010*3+3010*(k-1)+10*(clk_count_ac-1)+1,906010*3+3010*(k-1)+10*(clk_count_ac),recur_Weights), a_prev, tmp_Woa_aprev[k]);
                end            
            
                clk_count_ac <= clk_count_ac + 1;
            end
            else begin
                if (done == 1'b0) begin
                    for (k = 1; k < 302; k = k + 1) begin
                        sigmoid_input_u[k] = my_add (my_add (tmp_Wux_xt[k] , tmp_Wua_aprev[k]) , find_b_u(10*(k-1)+1,10*k, Bias ));
                        sigmoid_input_f[k] = my_add(my_add(tmp_Wfx_xt[k], tmp_Wfa_aprev[k]) , find_b_f(3010+10*(k-1)+1,3010+10*k,Bias));
                        tanh_input_c[k] = my_add(my_add(tmp_Wcx_xt[k], tmp_Wca_aprev[k]) , find_b_c(3010*2+10*(k-1)+1,3010*2+10*k, Bias));
                        sigmoid_input_o[k] = my_add(my_add(tmp_Wox_xt[k], tmp_Woa_aprev[k]), find_b_o(3010*3+10*(k-1)+1,3010*3+10*k, Bias));
                    end
                    done = 1'b1;   
                end
                else begin
                    if (clk_count_out < 302) begin
   
                        c_next = my_add( my_mul (sigmoid_output_u[clk_count_out],tanh_output_c[clk_count_out]) , my_mul (sigmoid_output_f[clk_count_out], c_matrix[clk_count_out]));                    
                        a_next = my_mul(sigmoid_output_o[clk_count_out], c_next);
                        clk_count_out <= clk_count_out + 1;
                    end
                    else begin
                        output_done = 1'b1;
                        c_next = 0;
                        a_next = 0;
                    end // if (clk_count_out < 302)
                end // if (done ==0)      
            end
        end // if (load == 1)
    end // if-else (reset)
   end // always-end
   
 
    
endmodule
