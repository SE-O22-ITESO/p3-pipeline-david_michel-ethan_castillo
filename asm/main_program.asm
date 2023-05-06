#Data
#.data 
#	vector: .word 1 2 3 4  
#	row_0: .word 1 2 3 4  
#	row_1: .word 5 6 7 8 
#	row_2: .word 9 10 11 12 
#	row_3: .word 13 14 15 16
#	result: .word 0     
#.text
#0x10010024 dato a transmitir
#0x10010028 seÃ±al start tx
#0x1001002C seÃ±al que la uart ya termino de transmitir
#0x10010030 dato a recibir de uart
#0x10010034 seÃ±al que la uart ya recibio un dato
#0x10010038 seÃ±al para limpiar el rx uart
main:
	auipc a3,    0x0000fc10 #cargar valor base de 10010024
	addi a4, a3, 0x50 #cargar base de las matrices
	addi a3, a3, 0x24
	addi t5, zero, 0x10
	addi t2, zero, 0x1 #bit para cargar a registros de seÃ±ales
	addi t3, zero, 0x3 #matrix of 4 elements 
	addi t6, zero, 0x1 #vector of 1 element
wait_for_row:
	addi a5, a4, 0x10
	j init_ctt
wait_for_matrix:
	addi t3, zero, 0x0
init_ctt:
	addi s1, zero, 0x0
get_uart_data:
	lw t1, 0x10(a3) #obtener la seÃ±al de 0x10010034 para ver si ya recibimos un dato
	beq t1, zero, get_uart_data #checar si es un valor distinto de cero, sino seguir esperando
	lw a2, 0xC(a3) #loading number from address
	sw t2, 0x14(a3) #levantar seÃ±al para limpiar la bandera de rx
	sw zero, 0x14(a3) #bajar seÃ±al para limpiar la bandera de rx
	add t4, a5, s1
	sw a2, 0(t4) #load vaue based in matrix base + offset
	addi s1, s1, 4	#contador 
	bne s1, t5, get_uart_data #poll until f4 times happen
	addi t3, t3, -1
	bne t3, zero, wait_for_row
	
finish:
	nop

start_matrix:
	addi s0, zero, 4 #matrix size
	addi s1, zero, 0 #int i = 0
	addi s3, zero, 0 #int resultado = 0
	addi s4, zero, 4 #word size
	mul s7, s4, s0 #row size
	#for grande que vaya por rows de la matriz
	#for peque;o que vaya por columnas de la row, producto punto
	#la a1, row_0
	auipc a1,    0x0000fc10
	addi a1, a1, 0xfffffffc
	#la a2, result
	auipc a2,    0x0000fc10
	addi a2, a2, 0x00000034
	
Column_loop:

	#for(i=0;i<4;i++)
	slti t1, s1, 0x4 
	beqz t1, Exit #exit for if condition is not met
	#la a0, vector
	auipc a0,    0x0000fc10
	addi a0, a0, 0xffffffd4
	addi s2, zero, 0 #int j = 0
	addi t3, zero, 0#resetear la variable temporal t3
Row_loop:
	#for(j=0;j<4;j++)
	slti t1, s2, 0x4 
	beqz t1, Row_loop_done #exit for if condition is not met
	lw t2, 0(a0)#get a from vector 1
	sw t2, -4(sp)#load a to 4(sp)
	lw t2, 0(a1)#get b from vector 2
	sw t2, -8(sp)#load b to 8(sp)
	jal ra, ProductFunction #ProductFunction(Vector_1[i], Vector_2[i])
	lw t2, -12(sp)#get result from 12(sp)
	add t3, t3, t2 # result = result + ProductFunction(Vector_1[i], Vector_2[i]);
	addi a0, a0, 4 #move vector1 base address
	addi a1, a1, 4 #move vector2 base address
	addi s2, s2, 0x1 #j++
	jal zero, Row_loop #next for iteration
	
Row_loop_done:
	sw t3, 0(a2)#guardar el resultado en el result vector
	addi a2, a2, 4#mover el apuntador del vector
	addi s1, s1, 1#add i++
	jal zero, Column_loop #jump to column loop
Exit:
	addi zero, zero, 0

ProductFunction:
	sw ra, 0(sp) #save ra in 0(sp)
	lw s4, -4(sp) #get a from 4(sp)
	lw s5, -8(sp) #get b from 8(sp)
	mul t0, s4, s5 # a*b
	sw t0, -12(sp) #save result to 12(sp)
	lw ra, 0(sp) #load ra
	jalr zero, ra, 0
