module i_mem #(
    parameter MEM_SIZE = 256       // número máximo de instruções
)(
    input wire [31:0] address,     // Endereço vindo do PC
    output wire [31:0] i_out       // Instrução lida
);

    // Define a memória ROM
    reg [31:0] mem [0:MEM_SIZE-1];

    // Carrega instruções do arquivo externo
    initial begin
        $readmemb("instruction.list", mem);
    end

    // Como cada instrução tem 4 bytes, descartamos os 2 últimos bits
    assign i_out = mem[address[31:2]];

endmodule
