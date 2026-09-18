module alucont(aluop1,aluop0,f3,f2,f1,f0,gout);
input aluop1,aluop0,f3,f2,f1,f0;
output [2:0] gout;
reg [2:0] gout;

always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
	if(~(aluop1|aluop0)) 			//aluop=00,add(sw,lw and addi)
		gout=3'b110;
	if(aluop0) 				//aluop=x1,substract(beq and bne)
		gout=3'b100;
	if(aluop1) 				//aluop=1x,r-type
	begin					
		if (~(f3|f2|f1|f0)) 		//function fields;
			gout=3'b110;		//0000,add
		if (f0 & ~(f1)) 		
			gout=3'b001;		//0001,sll
		if (f1 & ~(f0)) 		
			gout=3'b010;		//0010,srl 
		if ((f0) & f1 & (~f2) & (~f3)) 	 
			gout=3'b011;		//0011,nor
		if (f2 & ~(f0)) 		
			gout=3'b100;		//0100,sub
		if (f2 & f0) 			
			gout=3'b101;		//0101,or
		end
	end
endmodule
