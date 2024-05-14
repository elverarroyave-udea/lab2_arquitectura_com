.data
fileName: .asciiz "C:/mips/input_file.txt"
finished_msj: .asciiz "Fin de la ejecución!"
fileWords: .space 1024
get_separator: .asciiz "Ingrese el separador: "
break_line: .asciiz "\n" 
show_string: .asciiz "Cadena leida: \n"
show_order_string: .asciiz "Cadena ordenada: "
fileName2: .asciiz "C:/mips/output_file.txt"

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
    jal printReuslt
    jal createTxt
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
	addi $s2,$v0,0        	# Guardar el file_descriptor. s2 = file
	
	#Leer el archivo
	li $v0, 14		# leer el archivo syscall code = 14
	addi $a0,$s2,0		# file_descriptor en a0
	la $a1,fileWords  	# 
	la $a2,2048		# Codificamos el buffer length
	syscall
	
	#Imprimir cadena
	li $v0,4
 	la $a0, show_string		# Mensaje de cadena leida
 	syscall
	la $a0,fileWords	# Direccion de la cadena
	syscall
	la $a0,break_line	# Salto de linea
	syscall
	
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	addi $a0,$s2,0      		# file descriptor to close
    	syscall
	
	addi $s2,$a1,0 		# Guardamos la direcci?n base del string en s2
	
	# solicitar separador
	jal ask_for_separator
	lb $s7,0($a0)		# Almacenamos en s7 el valor del saparador en codigo ASCCI
		
	addi $s4,$zero,0			# s4 ser? el contador de los numeros que contiene el string
	
	addi $s0,$zero,268503040
	addi $s3,$zero,0			# Contador de apilacion
	
	addi $t8,$zero,-1		# t8=-1
	
	loop_array_string:
		lb $t0,0(,$s2)			# Almacenamos en t0 el valor recuperado del string en en codigo ASCCI
		#validacion de salida del loop
		beq $t0,$zero,exit_loop_array_string 
		
		begin_if_separator: bne $t0,$s7,else
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
			addi $t1,$zero,45	 # 45 = '-' en codigo ASCCI
			bne $t0,$t1,no_negative_signo
				addi $t7,$zero,-1
				jal end_if_separator
			no_negative_signo:
			addi $t0,$t0,-48		# Convertir de codigo ASCCI a numero 	
			addi $sp,$sp,4			# Ajustamos el puntero de pila
			sw $t0,($sp)			# Guardamos el valor en la pila
			addi $s3,$s3,1			# Aumentar el contador s3++
											
		end_if_separator:		
		addi $s2,$s2,1 			#Aumentar el contador s2++
		jal loop_array_string
	
exit_loop_array_string:				
    	lw $ra,($sp)				# Recuperamos la direccion de retorno de la pila
	addi $sp,$sp,4				# Ajustamos el puntero de pila
	jr $ra
	
#---------------------------------------------Build Number--------------------------------------------------------
build_number:
	addi $t9,$ra,0
	addi $t0,$zero,0			# Inicalizamos el acumulador		
	addi $t2,$zero,1			# Acumulador x10
	loop_build_number:
		lw $t3,($sp)			# Recuperamos el valor de la pila		
		mul $t3,$t3,$t2			# Multiplicamos numero de la pila por acumulador x 10
		add $t0,$t0,$t3			# acumulador + acumulador + t3	
		mul $t2,$t2,10			# Acumulador =  acum * 10
		addi $sp,$sp,-4			# Desapilamos
		addi $s3,$s3,-1			# Restamos contador de aplicaci?n
		beq $s3,$zero,exit_build_number # ir a exit_build_number si s3 = 0
		j loop_build_number		
	exit_build_number:
	addi $v0,$t0,0
	addi $ra,$t9,0
	jr $ra

#---------------------------------------------Methods--------------------------------------------------------
ask_for_separator:
	li $v0,4		# syscall code 4
 	la $a0, get_separator		# Mensaje de solicitud de separador
 	syscall		# syscall para imprimir el mensaje
 	li $v0, 8	# syscall code 8
 	move $t0, $v0	# Guardamos el valor de retorno en t0
 	syscall
 	jr $ra

# Obtener el valor de una posici?n del vector
getArrayValueByIndex:
    sll  $t9, $a0, 2  		# Multiplicar por 4 (tama?o de palabra)
    add  $t9, $s0, $t9  	# Calcular la direcci?n en memoria
    lw   $t9, 0($t9)  		# Cargar el valor
    addi $v0, $t9, 0  		# Retornar el valor
    jr   $ra  			# Regresar al llamador

 # Establecer el valor de un elemento del vector
 # a2 indice de inserci?
 # a3 valor a insertar
setArrayValue:
    sll  $t9, $a2, 2  		# Multiplicar por 4 para obtener el desplazamiento
    add  $t9, $s0, $t9  	# Calcular la posici?n en memoria
    sw   $a3, 0($t9)  		# Guardar el valor
    jr   $ra  			# Regresar al llamador
    
printReuslt:
	addi $t9,$ra,0
	addi $v0, $zero, 4    #Establezco el modo de operacion para syscall 4
	la $a0, show_order_string
	syscall
	la $a0,break_line	# Salto de linea
	syscall
	addi $t8,$zero,0
	addi $t7,$zero,268503040
	#sw $s7,0($sp)	
	print:       
		#addi $v0, $zero, 1    #Establezco el modo de operacion para syscall 1
        	lw $a0,($t7)
        	#syscall
        	addi,$t7,$t7,4
        	addi,$t8,$t8,1
        	
        	jal writeFile
        	
        	bne $t8,$s4,print       	
        addi $v0, $zero, 4 
        la $a0,break_line	# Salto de linea
	syscall
	addi $ra,$t9,0
        jr $ra
        
#-------------------------------- Escribir archivo ------------------------------------

writeFile:
	addi $t0, $a0,0       #Numero a convertir
	addi $s2,$sp,0
	addi $t6,$zero,0
	#Apilar separador
	addi $sp,$sp,-1
	addi $t1,$s7,-48
	sb $t1,($sp)	
	loopWrite:
		beqz $t0, endLoopWrite
		slt $t5,$zero,$t0	#if(t0>zero)==> t5 = 1, else t5=0 
		beqz $t5,isNegative 
		div $t0,$t0,10	
		mfhi $t4	#capruta el residuoo
		j continue
		isNegative:
			addi $t6,$zero,-3	#45-48 = '-' en codigo ASCCI
			mul $t0,$t0,-1	
			j loopWrite
		continue:
		addi $sp,$sp, -1
		sb $t4,($sp)
		j loopWrite
	endLoopWrite:
		beq $t6,$zero,noNegative
		add $sp,$sp, -1
		sb $t6,($sp)
		noNegative:	
		sub $s3,$s2,$sp     #Numero de caracteres detectados
		addi $v0,$zero 9    #Creando modo de solicitud de memoria en el HEAP
		addi $a0, $s3, 0	
		add $a0,$a0,1      #Aumentando 1 caracter para el terminador 0 (los asciiz terminan con el byte 0)
		syscall            #Solicitando la memoria, en este modo, syscall 9 retorna la base de la memoria en $v0
		add $s1,$v0,0      #Sacando un backup en $s1 de la base del nuevo arreglo de asciiz recien creado por syscall 9
		add $t0, $s1,0     #Creamos un puntero para ir llenando el arreglo en el siguiente loop
	loopWriteReverse:
		beq $sp,$s2,endLoopWriteReverse #Si el puntero de la pila no ha llegado al origen
		lb $t1,($sp)
		add $t1,$t1,48
		sb $t1,($t0)
		add $t0,$t0,1      #Pasamos al siguiente .word en el puintero a la cadena
		add $sp,$sp,1      #Nos movemos al siguiente elemento en la pila, en reversa
		j loopWriteReverse
	endLoopWriteReverse:
		sb $zero,($t0)     #Agregamos la terminacion el zero (null), del ultimo caracter para formar un asciiz valido
		lw $t1,268697600
		sw $t1,268697600
		#Imprimos el asciiz final
		addi $v0, $zero, 4    #Modo de impresion de asciiz (strings)
		add $a0, $s1,0        #Finalmente cargamos la direccion de nuestro numero .word convertido a cadena .asciiz
		syscall
		addi $sp,$s2,0
		jr $ra	
		
#-------------------------------Create txt-------------------------------
    	# HOW TO WRITE INTO A FILE
createTxt:   	
    	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0, fileName2    	# get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	addi $s1,$v0,0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	addi $a0,$s1,0		# file descriptor
    	la $a1,268697600		# the string that will be written
    	mul $t2,$s4,4
    	la $a2,($t2)		# length of the toWrite string
    	#la $a2,30		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall

		

	
