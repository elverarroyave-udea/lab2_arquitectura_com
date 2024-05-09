.data
fileName: .asciiz "C:/mips/input_file.txt"
finished_msj: .asciiz "Fin de la ejecución!"
fileWords: .space 1024
get_separator: .asciiz "Ingrese el separador: "
show_string: .asciiz "Cadena ingresada: "
show_order_string: .asciiz "Cadena ordenada: "

.text
.globl main
main:

    # Direccion para leer y procesar archivo txt
    jal read_file

    # Bucle externo para recorrer desde el segundo elemento hasta el final
    addi $t0, $zero, 1 	 	# ?ndice para el bucle externo(i)
    
outer_loop:
    slt  $t1, $t0, $s4  	# if($t0<$s1) => $t2=1 else $t2=0 
    beq  $t1, $zero, exit_loop  # Si $t2=$0 ir exit_loop

    # Obtener el valor del elemento actual(key)
    addi $a0, $t0, 0
    jal  getArrayValueByIndex	# Obtenemos el valor a insertar
    move $s1, $v0  		# Guardamos el valor a insertar en $s1(key)
    
    # ?ndice para el bucle interno
    addi $t1, $t0, -1  		# Empezamos desde el elemento anterior t1=i-1(j)
    inner_loop:
    	# Validaci?n t1>=0
    	addi $t2,$zero,-1
    	slt  $t3, $t2,$t1  	# if(t1>=0) t2=1 else t2 = 0
    	beq  $t3, $zero, exit_inner_loop  # Si negativo, insertar el elemento
    
    	# Obtenemos el valor del elemento arr[t1]
    	addi $a0,$t1,0
    	jal  getArrayValueByIndex	# Obtenemos el valor a insertar
    	move $s2, $v0  			# Guardamos el valor a insertar en $s2
    
    	#Validaci?n arr[t1]<$s1
    	slt $t2,$s2,$s1		#if(s2<s1) => t2=1 else t2=0
    	beq $t2,$zero, exit_inner_loop
    	
    	addi $a2, $t1, 1  		# ?ndice de inserci?n
    	addi $a3, $s2, 0  		# Valor a insertar
    	jal  setArrayValue
    	
    	addi $t1,$t1,-1
    	j inner_loop
    	        

exit_inner_loop:
    # Insertar el valor en la posici?n correcta
    addi $a2, $t1, 1  		# ?ndice de inserci?n
    addi $a3, $s1, 0  		# Valor a insertar
    jal  setArrayValue
    
    # Incrementar el ?ndice externo para continuar con el siguiente
    addi $t0, $t0, 1
    j    outer_loop  		# Continuar el bucle externo

exit_loop:
    j exit  			# Finaliza el bucle externo

exit:
    li  $v0, 4
    la  $a0, finished_msj
    syscall
    li  $v0, 10
    syscall  			# Termina el programa
    
    
#---------------------------------------------Read File -----------------------------------------------------
read_file:

	subu	$sp, $sp,4
	sw	$ra,($sp) #Salvamos la direccion de retorno en la pila a la funcion main, en la posicion actual del puntero de pila
	
	li $v0,13           	# abrir archivo syscall code = 13
	la $a0,fileName     	# Obtener nombre
	li $a1,0           	# Obtenemos direcci?n base del banco de registros
	syscall
	move $s2,$v0        	# Guardar el file_descriptor. s2 = file
	
	#Leer el archivo
	li $v0, 14		# leer el archivo syscall code = 14
	move $a0,$s2		# file_descriptor en a0
	la $a1,fileWords  	# 
	la $a2,2048		# Codificamos el buffer length
	syscall
	
	addi $s2,$a1,0 		# Guardamos la direcci?n base del string en s2
	
	# solicitar separador
	jal ask_for_separator
	lb $s1,0($a0)		# Almacenamos en s1 el valor del saparador en codigo ASCCI
	#addi $s1,$s1,-48	
	
	#TODO crear variable para contar cuantos numeros contiene el arreglo
	addi $s4,$zero,0	# s4 ser? el contador de los numeros que contiene el string
	
	#add $s0,$s2,$a2		# s0 ser? la base donde se almacenar? el vector de los numeros procesados en memoria,
	#addi $s0,$s0,1		# sumamos 1 para aliniar la memoria
	addi $s0,$zero,268503040
	addi $s3,$zero,0		# Contador de apilacion
	
	addi $t8,$zero,-1
	
	loop_array_string:
		lb $t0,0(,$s2)			# Almacenamos en t0 el valor recuperado del string en en codigo ASCCI
		#validacion de salida del loop
		beq $t0,$zero,exit_loop_array_string 
		
		begin_if_separator: bne $t0,$s1,else
			jal build_number		
			addi $a2,$s4,0
			addi $a3,$v0,0
			bne $t7,$t8,no_negative	
				mul $a3,$a3,$t8		# a3=a3*-1
				addi $t7,$zero,0
			no_negative:
			jal setArrayValue
			addi $s4,$s4,1		#s4++
		 	jal end_if_separator
		else:	
			addi $t1,$zero,45 #validacion si se trata de un numero negativo
			bne $t0,$t1,no_negative_signo
				addi $t7,$zero,-1
				jal end_if_separator
			no_negative_signo:
			addi $t0,$t0,-48 	
			addi $sp,$sp,4
			sw $t0,($sp)
			addi $s3,$s3,1
											
		end_if_separator:		
		addi $s2,$s2,1 		#Aumentar el contador s2++
		jal loop_array_string
	
exit_loop_array_string:				
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	move $a0,$s0      		# file descriptor to close
    	syscall
    	lw $ra,($sp)			# Recuperamos la direccion de retorno de la pila
	addi $sp,$sp,4			# Ajustamos el puntero de pila
	jr $ra
	
#---------------------------------------------Build Number--------------------------------------------------------
build_number:
	addi $t9,$ra,0
	addi $t0,$zero,0			# Inicalizamos el acumulador		
	addi $t1,$zero,0 			# Inicializamos el contador
	loop_build_number:
		lw $a0,($sp)			# Recuperamos el valor de la pila
		addi $v0,$zero,1
		addi $a1,$t1,0			
		jal loop_multiplicador
		mul $t2,$a0,$v0
		add $t0,$t0,$t2			
		addi $t1,$t1,1			
		addi $sp,$sp,-4
		addi $s3,$s3,-1
		beq $s3,$zero,exit_build_number
		j loop_build_number
	exit_build_number:
	addi $v0,$t0,0
	addi $ra,$t9,0
	jr $ra

loop_multiplicador:
	beq $a1,$zero,exit_loop_multiplicador
	addi $t2,$zero,10
	mul $v0,$v0,$t2,
	addi $a1,$a1,-1
		j loop_multiplicador
	exit_loop_multiplicador:
	jr $ra

#---------------------------------------------Methods--------------------------------------------------------
ask_for_separator:
	li $v0,4
 	la $a0, get_separator
 	syscall
 	li $v0, 8
 	move $t0, $v0
 	syscall
 	jr $ra

# Obtener el valor de una posici?n del vector
getArrayValueByIndex:
    sll  $t9, $a0, 2  		# Multiplicar por 4 (tama?o de palabra)
    add  $t9, $s0, $t9  		# Calcular la direcci?n en memoria
    lw   $t9, 0($t9)  		# Cargar el valor
    addi $v0, $t9, 0  		# Retornar el valor
    jr   $ra  			# Regresar al llamador
 
 # Establecer el valor de un elemento del vector
 # a2 indice de inserció
 # a3 valor a insertar
setArrayValue:
    sll  $t9, $a2, 2  		# Multiplicar por 4 para obtener el desplazamiento
    add  $t9, $s0, $t9  	# Calcular la posición en memoria
    sw   $a3, 0($t9)  		# Guardar el valor
    jr   $ra  			# Regresar al llamador
