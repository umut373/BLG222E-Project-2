`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2024 16:11:36
// Design Name: 
// Module Name: InstructionRegister
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


module InstructionRegister(I, Write, LH, Clock, IROut);
    input wire [7:0] I;
    input wire Write;
    input wire LH;
    input wire Clock;
    
    output reg [15:0] IROut;
    
    always @(posedge Clock) begin
        if(Write) begin
            case(LH)
                1'b0: IROut[7:0] = I;
                1'b1: IROut[15:8] = I;
            endcase
        end
    end
    
endmodule
