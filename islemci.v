`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2021 10:34:30
// Design Name: 
// Module Name: risc_v
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


module islemci(
    input saat,reset,
    input [31:0] buyruk,
    output reg signed [31:0] ps, yazmac_on
    );
    reg[31:0] ps_next;
    reg signed [31:0] yazmac[31:0],yazmac_n[31:0];
    reg [20:0]imm ;
    integer i = 0;
    initial begin
        for(i = 0; i<32; i = i+1)begin
                yazmac[i] = 0;
                yazmac_n[i] = 0;
        end
         

        ps_next = 0;
        ps = 0;
        yazmac[0] = 0;
        yazmac_n[0] = 0;
    end
    always@*begin
        for(i = 0; i<32; i = i+1)begin
                yazmac_n[i] = yazmac[i];
        end
        ps_next = ps;
        if(buyruk[6:0] == 7'b0110011) begin//R-type 7 bit funct7 5 bit rs2 5 bit rs1 3 bit func3 5 bit rd 7 bit opcode
            if(buyruk[31-:7] == 7'b0000000 && buyruk[14-:3] == 3'b000) //add
                yazmac_n[buyruk[11-:5]] =  yazmac[buyruk[24-:5]] + yazmac[buyruk[19-:5]];
            else if(buyruk[31-:7] == 7'b0100000 && buyruk[14-:3] == 3'b000) //sub
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] - yazmac[buyruk[24-:5]];
            else if(buyruk[31-:7] == 7'b0000000 && buyruk[14-:3] == 3'b100) // xor
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] ^ yazmac[buyruk[24-:5]];
            else if(buyruk[31-:7] == 7'b0000000 && buyruk[14-:3] == 3'b111) // and
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] & yazmac[buyruk[24-:5]];
            else if(buyruk[31-:7] == 7'b0100000 && buyruk[14-:3] == 3'b101) // SRA
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] >>> yazmac[buyruk[24-:5]][4:0];
            else if(buyruk[31-:7] == 7'b0000000 && buyruk[14-:3] == 3'b101) // SRL
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] >> yazmac[buyruk[24-:5]][4:0];
            ps_next = ps + 4;    
        end
        else if(buyruk[6:0] == 7'b0010011) begin//I-type 12 bit imm 5 bit rs1 3 bit func3 5 bit rd 7 bit opcode
            if(buyruk[14-:3] == 3'b000) //addi
                yazmac_n[buyruk[11-:5]] = {{22{buyruk[31]}}, buyruk[30:20]} + yazmac[buyruk[19-:5]];
            else if(buyruk[14-:3] == 3'b100) // xori
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] ^ {{21{buyruk[31]}}, buyruk[30:20]};
            else if(buyruk[31-:7] == 7'b0100000 && buyruk[14-:3] == 3'b101) // SRAI
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] >>> buyruk[24-:5];
            else if(buyruk[31-:7] == 7'b0000000 && buyruk[14-:3] == 3'b101) // SRLI
                yazmac_n[buyruk[11-:5]] = yazmac[buyruk[19-:5]] < {{21{buyruk[31]}}, buyruk[30:20]} ? 32'b1 : 32 'b0;
            ps_next = ps + 4; 
        end
        else if(buyruk[6:0] == 7'b1100011) begin//B-type 31:30 bit imm[12] 30:25 bit imm[10:5] 24:20 bit rs2 19:15 bit rs1 14:12 bit func3 11:8 imm[4:1] 7:6 bit imm[11] 7 bit opcode

            if(buyruk[14-:3] == 3'b000)begin//BEQ
                if(yazmac[buyruk[24-:5]] != yazmac[buyruk[19-:5]])begin
                    ps_next = ps + 4;
                    end
                 else
                    ps_next = ps + ({buyruk[31],  buyruk[7], buyruk[30:25], buyruk[11:8]} * 4) ;
            end
          else if(buyruk[14-:3] == 3'b101)begin//BEG
                if(yazmac[buyruk[19-:5]] >= yazmac[buyruk[24-:5]])
                   ps_next = ps + ({buyruk[31],  buyruk[7], buyruk[30:25], buyruk[11:8]} * 4) ;
                 else                    
                    ps_next = ps + 4;
            end
           else if(buyruk[14-:3] == 3'b100)begin//BLT
                if( yazmac[buyruk[19-:5]] < yazmac[buyruk[24-:5]])
                    ps_next = ps + ({buyruk[31],  buyruk[7], buyruk[30:25], buyruk[11:8]} * 4) ;
                 else
                    ps_next = ps + 4;
            end
            end
             else if(buyruk[6:0] == 7'b1101111) begin// J type 31.bit imm[20] 30:21 bit imm[10:1] 20.bit imm[11] 19:12 bit imm[19:12] gerisi ayný

                ps_next = ps + { {12{buyruk[31]}}, buyruk[19:12], buyruk[20], buyruk[30:21], 1'b0 }; 
                yazmac_n[buyruk[11-:5]] = ps + 4;

             end
             else if(buyruk[6:0] == 7'b1100111) begin //jalr 
                yazmac_n[buyruk[11-:5]] = ps + 4;
                ps_next = yazmac[buyruk[19-:5]] + ({{21{buyruk[31]}}, buyruk[30:20]});           
             end
        yazmac_n[0] = 0;
    end
    
    
    always@(posedge saat)begin
        if(reset)begin
            yazmac_on <= 0;
            imm <= 0;
            ps <= 0; 
            for(i = 0; i<32; i = i+1)begin
                yazmac[i] <= 0;
            end
        end
        else begin
            yazmac_on <= yazmac_n[10];
            imm <= 0;
            ps <= ps_next; 
            for(i = 0; i<32; i = i+1)begin
                yazmac[i] <= yazmac_n[i];
            end
        end
    end
endmodule
