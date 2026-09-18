module alu32(alu_out, a, b, zout, alu_control,shamt);
output reg [31:0] alu_out;
input [31:0] a,b;
input [2:0] alu_control;
input [5:0] shamt;	//inst11_6
output zout;
reg zout;

 always @(a or b or alu_control)
begin
	case(alu_control)
	3'b001: alu_out = b << shamt;	//the shifted result is then written to the rd register
	3'b010: alu_out = b >> shamt;	//the shifted result is then written to the rd register
	3'b011: alu_out = ~(a | b); 
	3'b100: alu_out = a - b;
	3'b101: alu_out = a | b;
	3'b110: alu_out = a + b;
	default: alu_out=32'bx;
	endcase
zout=~(|alu_out);
end
endmodule


