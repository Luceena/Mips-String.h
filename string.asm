.data
fim: .asciiz "\0" #caracteres que marcam o fim da string
pedir_string: .asciiz "por favor insira a string \n" 
str1: .space 300 #endereco da string 1 de ate 300 chars
str2: .space 300 #endereco da string 2 de ate 300 chars

.macro inserir_string1
	li $v0, 4 #carrega o codigo do syscall de imprimir string
	la $a0, pedir_string #carrega o endereco da string a ser printada
	syscall
	li $v0, 8 #carrega o codigo do syscall de ler uma string
	la $a0, str1 #carrega o endereco da memoria onde comecara a string 1
	li $a1, 300 #achamos 300 caracteres um valor razoavel
	syscall 
.end_macro

.macro inserir_string2
	li $v0, 4 #carrega o codigo do syscall de imprimir string
	la $a0, pedir_string #carrega o endereco da string a ser printada
	syscall
	li $v0, 8 #carrega o codigo do syscall de ler uma string
	la $a0, str2 #carrega o endereco da memoria onde comecara a string 2
	li $a1, 300 #achamos 300 caracteres um valor razoavel
	syscall 
.end_macro

.macro strcat
    la $t0, str1        # ponteiro p/ str1
encontrar_fim:
    lb $t1, 0($t0)      # lê o byte atual
    beq $t1, 10, remover_newline  # se '\n', remove
    beq $t1, $zero, loop_copia  # se '\0', achou fim
    addi $t0, $t0, 1    # avança ponteiro
    j encontrar_fim

remover_newline:
    sb $zero, 0($t0)    # substitui '\n' por '\0' (Poque se não não concatena)
    j loop_copia

loop_copia:
    la $t2, str2        # ponteiro p/ str2
copiar_char:
    lb $t3, 0($t2)      # lê byte de str2
    beq $t3, 10, pular_newline  # se for '\n', pula
    sb $t3, 0($t0)      # copia para str1
    beq $t3, $zero, copia_feita  # para após copiar '\0'
    addi $t0, $t0, 1    # avança ponteiro str1
pular_newline:
    addi $t2, $t2, 1    # avança ponteiro str2
    j copiar_char

copia_feita:
.end_macro

.macro strcmp 
	la $t0, fim  #carrega o end de \0 no registrador t0 
	lb $t0, 0($t0) #carrega o \0 no registrador t0
	la $t1, str1 #carrega endereco da string1
	la $t2, str2 #carrega endereco da string2
	comeco: #comeco do loop
	lb $s1, 0($t1) #carrega o byte no endereco $t1 para o $s1,na primeira iteracao do loop carrega o primeiro caractere e assim por diante
	lb $s2, 0($t2) #o mesmo mas para a string 2
	beq $s1,$s2,iguais #se os caracteres forem iguais pula pra label iguais
	slt $t3,$s1,$s2 #armazena 1 se o primeiro caractere tiver valor menor na primeira string ou zero se tiver valor maior
	beq $t3,$zero, primeiro_maior
	#primeiro caractere diferente da string 1 e menor retorna -1
	li $v0,1
	li $a0,-1
	syscall
	j encerrar_cmp 
	primeiro_maior:
	#primeiro caractere diferente da string 1 e maior retorna 1
	li $v0,1
	li $a0,1
	syscall
	j encerrar_cmp 
	iguais:
	beq $t0,$s1, strings_identicas #detecta se ambas as strings terminaram juntas
	addi $t1,$t1,1 #avanca o ponteiro da string 1 pro proximo byte
	addi $t2,$t2,1 #idem pra string 2
	j comeco
	strings_identicas:
	#cabou as strings e sao iguais retona 0
	li $v0,1
	li $a0,0
	syscall
	encerrar_cmp:
	#apenas retorna da macro, nao encerra o programa
.end_macro 

# Função strcpy - implementada conforme requisitos
# $a0 = destination, $a1 = source
# Retorna $v0 = destination
strcpy:
    move $v0, $a0       # Salva destination original para retorno
    move $t0, $a0       # Ponteiro para destination
    move $t1, $a1       # Ponteiro para source
    
strcpy_loop:
    lb $t2, 0($t1)      # Carrega byte da source
    sb $t2, 0($t0)      # Armazena byte no destination
    beq $t2, $zero, strcpy_end  # Se encontrou NULL, termina
    addi $t0, $t0, 1    # Avança destination
    addi $t1, $t1, 1    # Avança source
    j strcpy_loop
    
strcpy_end:
    jr $ra              # Retorna para o endereço de chamada

# Função strncmp - compara até num caracteres
strncmp:
    move $t0, $a0       # $t0 = ponteiro para str1
    move $t1, $a1       # $t1 = ponteiro para str2  
    move $t2, $a3       # $t2 = contador de caracteres (num)
    li $v0, 0           # Inicializa retorno como 0 (iguais)

strncmp_loop:
    ble $t2, $zero, strncmp_end  # Se num <= 0, termina a comparação
    lb $t3, 0($t0)      # Carrega byte atual de str1
    lb $t4, 0($t1)      # Carrega byte atual de str2
    
    beq $t3, $zero, check_str2_end  # Se str1 terminou, verifica str2
    beq $t4, $zero, str1_greater    # Se str2 terminou mas str1 não, str1 é maior
    
    bne $t3, $t4, chars_different   # Se caracteres são diferentes, trata
    
    # Caracteres são iguais, avança para o próximo
    addi $t0, $t0, 1    # Avança ponteiro de str1
    addi $t1, $t1, 1    # Avança ponteiro de str2
    addi $t2, $t2, -1   # Decrementa contador
    j strncmp_loop      # Continua loop

check_str2_end:
    beq $t4, $zero, strncmp_end  # Se ambas terminaram, são iguais
    j str2_greater                # Se só str1 terminou, str2 é maior

chars_different:
    slt $t5, $t3, $t4   # $t5 = 1 se str1 < str2, 0 caso contrário
    beq $t5, $zero, str1_greater  # Se str1 >= str2, verifica qual é maior
    
str2_greater:
    li $v0, -1          # str1 < str2, retorna -1
    j strncmp_end
    
str1_greater:
    li $v0, 1           # str1 > str2, retorna 1

strncmp_end:
    jr $ra              # Retorna para o endereço de chamada

# Memcpy
memcpy:
    move $v0, $a0       # Salva o destination original para retorno
    move $t0, $a0       # Ponteiro para destination
    move $t1, $a1       # Ponteiro para source
    
memcpy_loop:
    beq $a2, $zero, memcpy_end  # Se num == 0, termina
    lb $t2, 0($t1)      # Carrega byte da source
    sb $t2, 0($t0)      # Armazena byte no destination
    addi $t0, $t0, 1    # Avança destination
    addi $t1, $t1, 1    # Avança source
    addi $a2, $a2, -1   # Decrementa contador
    j memcpy_loop
    
memcpy_end:
    jr $ra              # Retorna para o endereço de chamada
