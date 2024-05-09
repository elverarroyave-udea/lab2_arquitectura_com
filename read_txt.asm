#Directiva para ubicarnos en la memoria de instrucciones
.text
.globl main

main:
	li $v0,13           	# abrir archivo syscall code = 13
    	la $a0,fileName     	# Obtener nombre
    	li $a1,0           	# Obtenemos direcci�n base del banco de registros
    	syscall
    	move $s7,$v0        	# Guardar el file_descriptor. s7 = file
	
	#Leer el archivo
	li $v0, 14		# leer el archivo syscall code = 14
	move $a0,$s7		# file_descriptor en a0
	la $a1,fileWords  	# 
	la $a2,2048		# Codificamos el buffer length
	syscall
	
	addi $s7,$a1,0 		# Guardamos la direcci�n base del string en s7
	
	# solicitar separador
	jal ask_for_separator
	lb $s1,0($a0)		# Almacenamos en s1 el valor del saparador en codigo ASCCI
	addi $s1,$s1,-48	
	
	addi $s2,$s7,0		# Almacenamos en s2 la direccion base del string
	#TODO crear variable para contar cuantos numeros contiene el arreglo
	addi $s4,$zero,0	# s4 ser? el contador de los numeros que contiene el string
	
	#add $s0,$s7,$a2		# s0 ser? la base donde se almacenar? el vector de los numeros procesados en memoria,
	#addi $s0,$s0,1		# sumamos 1 para aliniar la memoria
	addi $s0,$s0,268503040
	
	addi $t8,$zero,0
	loop_array_string:
		lb $t0,0($s2)			# Almacenamos en t0 el valor recuperado del string en en codigo ASCCI		
		addi $t0,$t0,-48 		# ascii_to_decimal
		
		#validacion de salida del loop
		slt $t1,$t0,$zero  		# if(t0<0) ==> t1=1 else t1=0
		bne $t1,$zero,exit_loop_array_string 
		
		begin_if_separator: bne $t0,$s1,else
		 	jal end_if_separator
		else:
			addi $a2,$t8,0
			addi $a3,$t0,0
			jal setArrayValue
			addi $s4,$s4,1		#s4++
			addi $t8,$t8,1		#t8++
									
		end_if_separator:	
					
		addi $s2,$s2,1 		#Aumentar el contador s2++
		jal loop_array_string
	
exit_loop_array_string :				
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	
    	li  $v0, 10 		# Syscall code finalizar programa code = 10
    	syscall  	
    	
ask_for_separator:
	li $v0,4
 	la $a0, mensaje1
 	syscall
 	li $v0, 8
 	move $t0, $v0
 	syscall
 	jr $ra
 	
 # Establecer el valor de un elemento del vector
 # a2 indice de inserci�
 # a3 valor a insertar
setArrayValue:
    sll  $t9, $a2, 2  		# Multiplicar por 4 para obtener el desplazamiento
    add  $t9, $s0, $t9  	# Calcular la posici�n en memoria
    sw   $a3, 0($t9)  		# Guardar el valor
    jr   $ra  	
	
.data
fileName: .asciiz "C:/mips/input_file.txt"
fileWords: .space 1024
mensaje1: .asciiz "Ingrese el separador: "
