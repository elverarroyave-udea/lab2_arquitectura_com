.data
vector:  .word 2, 12, 6, 41, 18, 31, 53
length:  .word 7
mensaje1: .asciiz "Fin de la ejecución!"

fileName: .asciiz "C:/mips/input_file.txt"
fileWords: .space 1024
mensaje1: .asciiz "Ingrese el separador: "

.text
.globl main
main:

    jal read_file
	

    la   $s0, vector    	# Con esta instruccion cargamos la direccion base del vector en la variable indicada (s0 en este caso)
    la   $s1, length    	# Cargamos la direccion de memoria de length
    lw   $s1, 0($s1)    	# Cargamos el valor de la longitud del vector

    # Bucle externo para recorrer desde el segundo elemento hasta el final
    addi $t0, $zero, 1 	 	# Índice para el bucle externo(i)
    
outer_loop:
    slt  $t2, $t0, $s1  	# if($t0<$s1) => $t2=1 else $t2=0 
    beq  $t2, $zero, exit_loop  # Si $t2=$0 ir exit_loop

    # Obtener el valor del elemento actual(key)
    addi $a0, $t0, 0
    jal  getArrayValueByIndex	# Obtenemos el valor a insertar
    move $s2, $v0  		# Guardamos el valor a insertar en $s2(key)
    
    # Índice para el bucle interno
    addi $t1, $t0, -1  		# Empezamos desde el elemento anterior t1=i-1(j)
    inner_loop:
    	# Validación t1>=0
    	addi $t8,$zero,-1
    	slt  $t2, $t8,$t1  	# if(t1>=0) t2=1 else t2 = 0
    	beq  $t2, $zero, exit_inner_loop  # Si negativo, insertar el elemento
    
    	# Obtenemos el valor del elemento arr[t1]
    	addi $a0,$t1,0
    	jal  getArrayValueByIndex	# Obtenemos el valor a insertar
    	move $s3, $v0  			# Guardamos el valor a insertar en $s3
    
    	#Validación arr[t1]<$s2
    	slt $t2,$s3,$s2		#if(s3<s2) => t2=1 else t2=0
    	beq $t2,$zero, exit_inner_loop
    	
    	addi $a2, $t1, 1  		# Índice de inserción
    	addi $a3, $s3, 0  		# Valor a insertar
    	jal  setArrayValue
    	
    	addi $t1,$t1,-1
    	j inner_loop
    	        

exit_inner_loop:
    # Insertar el valor en la posición correcta
    addi $a2, $t1, 1  		# Índice de inserción
    addi $a3, $s2, 0  		# Valor a insertar
    jal  setArrayValue
    
    # Incrementar el índice externo para continuar con el siguiente
    addi $t0, $t0, 1
    j    outer_loop  		# Continuar el bucle externo

exit_loop:
    j exit  			# Finaliza el bucle externo

exit:
    li  $v0, 4
    la  $a0, mensaje1
    syscall
    li  $v0, 10
    syscall  			# Termina el programa
    
    
#---------------------------------------------Read File -----------------------------------------------------
read_file:
	
	li $v0,13           	# abrir archivo syscall code = 13
    	la $a0,fileName     	# Obtener nombre
    	li $a1,0           	# Obtenemos dirección base del banco de registros
    	syscall
    	addi $s0,$v0,0        	# Guardar el file_descriptor. $s0 = file
	
	#Leer el archivo
	li $v0, 14		# leer el archivo syscall code = 14
	addi $a0,$s0,0		# file_descriptor en a0
	la $a1,fileWords  	# 
	la $a2,2048		# Codificamos el buffer length
	syscall	
	
	addi $s0,$a1,0 		# Almacenamos en s0 la direccion base del string
	
	# solicitar separador
	jal ask_for_separator
	lb $s1,0($a0)		# Almacenamos en s1 el valor del saparador en codigo ASCCI
	addi $s1,$s1,-48	
	
	addi $s2,$s0,0
	#TODO crear variable para contar cuantos numeros contiene el arreglo
	
	add $s7,$s0,$a2		# s7 será la base donde se almacenará el vector de numeros,
	addi $s7,$s7,1		# sumamos 1 para aliniar la memoria
	
	addi $t8,$zero,0
	loop_array:
		lb $t0,0($s2)			# Almacenamos en t0 el valor recuperado del string en en codigo ASCCI		
		addi $t0,$t0,-48 		# ascii_to_decimal
		
		#validacion de salida del loop
		slt $t1,$t0,$zero  		# if(t0<0) ==> t1=1 else t1=0
		bne $t1,$zero,exit_loop_array
		
		begin_if_separator: bne $t0,$s1,else
		 	jal end_if_separator
		else:
			addi $a2,$t8,0
			addi $a3,$t0,0
			jal setArrayValue
			addi $t8,$t8,1		#t8++
									
		end_if_separator:	
					
		addi $s2,$s2,1 		#Aumentar el contador s2++
		jal loop_array
	
exit_loop_array:				
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	addi $a0,$s0,0      		# file descriptor to close
    	syscall
    	
    	li  $v0, 10 		# Syscall code finalizar programa code = 10
    	syscall  	



#---------------------------------------------Methods--------------------------------------------------------

ask_for_separator:
	li $v0,4
 	la $a0, mensaje1
 	syscall
 	li $v0, 8
 	move $t0, $v0
 	syscall
 	jr $ra

# Obtener el valor de una posición del vector
getArrayValueByIndex:
    sll  $t9, $a0, 2  		# Multiplicar por 4 (tamaño de palabra)
    add  $t9, $s0, $t9  		# Calcular la dirección en memoria
    lw   $t9, 0($t9)  		# Cargar el valor
    addi $v0, $t9, 0  		# Retornar el valor
    jr   $ra  			# Regresar al llamador

# Establecer el valor de un elemento del vector
setArrayValue:
    sll  $t9, $a2, 2  		# Multiplicar por 4 para obtener el desplazamiento
    add  $t9, $s0, $t9  	# Calcular la posición en memoria
    sw   $a3, 0($t9)  		# Guardar el valor
    jr   $ra  			# Regresar al llamador
