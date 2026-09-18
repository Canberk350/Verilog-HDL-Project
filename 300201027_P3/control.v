module control(in, regdest, alusrc, memtoreg, regwrite, 
               memread, memwrite, branch, aluop1, aluop2, branchnot,jump, jalfor);

input [7:0] in;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch,aluop1, aluop2,branchnot, jump, jalfor;

wire rformat, lw, sw, beq, bne, addi, j;
										     //30020127-> starts from 27
assign rformat = (~in[7]) & (~in[6]) & (~in[5]) & in[4] & in[3] & (~in[2]) & (in[1]) & (in[0]); // 00011011 = 27
assign lw = (~in[7]) & (~in[6]) & (~in[5]) & in[4] & in[3] & in[2] & (~in[1]) & (~in[0]); //00011100 = 28
assign sw = (~in[7]) & (~in[6]) & (~in[5]) & in[4] & in[3] & in[2] & (~in[1]) & in[0]; // 00011101 = 29
assign beq = (~in[7]) & (~in[6]) & (~in[5]) & in[4] & in[3] & in[2] & in[1] & (~in[0]); // 00011110 = 30
assign bne = (~in[7]) & (~in[6]) & (~in[5]) & in[4] & in[3] & in[2] & in[1] & in[0]; // 00011111 = 31
assign addi = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & (~in[3]) & (~in[2]) & (~in[1]) & (~in[0]); // 00100000 = 32
assign j = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & (~in[3]) & (~in[2]) & (~in[1]) & in[0]; // 00100001 = 33
assign jalfor = (~in[7]) & (~in[6]) & in[5] & (~in[4]) & (~in[3]) & (~in[2]) & in[1] & (~in[0]); // 00100010 = 34


assign regdest = rformat;
assign alusrc = lw | sw | addi;
assign memtoreg = lw;
assign regwrite = (rformat | lw | addi );
assign memread = lw;
assign memwrite = sw;
assign branch = beq;
assign branchnot = bne;
assign aluop1 = rformat;
assign aluop2 = beq | bne;
assign jump = j ;              
assign jalfor_out= jalfor;
assign jump =j;
endmodule