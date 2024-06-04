`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2024 18:14:53
// Design Name: 
// Module Name: ArithmeticLogicUnit
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


module ArithmeticLogicUnit(A, B, FunSel, WF, Clock, ALUOut, FlagsOut);
    input wire [15:0] A;
    input wire [15:0] B;
    input wire [4:0] FunSel;
    input wire WF;
    input wire Clock;
    
    output reg [15:0] ALUOut;
    output reg [3:0] FlagsOut; // Z|C|N|O
    
    reg Z, C, N, O;
    reg [15:0] comp; // for the complement of input
    
    initial begin
        ALUOut = 16'b0;
        FlagsOut = 4'b0;
        {Z, C, N, O} = FlagsOut;
    end
    
    always @(*) begin
        case(FunSel)
            5'b00000: ALUOut = {8'b0, A[7:0]};
            5'b00001: ALUOut = {8'b0, B[7:0]};
            5'b00010: ALUOut = {8'b0, ~A[7:0]};
            5'b00011: ALUOut = {8'b0, ~B[7:0]};
            5'b00100:  begin // ALUOut = A + B
                ALUOut = 15'b0;
                {C, ALUOut[7:0]} = A[7:0] + B[7:0];
                    if ((~A[7] == ALUOut[7]) && (~B[7] == ALUOut[7]))
                       O = 1;
                   else
                       O = 0;
            end
            5'b00101:  begin // ALUOut = A + B + Cin
                ALUOut = 15'b0;
                {C, ALUOut[7:0]} = A[7:0] + B[7:0] + FlagsOut[2];
                    if ((~A[7] == ALUOut[7]) && (~B[7] == ALUOut[7]))
                       O = 1;
                   else
                       O = 0;
            end
            5'b00110: begin // ALUOut = A - B
                comp = ~B;
                ALUOut = 15'b0;
                {C, ALUOut[7:0]} = A[7:0] + comp[7:0] + 1;
                if ((~A[7] == ALUOut[7]) && (B[7] == ALUOut[7]))
                    O = 1;
                else
                    O = 0;
            end
            5'b00111: ALUOut = {8'b0, A[7:0] & B[7:0]};
            5'b01000: ALUOut = {8'b0, A[7:0] | B[7:0]};
            5'b01001: ALUOut = {8'b0, A[7:0] ^ B[7:0]};
            5'b01010: ALUOut = {8'b0, ~(A[7:0] & B[7:0])};
            5'b01011: begin // LSL A
                ALUOut = {8'b0, A[6:0], 1'b0};
                C = A[7];
            end
            5'b01100: begin // LSR A
                ALUOut = {8'b0, 1'b0, A[7:1]};
                C = A[0];
            end
            5'b01101: begin // ASR A
                ALUOut = {8'b0, A[7], A[7:1]};
                C = A[0];
            end
            5'b01110: begin // CSL A
                C = A[7];
                ALUOut = {8'b0, A[6:0], FlagsOut[2]};
            end
            5'b01111: begin // CSR A
                C = A[0];
                ALUOut = {8'b0, FlagsOut[2], A[7:1]};
            end
            5'b10000: ALUOut = A;
            5'b10001: ALUOut = B;
            5'b10010: ALUOut = ~A; 
            5'b10011: ALUOut = ~B;
            5'b10100: begin // ALUOut = A + B
                {C, ALUOut} = A + B;
                if ((~A[15] == ALUOut[15]) && (~B[15] == ALUOut[15]))
                    O = 1;
                else
                    O = 0;
            end
            5'b10101: begin // ALUOut = A + B + Cin
                {C, ALUOut} = A + B + FlagsOut[2];
                if ((~A[15] == ALUOut[15]) && (~B[15] == ALUOut[15]))
                    O = 1;
                else
                    O = 0;
            end
            5'b10110: begin // ALUOut = A - B
                comp = ~B;
                {C, ALUOut} = A + comp + 1;
                if ((~A[15] == ALUOut[15]) && (B[15] == ALUOut[15]))
                    O = 1;
                else
                    O = 0;
            end
            5'b10111: ALUOut = A & B;
            5'b11000: ALUOut = A | B;
            5'b11001: ALUOut = A ^ B;
            5'b11010: ALUOut = ~(A & B);
            5'b11011: begin // LSL A
                ALUOut = {A[14:0], 1'b0};
                C = A[15];
            end
            5'b11100: begin // LSR A
                ALUOut = {1'b0, A[15:1]};
                C = A[0];
            end
            5'b11101: begin // ASR A
                ALUOut = {A[15], A[15:1]};
                C = A[0];
            end
            5'b11110: begin // CSL A
                C = A[15];
                ALUOut = {A[14:0], FlagsOut[2]};
            end
            5'b11111: begin // CSR A
                C = A[0];
                ALUOut = {FlagsOut[2], A[15:1]};
            end
        endcase
        
        if ((FunSel[4] && ALUOut == 15'b0) || (~FunSel[4] && ALUOut[7:0] == 8'b0))
            Z = 1;
        else
            Z = 0;    
        if ((FunSel != 5'b01101) && (FunSel != 5'b11101)) begin
            if ((FunSel[4] && ALUOut[15]) || (~FunSel[4] && ALUOut[7]))
                N = 1;
            else
                N = 0;
        end
    end
    
    always @(posedge Clock) begin
        if(WF) begin
            case (FunSel[3:0])
                4'b0100: begin
                    FlagsOut[0] = O;
                    FlagsOut[2] = C;
                end
                4'b0101: begin
                    FlagsOut[0] = O;
                    FlagsOut[2] = C;
                end
                4'b0110: begin
                    FlagsOut[0] = O;
                    FlagsOut[2] = C;
                end
                4'b1011: FlagsOut[2] = C;
                4'b1100: FlagsOut[2] = C;
                4'b1101: FlagsOut[2] = C;
                4'b1110: FlagsOut[2] = C;
                4'b1111: FlagsOut[2] = C;
            endcase
            
            if ((FunSel != 5'b01101) && (FunSel != 5'b11101))
                FlagsOut[1] = N;
                
            FlagsOut[3] = Z;
       end 
    end
    
endmodule
