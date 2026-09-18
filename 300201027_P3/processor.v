module processor;
reg clk;
reg [31:0] pc;
reg [7:0] datmem[0:63], mem[0:31];
wire [31:0] dataa, datab;
wire [31:0] out2, out3, out4, out5, out6;
wire [31:0] sum, extad, adder1out, adder2out,sextad,readdata,jump_address,jalfor_address;

wire [23:0] inst23_0;
wire [7:0] inst31_24;
wire [3:0] inst23_20, inst19_16, inst15_12, out1;
wire [5:0] inst11_6;
wire [15:0] inst15_0;
wire [31:0] instruc, dpack;
wire [2:0] gout;

wire cout, zout, nout, pcsrc, regdest, alusrc, memtoreg, regwrite, memread,
     memwrite, branch, branchnot, pcsrctwo, aluop1, aluop0, jump, jalfor_active;

reg [31:0] jalfor_return_addr = 0;
reg [3:0] jalfor_counter = 0, necl_counter = 0, buffer = 0; //jalfor loop counters, nested control loop counter, inner loop counter
reg jalfor_active_flag = 0;

reg [15:0] jalfor_addr_latch;


reg [31:0] registerfile [0:15];
reg [31:0] t_mem;
integer i, c;



always @(posedge clk) begin
    if (memwrite) begin 
        datmem[sum[5:0]+3] <= datab[7:0];
        datmem[sum[5:0]+2] <= datab[15:8];
        datmem[sum[5:0]+1] <= datab[23:16];
        datmem[sum[5:0]] <= datab[31:24];
    end
end

assign instruc = {mem[pc[4:0]],
                 mem[pc[4:0]+1],
                 mem[pc[4:0]+2],
                 mem[pc[4:0]+3]};

assign inst31_24 = instruc[31:24];
assign inst23_20 = instruc[23:20];
assign inst19_16 = instruc[19:16];
assign inst15_12 = instruc[15:12];
assign inst15_0 = instruc[15:0];
assign inst23_0 = instruc[23:0];
assign inst11_6 = instruc[11:6];

assign dataa = registerfile[inst23_20];
assign datab = registerfile[inst19_16];

assign dpack = {datmem[sum[5:0]],
               datmem[sum[5:0]+1],
               datmem[sum[5:0]+2],
               datmem[sum[5:0]+3]};

assign jump_address = {8'b0, inst23_0};
assign jalfor_address = {16'b0, inst15_0};


assign pcsrc = branch && zout;
assign pcsrctwo = branchnot && ~zout;

mult2_to_1_5  mult1(out1, instruc[19:16], instruc[15:12], regdest);	//in between reg and mem
mult2_to_1_32 mult2(out2, datab, extad, alusrc);			//in between reg below alu
mult2_to_1_32 mult3(out3, sum, dpack, memtoreg);
mult2_to_1_32 mult4(out4, adder1out, adder2out, pcsrc);	// 
mult2_to_1_32 mult5(out5, out6, jump_address, jump);	// right top most 
mult2_to_1_32 mult6(out6, out4, adder2out, pcsrctwo); //left of rigth top most


always @(posedge clk) begin
    if (jalfor_active && !jalfor_active_flag) begin
        jalfor_return_addr <= pc + 4;   //return address
        jalfor_addr_latch <= inst15_0;
        pc <= jalfor_address;           //jalfor jump
        jalfor_counter <= inst23_20;    //nr
        buffer <= inst19_16;
        necl_counter <= inst19_16;      //necl
        jalfor_active_flag <= 1;
    end 

    else if (jalfor_active_flag) begin
        if (necl_counter > 1) begin
            necl_counter <= necl_counter - 1;
            pc <= pc + 4;              //iterate for loop
        end 
        else if (jalfor_counter > 1) begin
            jalfor_counter <= jalfor_counter - 1; 
            //necl_counter <= inst19_16;
            necl_counter <= buffer;
            //pc <= jalfor_address;
            pc <= {16'b0, jalfor_addr_latch};
        end 
        else begin
            pc <= jalfor_return_addr;//loop end
            jalfor_active_flag <= 0;
        end
    end

    else begin
        pc <= out5; //jump, branch etc.
    end
end



always @(posedge clk) begin
    if (regwrite)
        registerfile[out1] <= out3;
end


//module instantiations
alu32 alu1(sum, dataa, out2, zout, gout, inst11_6);
adder add1(pc, 32'h4, adder1out);
adder add2(adder1out, sextad, adder2out);


control cont(instruc[31:24], regdest, alusrc, memtoreg, regwrite, 
             memread, memwrite, branch, aluop1, aluop0, branchnot, jump,jalfor_active);


signext sext(instruc[15:0], extad);


alucont acont(aluop1, aluop0, instruc[3], instruc[2], instruc[1], instruc[0], gout);
shift shift2(sextad, extad);

//memory and register initialization
initial begin
    $readmemh("initDataMemory.dat", datmem);
    $readmemh("initInstructionMemory_1.dat", mem);	//initInstructionMemory_1 ; initInstructionMemory_2 ; initInstructionMemory_3 ; test
    $readmemh("initRegisterMemory.dat", registerfile);

    for (i = 0; i < 31; i = i + 1)
        $display("Instruction Memory[%0d]= %h  ", i, mem[i], 
                 "Data Memory[%0d]= 0x%h   ", i, datmem[i], 
                 "Register[%0d]= 0x%h ", i, registerfile[i]);

    c = 0;
    t_mem = 0;

    for (i = 0; i < 31; i = i + 1) begin
        t_mem = {t_mem[23:0], mem[i]}; 
        c = c + 1;
        if (c == 4) begin
            c = 0;
            $display("Instruction Memory[%0d]= 0x%h [%b %b %b %b %b %b]", 
                      i - 3, t_mem,
                      t_mem[31:24], t_mem[23:20], 
                      t_mem[19:16], t_mem[15:12], 
                      t_mem[5:0], t_mem[15:0]);
            t_mem = 0; 
        end
    end
end

//simulation timing control
initial begin		//use in 500ps for sim
    pc = 0;
    #1000 $finish;
end

initial begin
    clk = 0;
    forever #20 clk = ~clk;
end

//output
initial begin
    $monitor($time, " PC %h [%d]", pc, pc, 
             "  SUM %h", sum, 
             "   INST %h [%b %b %b %b %b %b]", instruc[31:0], 
             inst31_24, inst23_20, inst19_16, inst15_12, 
             instruc[5:0], inst15_0,
             "   REGISTER %h %h %h %h %p DATA MEMORY %p", 
             registerfile[4], registerfile[5], registerfile[6], 
             registerfile[1], registerfile, datmem);

end
endmodule






