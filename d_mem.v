module d_mem #(
    parameter MEM_SIZE = 256     // número de PALAVRAS (32 bits cada)
)(
    input wire clock,
    input wire MemWrite,         // escrever?
    input wire MemRead,          // ler?
    input wire [31:0] Address,   // endereço vindo da ULA
    input wire [31:0] WriteData, // dado para escrever
    output wire [31:0] ReadData  // dado lido
);

    // RAM de 32 bits por palavra
    reg [31:0] mem [0:MEM_SIZE-1];

    wire [31:0] word_addr;
    assign word_addr = Address[31:2];  // ignora os dois últimos bits (4 bytes)

    // Escrita síncrona
    always @(posedge clock) begin
        if (MemWrite)
            mem[word_addr] <= WriteData;
    end

    // Leitura assíncrona
    assign ReadData = (MemRead) ? mem[word_addr] : 32'bz;

endmodule

