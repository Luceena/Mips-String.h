module mips_top (
    input wire clock,
    input wire reset,

    output wire [31:0] PC_out,      // PC atual
    output wire [31:0] ALU_out,     // Saída da ULA
    output wire [31:0] DM_out       // Saída da memória de dados
);

    // -------------------------------------------------------
    // Fios internos
    wire [31:0] PC_next;
    wire [31:0] instruction;
    wire [31:0] regRead1;
    wire [31:0] regRead2;
    wire [31:0] writeDataReg;
    wire [31:0] signImm;
    wire [3:0]  aluControl;
    wire        regWrite;
    wire        memWrite;
    wire        memRead;
    wire        aluSrc;
    wire        memToReg;

    // PC incrementa de 4
    assign PC_next = PC_out + 32'd4;

    // -------------------------------------------------------
    // Instância do PC
    pc u_pc (
        .clock  (clock),
        .nextPC (PC_next),
        .PC     (PC_out)
    );

    // -------------------------------------------------------
    // Memória de instruções
    i_mem u_imem (
        .address (PC_out),
        .i_out   (instruction)
    );

    // -------------------------------------------------------
    // Unidade de controle
    ctrl u_ctrl (
        .opcode     (instruction[31:26]),
        .RegWrite   (regWrite),
        .MemWrite   (memWrite),
        .MemRead    (memRead),
        .ALUSrc     (aluSrc),
        .MemToReg   (memToReg)
    );

    // -------------------------------------------------------
    // Banco de registradores
    regfile u_regfile (
        .clock   (clock),
        .reset   (reset),
        .we      (regWrite),
        .ra1     (instruction[25:21]), // rs
        .ra2     (instruction[20:16]), // rt
        .wa      (instruction[15:11]), // rd
        .wd      (writeDataReg),
        .rd1     (regRead1),
        .rd2     (regRead2)
    );

    // -------------------------------------------------------
    // Imediato com extensão de sinal
    assign signImm = {{16{instruction[15]}}, instruction[15:0]};

    // -------------------------------------------------------
    // Unidade de controle da ULA
    ula_ctrl u_ula_ctrl (
        .funct   (instruction[5:0]),
        .alu_op  (instruction[31:26]),
        .aluCtrl (aluControl)
    );

    // -------------------------------------------------------
    // Mux da ULA (escolhe entre registrador ou imediato)
    wire [31:0] aluB_in;
    assign aluB_in = aluSrc ? signImm : regRead2;

    // -------------------------------------------------------
    // ULA
    ula u_ula (
        .A     (regRead1),
        .B     (aluB_in),
        .ctrl  (aluControl),
        .out   (ALU_out)
    );

    // -------------------------------------------------------
    // Memória de Dados
    d_mem u_dmem (
        .clock     (clock),
        .MemWrite  (memWrite),
        .MemRead   (memRead),
        .Address   (ALU_out),
        .WriteData (regRead2),
        .ReadData  (DM_out)
    );

    // -------------------------------------------------------
    // Mux Write-Back (resultado vai para o regfile)
    assign writeDataReg = memToReg ? DM_out : ALU_out;

endmodule

