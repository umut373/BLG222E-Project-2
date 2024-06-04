`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 02.05.2024 16:42:13
// Design Name:
// Module Name: CPUSystem
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


module CPUSystem(Clock, Reset, T);
    input wire Clock;
    input wire Reset;
    
    output reg [7:0] T;
    
    reg [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [4:0] ALU_FunSel;
    reg ALU_WF;
    reg [1:0] ARF_OutCSel, ARF_OutDSel;
    reg [2:0] ARF_FunSel, ARF_RegSel;
    reg IR_LH, IR_Write;
    reg Mem_WR, Mem_CS;
    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;

    ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel), .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel), .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF), .ARF_OutCSel(ARF_OutCSel),
        .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel), .ARF_RegSel(ARF_RegSel), .IR_LH(IR_LH), .IR_Write(IR_Write),
        .Mem_WR(Mem_WR), .Mem_CS(Mem_CS), .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel), .Clock(Clock)
    );
    
    reg [5:0] D;
    reg [1:0] RSEL;
    reg S;
    reg [2:0] DSTREG, SREG1, SREG2;
    reg [7:0] _T = 8'b1;
    
    initial begin
        _T = 8'd1;
        _ALUSystem.ARF.PC.Q = 16'b0;
        _ALUSystem.ARF.SP.Q = 16'd255;
        IR_Write = 1'b0;
        Mem_CS = 1'b1;
        resetSel();
    end
    
    always @(*) begin
        if (~Reset) begin
            _T = 8'd1;
            _ALUSystem.ARF.PC.Q = 16'd0;
            _ALUSystem.ARF.SP.Q = 16'd255;
            _ALUSystem.ARF.AR.Q = 16'd0;
            _ALUSystem.RF.R1.Q = 16'd0;
            _ALUSystem.RF.R2.Q = 16'd0;
            _ALUSystem.RF.R3.Q = 16'd0;
            _ALUSystem.RF.R4.Q = 16'd0;
            _ALUSystem.ALU.ALUOut = 16'd0;
            _ALUSystem.ALU.FlagsOut = 4'd0;
            IR_Write = 1'b0;
            Mem_CS = 1'b1;
            resetSel();
        end
    end

    always @(posedge Clock) begin
        if (Reset) begin
            case (_T)
                8'd1: begin
                    T = _T;
                    RF_RegSel = 4'b1111;
                    RF_ScrSel = 4'b1111;
                
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b1;
                    IR_LH = 1'b0;
                    ARF_OutDSel = 2'b00;
                    
                    ARF_RegSel = 3'b011;
                    ARF_FunSel = 3'b001;
                    
                    _T = 8'd2;
                end
                8'd2: begin
                    T = _T;
                    IR_LH = 1'b1;
                    
                    _T = 8'd4;
                end
                8'd4: begin
                    T = _T;
                    IR_Write = 1'b0;
                    resetSel();
                    
                    decode(_ALUSystem.IR.IROut);

                    case (D)
                        6'h00: branch_1();
                        6'h01: begin
                            if (~_ALUSystem.ALU.FlagsOut[3])
                                branch_1();
                            else _T =  8'd1;
                        end
                        6'h02: begin
                            if (_ALUSystem.ALU.FlagsOut[3])
                                branch_1();
                            else _T =  8'd1;
                        end
                        6'h03: begin
                            inc_dec_sp(1'b0);
                            _T = 8'd8;
                        end
                        6'h04: push_1();
                        6'h05: inc_dec_1();
                        6'h06: inc_dec_1();
                        6'h07: one_sreg_1();
                        6'h08: one_sreg_1();
                        6'h09: one_sreg_1();
                        6'h0A: one_sreg_1();
                        6'h0B: one_sreg_1();
                        6'h0C: two_sreg_1();
                        6'h0D: two_sreg_1();
                        6'h0E: one_sreg_1();
                        6'h0F: two_sreg_1();
                        6'h10: two_sreg_1();
                        6'h11: mov(1'b1);
                        6'h12: ldr_1();
                        6'h13: str_1();
                        6'h14: mov(1'b0);
                        6'h15: two_sreg_1();
                        6'h16: two_sreg_1();
                        6'h17: two_sreg_1();
                        6'h18: one_sreg_1();
                        6'h19: two_sreg_1();
                        6'h1A: two_sreg_1();
                        6'h1B: two_sreg_1();
                        6'h1C: two_sreg_1();
                        6'h1D: two_sreg_1();
                        6'h1E: branch_1();
                        6'h1F: begin
                            inc_dec_sp(1'b0);
                            _T = 8'd8;
                        end
                        6'h20: ldrim();
                        6'h21: strim_1();
                    endcase
                end
                8'd8: begin
                    T = _T;
                    resetSel();

                    case (D)
                        6'h00: branch_2();
                        6'h01: branch_2();
                        6'h02: branch_2();
                        6'h03: pop_1();
                        6'h04: push_2();
                        6'h05: inc_dec_2(3'b001);
                        6'h06: inc_dec_2(3'b000);
                        6'h07: one_sreg_2(5'b11011, 1'b0);
                        6'h08: one_sreg_2(5'b11100, 1'b0);
                        6'h09: one_sreg_2(5'b11101, 1'b0);
                        6'h0A: one_sreg_2(5'b11110, 1'b0);
                        6'h0B: one_sreg_2(5'b11111, 1'b0);
                        6'h0C: two_sreg_2();
                        6'h0D: two_sreg_2();
                        6'h0E: one_sreg_2(5'b10010, 1'b0);
                        6'h0F: two_sreg_2();
                        6'h10: two_sreg_2();
                        6'h12: ldr_2();
                        6'h13: str_2();
                        6'h15: two_sreg_2();
                        6'h16: two_sreg_2();
                        6'h17: two_sreg_2();
                        6'h18: one_sreg_2(5'b10000, S);
                        6'h19: two_sreg_2();
                        6'h1A: two_sreg_2();
                        6'h1B: two_sreg_2();
                        6'h1C: two_sreg_2();
                        6'h1D: two_sreg_2();
                        6'h1E: bx_1();
                        6'h1F: bl_1();
                        6'h21: strim_2();
                    endcase
                end
                8'd16: begin
                    T = _T;
                    resetSel();

                    case (D)
                        6'h00: branch_3();
                        6'h01: branch_3();
                        6'h02: branch_3();
                        6'h03: pop_2();
                        6'h0C: two_sreg_3(5'b10111, 1'b0);
                        6'h0D: two_sreg_3(5'b11000, 1'b0);
                        6'h0F: two_sreg_3(5'b11001, 1'b0);
                        6'h10: two_sreg_3(5'b11010, 1'b0);
                        6'h15: two_sreg_3(5'b10100, 1'b0);
                        6'h16: two_sreg_3(5'b10101, 1'b0);
                        6'h17: two_sreg_3(5'b10110, 1'b0);
                        6'h19: two_sreg_3(5'b10100, S);
                        6'h1A: two_sreg_3(5'b10110, S);
                        6'h1B: two_sreg_3(5'b10111, S);
                        6'h1C: two_sreg_3(5'b11000, S);
                        6'h1D: two_sreg_3(5'b11001, S);
                        6'h1E: bx_2();
                        6'h1F: bl_2();
                        6'h21: strim_3();
                    endcase
                end
                8'd32: begin
                    T = _T;
                    resetSel();

                    case (D)
                        6'h1E: bx_3();
                        6'h1F: bl_3();
                        6'h21: strim_4();
                    endcase
                end
                 8'd64: begin
                    T = _T;
                    resetSel();

                    case (D)
                        6'h21: begin
                            strim_5();
                        end
                    endcase
                end
                        
                default: resetSel();
            endcase
        end
    end

    task decode (input [15:0] IR);
    begin
        D = IR[15:10];

        RSEL = IR[9:8];

        S = IR[9];
        DSTREG = IR[8:6];
        SREG1 = IR[5:3];
        SREG2 = IR[2:0];
    end
    endtask

    task resetSel ();
    begin
        Mem_CS = 1'b1;

        ARF_RegSel = 3'b111;
        RF_RegSel = 4'b1111;
        RF_ScrSel = 4'b1111;
    end
    endtask

    task branch_1 ();
    begin
        ARF_OutCSel = 2'b00; //PC

        MuxASel = 2'b01; // OutC

        RF_ScrSel = 4'b0111; //S1
        RF_FunSel = 3'b010;

        _T = 8'd8;
        end
    endtask

    task branch_2 ();
    begin
        MuxASel = 2'b11; //IROut

        RF_ScrSel = 4'b1011; //S2
        RF_FunSel = 3'b111;

        _T = 8'd16;
    end
    endtask

    task branch_3 ();
    begin
        RF_OutASel = 3'b100; //S1
        RF_OutBSel = 3'b101; //S2

        MuxBSel = 2'b00;
        ARF_RegSel = 3'b011; //PC
        ARF_FunSel = 3'b010;

        ALU_FunSel = 5'b10100;
        ALU_WF = 1'b0;

        _T = 8'd1;
    end
    endtask

    task inc_dec_sp (input id);
    begin
        ARF_RegSel = 3'b110; //SP
        ARF_FunSel = id ? 3'b000 : 3'b001;
    end
    endtask

    task  pop_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read
        
        ARF_OutDSel = 2'b11; //SP
        MuxASel = 2'b10; //MemOut

        case (RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = 3'b100;

        inc_dec_sp(1'b0);

        _T = 8'd16;
    end
    endtask

    task pop_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read
        
        ARF_OutDSel = 2'b11; //SP
        MuxASel = 2'b10; //MemOut

        case (RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = 3'b110;

        _T = 8'd1;
    end
    endtask

    task push_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write
        
        ARF_OutDSel = 2'b11; //SP
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b1; //MSB
        
        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        inc_dec_sp(1'b1);

        _T = 8'd8;
    end
    endtask

    task push_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write
        
        ARF_OutDSel = 2'b11; //SP
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b0; //LSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        inc_dec_sp(1'b1);

        _T = 8'd1;
    end
    endtask

    task inc_dec_1 ();
    begin
        if (DSTREG[2]) begin
            case (DSTREG)
                3'b100: RF_RegSel = 4'b0111; //R1
                3'b101: RF_RegSel = 4'b1011; //R2
                3'b110: RF_RegSel = 4'b1101; //R3
                3'b111: RF_RegSel = 4'b1110; //R4
            endcase
            RF_FunSel = 3'b010;
        end
        else begin
            case (DSTREG)
                3'b000: ARF_RegSel = 3'b011; //PC
                3'b001: ARF_RegSel = 3'b011; //PC
                3'b010: ARF_RegSel = 3'b110; //SP
                3'b011: ARF_RegSel = 3'b101; //AR
            endcase
            ARF_FunSel = 3'b010;
        end

        if (SREG1[2]) begin
            RF_OutASel = {1'b0, SREG1[1:0]};
            ALU_FunSel = 5'b10000;
            ALU_WF = 1'b0;

            if (DSTREG[2])
                MuxASel = 2'b00; //ALUOut
            else
                MuxBSel = 2'b00; //ALUOut
        end
        else begin
            case (SREG1)
                3'b000: ARF_OutCSel = 2'b00; //PC
                3'b001: ARF_OutCSel = 2'b00; //PC
                3'b010: ARF_OutCSel = 2'b11; //SP
                3'b011: ARF_OutCSel = 2'b10; //AR
            endcase

            if (DSTREG[2])
                MuxASel = 2'b01; //OutC
            else
                MuxBSel = 2'b01; //OutC
        end

        _T = 8'd8;
    end
    endtask

    task inc_dec_2 (input [2:0] opcode);
    begin
        if (DSTREG[2]) begin
            case (DSTREG)
                3'b100: RF_RegSel = 4'b0111; //R1
                3'b101: RF_RegSel = 4'b1011; //R2
                3'b110: RF_RegSel = 4'b1101; //R3
                3'b111: RF_RegSel = 4'b1110; //R4
            endcase
            RF_FunSel = opcode;
        end
        else begin
            case (DSTREG)
                3'b000: ARF_RegSel = 3'b011; //PC
                3'b001: ARF_RegSel = 3'b011; //PC
                3'b010: ARF_RegSel = 3'b110; //SP
                3'b011: ARF_RegSel = 3'b101; //AR
            endcase
            ARF_FunSel = opcode;
        end
        
        _T = 8'd1;
    end
    endtask

    task one_sreg_1 ();
    begin
        if (~SREG1[2]) begin
            case (SREG1)
                3'b000: ARF_OutCSel = 2'b00; //PC
                3'b001: ARF_OutCSel = 2'b00; //PC
                3'b010: ARF_OutCSel = 2'b11; //SP
                3'b011: ARF_OutCSel = 2'b10; //AR
            endcase
            
            RF_ScrSel = 4'b0111; //S1
            MuxASel = 2'b01; //OutC
            RF_FunSel = 3'b010;
        end

        _T = 8'd8;
    end
    endtask

    task one_sreg_2 (input [4:0] opcode, input s);
    begin
        if (SREG1[2])
            RF_OutASel = {1'b0, SREG1[1:0]};
        else
            RF_OutASel = 3'b100; //S1
        
        if (DSTREG[2]) begin
            case (DSTREG)
                3'b100: RF_RegSel = 4'b0111; //R1
                3'b101: RF_RegSel = 4'b1011; //R2
                3'b110: RF_RegSel = 4'b1101; //R3
                3'b111: RF_RegSel = 4'b1110; //R4
            endcase
            RF_FunSel = 3'b010;
            MuxASel = 2'b00; //ALUOut
        end
        else begin
            case (DSTREG)
                3'b000: ARF_RegSel = 3'b011; //PC
                3'b001: ARF_RegSel = 3'b011; //PC
                3'b010: ARF_RegSel = 3'b110; //SP
                3'b011: ARF_RegSel = 3'b101; //AR
            endcase
            ARF_FunSel = 3'b010;
            MuxBSel = 2'b00; //ALUOut
        end
        ALU_FunSel = opcode;
        ALU_WF = s;
        
        _T = 8'd1;
    end
    endtask
 
    task two_sreg_1 ();
    begin
        if (~SREG1[2]) begin
            case (SREG1)
                3'b000: ARF_OutCSel = 2'b00; //PC
                3'b001: ARF_OutCSel = 2'b00; //PC
                3'b010: ARF_OutCSel = 2'b11; //SP
                3'b011: ARF_OutCSel = 2'b10; //AR
            endcase
            
            RF_ScrSel = 4'b0111; //S1
            MuxASel = 2'b01; //OutC
            RF_FunSel = 3'b010;
        end

        _T = 8'd8;
    end
    endtask

    task two_sreg_2 ();
    begin
       if (~SREG2[2]) begin
            case (SREG2)
                3'b000: ARF_OutCSel = 2'b00; //PC
                3'b001: ARF_OutCSel = 2'b00; //PC
                3'b010: ARF_OutCSel = 2'b11; //SP
                3'b011: ARF_OutCSel = 2'b10; //AR
            endcase
            
            RF_ScrSel = 4'b1011; //S2
            MuxASel = 2'b01; //OutC
            RF_FunSel = 3'b010;
        end

        _T = 8'd16;
    end
    endtask

    task two_sreg_3 (input [4:0] opcode, input s);
    begin
        if (SREG1[2]) 
            RF_OutASel = {1'b0, SREG1[1:0]};
        else
            RF_OutASel = 3'b100; //S1

        if (SREG2[2])
            RF_OutBSel = {1'b0, SREG2[1:0]};
        else
            RF_OutBSel = 3'b101; //S2

        if (DSTREG[2]) begin
            case (DSTREG)
                3'b100: RF_RegSel = 4'b0111; //R1
                3'b101: RF_RegSel = 4'b1011; //R2
                3'b110: RF_RegSel = 4'b1101; //R3
                3'b111: RF_RegSel = 4'b1110; //R4
            endcase
            RF_FunSel = 3'b010;
            MuxASel = 2'b00; //ALUOut
        end
        else begin
            case (DSTREG)
                3'b000: ARF_RegSel = 3'b011; //PC
                3'b001: ARF_RegSel = 3'b011; //PC
                3'b010: ARF_RegSel = 3'b110; //SP
                3'b011: ARF_RegSel = 3'b101; //AR
            endcase
            ARF_FunSel = 3'b010;
            MuxBSel = 2'b00; //ALUOut
        end
        ALU_FunSel = opcode;
        ALU_WF = s;
        
        _T = 8'd1;
    end
    endtask

    task mov (input lh);
    begin
        case(RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = lh ? 3'b110 : 3'b101;

        MuxASel = 2'b11; //IROut

        _T = 8'd1;
    end
    endtask

    task ldr_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read

        ARF_OutDSel = 2'b10; //AR
        MuxASel = 2'b10; //MemOut

        case (RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = 3'b100;

        inc_dec_sp(1'b0);

        _T = 8'd8;
    end
    endtask

    task ldr_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read

        ARF_OutDSel = 2'b10; //AR
        MuxASel = 2'b10; //MemOut

        case (RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = 3'b110;

        inc_dec_sp(1'b1);

        _T = 8'd1;
    end
    endtask

    task str_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write

        ARF_OutDSel = 2'b10; //AR
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b0; //LSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        inc_dec_sp(1'b0);

        _T = 8'd8;
    end
    endtask

    task str_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write

        ARF_OutDSel = 2'b10; //AR
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b1; //MSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        inc_dec_sp(1'b1);

        _T = 8'd1;
    end
    endtask

    task bx_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write
        
        ARF_OutDSel = 2'b11; //SP
        RF_OutASel = 3'b100; //S1
        MuxCSel = 1'b1; //MSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        inc_dec_sp(1'b1);

        _T = 8'd16;
    end
    endtask

    task bx_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write
        
        ARF_OutDSel = 2'b11; //SP
        RF_OutASel = 3'b100; //S1
        MuxCSel = 1'b0; //LSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;
        
        inc_dec_sp(1'b1);

        _T = 8'd32;
    end
    endtask

    task bx_3 ();
    begin
        ARF_RegSel = 3'b011; //PC
        ARF_FunSel = 3'b010;

        RF_OutASel = {1'b0, RSEL};
        MuxBSel = 2'b00; //ALUOut

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        _T = 8'd1;
    end
    endtask

    task bl_1 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read
        
        ARF_OutDSel = 2'b11; //SP
        MuxBSel = 2'b10; //MemOut

        RF_ScrSel = 4'b0111; //S1
        RF_FunSel = 3'b100;

        inc_dec_sp(1'b0);

        _T = 8'd16;
    end
    endtask

    task bl_2 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b0; //Read
        
        ARF_OutDSel = 2'b11; //SP
        MuxBSel = 2'b10; //MemOut

        RF_ScrSel = 4'b0111; //S1
        RF_FunSel = 3'b110;

        _T = 8'd32;
    end
    endtask

    task bl_3 ();
    begin
        ARF_RegSel = 3'b011; //PC
        ARF_FunSel = 3'b010;

        RF_OutASel = 3'b100; //S1
        MuxBSel = 2'b00; //ALUOut

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        _T = 8'd1;
    end
    endtask

    task ldrim ();
    begin
        case (RSEL)
            2'b00: RF_RegSel = 4'b0111; //R1
            2'b01: RF_RegSel = 4'b1011; //R2
            2'b10: RF_RegSel = 4'b1101; //R3
            2'b11: RF_RegSel = 4'b1110; //R4
        endcase
        RF_FunSel = 3'b100;

        MuxASel = 2'b11; //IROut

        _T = 8'd1;
    end
    endtask

    task strim_1 ();
    begin
        RF_ScrSel = 4'b0111; //S1
        RF_FunSel = 3'b010;
        
        ARF_OutCSel = 2'b10; //AR
        MuxASel = 2'b01; //OutC

        _T = 8'd8;
    end
    endtask

    task strim_2 ();
    begin
        RF_ScrSel = 4'b1011; //S2
        RF_FunSel = 3'b010;
        
        MuxASel = 2'b11; //IROut

        _T = 8'd16;
    end
    endtask

    task strim_3 ();
    begin
        RF_OutASel = 3'b100; //S1
        RF_OutBSel = 3'b101; //S2

        ALU_FunSel = 5'b10100;
        ALU_WF = 1'b0;

        ARF_RegSel = 3'b101; //AR
        ARF_FunSel = 3'b010;

        MuxBSel = 2'b00; //ALUOut

        _T = 8'd32;
    end
    endtask

    task strim_4 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write

        ARF_OutDSel = 2'b10; //AR
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b0; //LSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        ARF_RegSel = 3'b101; //AR
        ARF_FunSel = 3'b001;

        _T = 8'd64;
    end
    endtask

    task strim_5 ();
    begin
        Mem_CS = 1'b0;
        Mem_WR = 1'b1; //Write

        ARF_OutDSel = 2'b10; //AR
        RF_OutASel = {1'b0, RSEL};
        MuxCSel = 1'b1; //MSB

        ALU_FunSel = 5'b10000;
        ALU_WF = 1'b0;

        ARF_RegSel = 3'b101; //AR
        ARF_FunSel = 3'b001;

        _T = 8'd1;
    end
    endtask

endmodule