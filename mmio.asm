
.text
main:
	lui $t1, 0xFFFF #carrega em $t1 o endereço reservado para o teclado
	ori $t1, 0x0000 
	lui $t2, 0xFFFF 
	ori $t2, 0x0004 #carrega em $t2 o endereço reservado para o dado do teclado e monta
	lui $t3, 0xFFFF
	ori $t3, 0x0008 #monta o endereço do display do mmio
	lui $t4, 0xFFFF 
	ori $t4, 0x000C #monta a parte data do display onde será recebido o byte a ser exibido
	
loop_LE:
	
	lw $t0, 0($t1) #carrega o status do teclado em $t0, caso digite algo será 1, caso não, 0
	beqz, $t0, loop_LE #caso $t0 seja zero retorna ao loop até o status ser 1.
	
	lb $t5, 0($t2) #carrega o byte do char escrito
		
display_loop:
	lw $t0, 0($t3)	#carrega o status do display		
	beqz, $t0, display_loop #quando o display ficar pronto pra receber o valor $t0 vai ser diferente de 0 e segue a execução
	sb $t5, 0($t4) #escreve o byte que está em $t5, ou seja o byte do char que foi lido
	j loop_LE #retorna ao inicio