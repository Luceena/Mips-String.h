.data
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

.macro encerrar_programa
	li $v0, 10 #carrega o codigo do syscall de encerrar o programa, literalmente copiamos isso do senhor prof
	syscall 
.end_macro 

.macro strcmp 
	la $t1, str1 #carrega endereco da string1
	la $t2, str2 #carrega endereco da string2
	comeco: #comeco do loop
	lb $s1, 0($t1) #carrega o byte no endereco $t1 para o $s1,na primeira iteracao do loop carrega o primeiro caractere e assim por diante
	lb $s2, 0($t2) #o mesmo mas para a string 2
	beq $s1,$s2,iguais #se os caracteres forem iguais pula pra label iguais
	iguais:
	
	
	
	
.end_macro 

 

.text
	#toda essa identacao nao afeta o codigo, serve apenas para manter a sanidade
	inserir_string1
	encerrar_programa
	