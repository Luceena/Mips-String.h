module pc (
    input wire clock,            // Atualiza na borda de subida
    input wire [31:0] nextPC,    // Próximo valor do PC
    output reg [31:0] PC         // Valor atual do PC
);

    // Atualiza o PC apenas na borda de subida
    always @(posedge clock) begin
        PC <= nextPC;
    end

endmodule
