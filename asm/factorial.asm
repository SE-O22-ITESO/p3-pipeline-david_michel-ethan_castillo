.text
#0x10010024 dato a transmitir
#0x10010028 seÃ±al start tx
#0x1001002C seÃ±al que la uart ya termino de transmitir
#0x10010030 dato a recibir de uart
#0x10010034 seÃ±al que la uart ya recibio un dato
#0x10010038 seÃ±al para limpiar el rx uart

main:
	auipc a3,    0x0000fc10 #cargar valor base de 10010024
	addi a3, a3, 0x24
	addi t2, zero, 0x1 #bit para cargar a registros de seÃ±ales
get_uart_data:
	lw t1, 0x10(a3) #obtener la seÃ±al de 0x10010034 para ver si ya recibimos un dato
	beq t1, zero, get_uart_data #checar si es un valor distinto de cero, sino seguir esperando
	lw a2, 0xC(a3) #loading number from address
	sw t2, 0x14(a3) #levantar seÃ±al para limpiar la bandera de rx
	sw zero, 0x14(a3) #bajar seÃ±al para limpiar la bandera de rx
main_factorial:
	#addi a2,zero,5 #loading factorial
	jal ra,factorial #calling procedure
	jal zero,send_uart_data # jump to uart data send
factorial:
	slti t0, a2, 1, #if n<1
	beq t0, zero, loop #branch to loop
	addi a0, zero, 1 #loading 1
	jalr zero,ra,0 #return to the caler
loop:
	addi sp, sp, -8 #decreasing stack pointer
	sw ra, 4(sp) #storing n
	sw a2, 0(sp) #storing return addres
	addi a2, a2, -1 #Decreasing n
	jal ra,factorial #recursive function
	lw a2, 0(sp) #load value from stack
	lw ra, 4(sp) # load ra from stack
	addi sp, sp, 8 #increase stack pointer
	mul a0, a2, a0 # n*factorial(n-1)
	jalr zero,ra,0 #return to caller	
send_uart_data:
	addi s0, zero, 0x20 #contador i para el loop
send_loop:
	addi s0, s0, -0x8 #decrease counter
	srl t3, a0, s0 #shift right register factorial number to get 8 bits to send
	sw t3, 0(a3) #cargar el factorial en la direccion de memoria de dato UART
	sw t2, 4(a3) #cargar el bit 1 a la seÃ±al de enviar tx de uart
	sw zero, 4(a3) #cargar el bit 0 a la seÃ±al de enviar tx de uart tipo one shot
wait_uart_working:
	lw t4, 0x18(a3) #obtener que UART ya empezo nuestra solicitud Tx
	beq t4, zero, wait_uart_working #checar si es un valor distinto de cero, sino seguir esperando que empiece solicitud
wait_to_send:
	lw t1, 8(a3) #obtener el valor de la bandera que termino de enviar la transmision
	beq t1, zero, wait_to_send #checar si es un valor distinto de cero, sino seguir esperando que termine de enviarse
	bne s0, zero, send_loop #check if al bytes have been sent
	jal zero,get_uart_data # jump to wait next factorial number
exit:
