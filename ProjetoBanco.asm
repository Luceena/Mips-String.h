.data
# Configurações
MAX_CLIENTES:       .word 50
MAX_TRANSACOES:     .word 100
LIMITE_PADRAO:      .word 150000
JUROS_INTERVALO:    .word 60
TAXA_JUROS:         .float 0.01

# Estrutura
clientes:           .space 5000
num_clientes:       .word 0
transacoes_debito:  .space 2400
transacoes_credito: .space 2400
num_trans_debito:   .word 0
num_trans_credito:  .word 0
prox_debito:        .word 0
prox_credito:       .word 0

# Data e Hora
data_hora:          .asciiz "01012025000000"
ultimo_juros:       .word 0
padrao_data:        .asciiz "01012025000000"

# Textos/Strings
banner:             .asciiz "\n=== BANCO VIA SHELL ===\n> "
msg_sucesso:        .asciiz "Operação realizada com sucesso!\n"
msg_cpf_existe:     .asciiz "ERRO: Já existe conta neste CPF\n"
msg_conta_uso:      .asciiz "ERRO: Número da conta já em uso\n"
msg_cliente_inex:   .asciiz "ERRO: Cliente inexistente\n"
msg_saldo_insuf:    .asciiz "ERRO: Saldo insuficiente\n"
msg_limite_insuf:   .asciiz "ERRO: Limite insuficiente\n"
msg_comando_inv:    .asciiz "ERRO: Comando inválido\n"
msg_confirmacao:    .asciiz "Confirma operação? (S/N): "

# Comandos (Retornar o que est áacontecendo na máquina)
cmd_cadastrar:      .asciiz "conta_cadastrar"
cmd_sacar:          .asciiz "sacar"
cmd_depositar:      .asciiz "depositar"
cmd_extrato_debito: .asciiz "debito_extrato"
cmd_extrato_credito: .asciiz "credito_extrato"
cmd_pagar_fatura:   .asciiz "pagar_fatura"
cmd_alterar_limite: .asciiz "alterar_limite"
cmd_fechar_conta:   .asciiz "conta_fechar"
cmd_data_hora:      .asciiz "data_hora"
cmd_salvar:         .asciiz "salvar"
cmd_recarregar:     .asciiz "recarregar"

# Buffers
buffer:             .space 256
buffer_conta:       .space 12
buffer_cpf:         .space 12
buffer_nome:        .space 50
buffer_valor:       .space 10

# Base para testar o "User"
msg_testando:       .asciiz "=== TESTANDO SISTEMA ===\n"
prompt_cpf:         .asciiz "Digite o CPF: "
prompt_conta:       .asciiz "Digite a conta (6 digitos): "
prompt_nome:        .asciiz "Digite o nome: "
resultado_dv:       .asciiz "Digito verificador: "

cpf_teste:          .asciiz "12345678901"
conta_teste:        .asciiz "123456"
nome_teste:         .asciiz "Joao Silva"

.text
.globl main

main:
    jal inicializar_sistema
    
    # >>> TESTE AUTOMÁTICO<<<
    # jal testar_sistema
    
    # >>> TESTE INTERATIVO <<<
    jal teste_interativo
    
    jal recarregar_dados
    
main_loop:
    # Banner
    li $v0, 4
    la $a0, banner
    syscall
    
    # Ler comando
    li $v0, 8
    la $a0, buffer
    li $a1, 256
    syscall
    
    # Processar comando
    jal processar_comando
    
    # Atualizar sistema
    jal atualizar_sistema
    
    j main_loop

# Inicio do Sistema
inicializar_sistema:
    sw $zero, prox_debito
    sw $zero, prox_credito
    sw $zero, ultimo_juros
    
    # Verificar se data/hora está vazia
    la $t0, data_hora
    lb $t1, 0($t0)
    bnez $t1, fim_inicializar
    
    # Copiar data padrão
    la $a0, data_hora
    la $a1, padrao_data
    jal copiar_string
    
fim_inicializar:
    jr $ra

# ==================== PROCESSAR COMANDOS ====================
processar_comando:
    la $a0, buffer
    
    # Verificar conta_cadastrar
    la $a1, cmd_cadastrar
    jal comparar_string
    beq $v0, 1, handler_cadastrar
    
    # Verificar sacar
    la $a1, cmd_sacar
    jal comparar_string
    beq $v0, 1, handler_sacar
    
    # Verificar depositar
    la $a1, cmd_depositar
    jal comparar_string
    beq $v0, 1, handler_depositar
    
    # Comando não reconhecido
    li $v0, 4
    la $a0, msg_comando_inv
    syscall
    
    jr $ra

# CADASTRAR
handler_cadastrar:
    # Parse: conta_cadastrar-CPF-CONTA-NOME
    la $a0, buffer
    li $a1, '-'
    jal encontrar_campo  # Pular comando
    
    move $s0, $v0       # Salvar CPF
    
    jal encontrar_campo  # Próximo campo
    move $s1, $v0       # Salvar conta
    
    jal encontrar_campo  # Próximo campo  
    move $s2, $v0       # Salvar nome
    
    # Chamar função de cadastro
    move $a0, $s0       # CPF
    move $a1, $s1       # CONTA
    move $a2, $s2       # NOME
    jal conta_cadastrar
    
    jr $ra

# CONTA CADASTRAR
conta_cadastrar:
    addi $sp, $sp, -20
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp) 
    sw $a2, 12($sp)
    
    # Verificar se CPF já existe
    jal buscar_por_cpf
    bnez $v0, erro_cpf_existe
    
    # Verificar se conta já existe
    lw $a0, 8($sp)
    jal buscar_por_conta
    bnez $v0, erro_conta_uso
    
    # Calcular dígito verificador
    lw $a0, 8($sp)
    jal calcular_digito_verificador
    sb $v0, 16($sp)     # Salvar DV
    
    # Adicionar cliente
    lw $a0, 4($sp)      # CPF
    lw $a1, 8($sp)      # CONTA
    lw $a2, 12($sp)     # NOME
    lb $a3, 16($sp)     # DV
    jal adicionar_cliente
    
    # Mensagem de sucesso
    li $v0, 4
    la $a0, msg_sucesso
    syscall
    
    # Mostrar conta completa com DV
    lw $a0, 8($sp)      # CONTA
    li $v0, 4
    syscall
    
    li $v0, 11
    li $a0, '-'
    syscall
    
    li $v0, 11
    lb $a0, 16($sp)     # DV
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall
    
    j fim_cadastro

erro_cpf_existe:
    li $v0, 4
    la $a0, msg_cpf_existe
    syscall
    j fim_cadastro

erro_conta_uso:
    li $v0, 4
    la $a0, msg_conta_uso
    syscall

fim_cadastro:
    lw $ra, 0($sp)
    addi $sp, $sp, 20
    jr $ra

# Digito verificador (Júlio, tu consegue ajeitar essa parte aqui? me perdi na lógica matemática)

# Add Cliente
adicionar_cliente:
    # $a0 = CPF, $a1 = CONTA, $a2 = NOME, $a3 = DV
    la $t0, clientes
    lw $t1, num_clientes
    li $t2, 100
    mul $t3, $t1, $t2
    add $t0, $t0, $t3
    
    # Copiar CPF (11 bytes)
    move $t4, $a0
    li $t5, 0
copiar_cpf:
    lb $t6, 0($t4)
    beqz $t6, cpf_fim
    sb $t6, 0($t0)
    addi $t0, $t0, 1
    addi $t4, $t4, 1
    addi $t5, $t5, 1
    blt $t5, 11, copiar_cpf
cpf_fim:

    # Copiar CONTA (6 bytes)
    move $t4, $a1
    li $t5, 0
copiar_conta:
    lb $t6, 0($t4)
    beqz $t6, conta_fim
    sb $t6, 0($t0)
    addi $t0, $t0, 1
    addi $t4, $t4, 1
    addi $t5, $t5, 1
    blt $t5, 6, copiar_conta
conta_fim:

    # Copiar DV
    sb $a3, 0($t0)
    addi $t0, $t0, 1

    # Copiar NOME (33 bytes)
    move $t4, $a2
    li $t5, 0
copiar_nome:
    lb $t6, 0($t4)
    beqz $t6, nome_fim
    sb $t6, 0($t0)
    addi $t0, $t0, 1
    addi $t4, $t4, 1
    addi $t5, $t5, 1
    blt $t5, 33, copiar_nome
nome_fim:

    # Inicializar campos financeiros
    sw $zero, 0($t0)    # saldo
    lw $t1, LIMITE_PADRAO
    sw $t1, 4($t0)      # limite crédito
    sw $zero, 8($t0)    # saldo devedor
    sw $zero, 12($t0)   # prox_trans_debito
    sw $zero, 16($t0)   # prox_trans_credito
    
    # Incrementar número de clientes
    lw $t1, num_clientes
    addi $t1, $t1, 1
    sw $t1, num_clientes
    
    jr $ra


# Buscar pela conta ou pelo cpf (Júlio, tenta desenrolar essa parte, apanhei aqui)

# Funções de aúxilio/suporte
comparar_string:
    move $t0, $a0
    move $t1, $a1
    
comp_loop:
    lb $t2, 0($t0)
    lb $t3, 0($t1)
    bne $t2, $t3, diferentes
    beqz $t2, iguais
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j comp_loop

iguais:
    li $v0, 1
    jr $ra

diferentes:
    li $v0, 0
    jr $ra

encontrar_campo:
    move $t0, $a0
    
encontrar_loop:
    lb $t1, 0($t0)
    beq $t1, $a1, encontrado
    beqz $t1, nao_encontrado
    beq $t1, 10, nao_encontrado
    addi $t0, $t0, 1
    j encontrar_loop

encontrado:
    addi $t0, $t0, 1
    move $v0, $t0
    jr $ra

nao_encontrado:
    li $v0, 0
    jr $ra

copiar_string:
    move $t0, $a0
    move $t1, $a1
    
copiar_loop:
    lb $t2, 0($t1)
    sb $t2, 0($t0)
    beqz $t2, fim_copia
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j copiar_loop

fim_copia:
    jr $ra

# Chamar a atualização pro sistema
atualizar_sistema:
    jr $ra

# Interação com o usuário
testar_sistema:
    # Teste automático
    li $v0, 4
    la $a0, msg_testando
    syscall
    
    la $a0, cpf_teste
    la $a1, conta_teste  
    la $a2, nome_teste
    jal conta_cadastrar
    
    jr $ra

teste_interativo:
    # Pedir CPF
    li $v0, 4
    la $a0, prompt_cpf
    syscall
    
    li $v0, 8
    la $a0, buffer_cpf
    li $a1, 12
    syscall
    
    # Pedir CONTA
    li $v0, 4
    la $a0, prompt_conta
    syscall
    
    li $v0, 8
    la $a0, buffer_conta  
    li $a1, 7
    syscall
    
    # Pedir NOME
    li $v0, 4
    la $a0, prompt_nome
    syscall
    
    li $v0, 8
    la $a0, buffer_nome
    li $a1, 50
    syscall
    
    # Remover newlines dos inputs
    la $a0, buffer_cpf
    jal remover_newline
    la $a0, buffer_conta
    jal remover_newline
    la $a0, buffer_nome
    jal remover_newline
    
    # Calcular e mostrar DV
    la $a0, buffer_conta
    jal calcular_digito_verificador
    move $s0, $v0
    
    li $v0, 4
    la $a0, resultado_dv
    syscall
    
    li $v0, 11
    move $a0, $s0
    syscall
    
    li $v0, 11
    li $a0, '\n'
    syscall
    
    # Tentar cadastrar
    la $a0, buffer_cpf
    la $a1, buffer_conta
    la $a2, buffer_nome
    jal conta_cadastrar
    
    jr $ra

remover_newline:
    # $a0 = string para remover newline
    move $t0, $a0
rn_loop:
    lb $t1, 0($t0)
    beqz $t1, rn_fim
    beq $t1, 10, rn_replace
    addi $t0, $t0, 1
    j rn_loop
rn_replace:
    sb $zero, 0($t0)
rn_fim:
    jr $ra