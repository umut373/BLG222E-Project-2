`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2024 22:40:15
// Design Name: 
// Module Name: Register
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


module Register(I, E, FunSel, Clock, Q);
    input wire [15:0] I;
    input wire E;
    input wire [2:0] FunSel;
    input wire Clock;
    
    output reg [15:0] Q;
    
    initial begin
        Q = 16'b0;
    end
    
    always @(posedge Clock) begin
        if(E) begin
            case(FunSel)
                3'b000: Q = Q - 16'd1;
                3'b001: Q = Q + 16'd1;
                3'b010: Q = I;
                3'b011: Q = 16'b0;
                3'b100: Q = {8'b0, I[7:0]};                            
                3'b101: Q[7:0] = I[7:0]; 
                3'b110: Q[15:8] = I[7:0]; 
                3'b111: Q[15:0] = { {8{I[7]}}, I[7:0] };   
            endcase
        end
    end
    
    
endmodule
