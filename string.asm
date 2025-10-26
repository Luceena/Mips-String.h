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
	beq $t3,$s0, primeiro_maior
	#primeiro caractere diferente da string 1 e menor retorna -1
	li $v0,1
	li $a0,-1
	syscall
	j encerrar_programa 
	primeiro_maior:
	#primeiro caractere diferente da string 1 e maior retorna 1
	li $v0,1
	li $a0,1
	syscall
	j encerrar_programa 
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
	encerrar_programa:
	li $v0, 10 #carrega o codigo do syscall de encerrar o programa, literalmente copiamos isso do senhor prof
	syscall 
	 
.end_macro 

 

.text
	#toda essa identacao nao afeta o codigo, serve apenas para manter a sanidade
	inserir_string1
	inserir_string2
	strcmp
	