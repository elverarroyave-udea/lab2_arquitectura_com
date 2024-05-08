.data
vector:  .word 2, 12, 6, 41, 18, 31, 53
length:  .word 7
mensaje1: .asciiz "Fin de la ejecución!"

.text
.globl main
main:
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
