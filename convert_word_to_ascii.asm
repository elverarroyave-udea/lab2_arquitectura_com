.data
numero: .word 2342
test: .asciiz "test"
aviso: .asciiz "Numero a convertir: "
saltodelinea: .asciiz "\n"
aviso2: .asciiz "Cadena convertida: " 
fileName: .asciiz "C:/mips/input_file2.txt"
.text

main:
	la $t0,test
	lb $t0,($t0)
	#Voy a imprimirel numero, 12345 a nivel de ejemplo, para eso uso sysca1l 4
	
	addi $v0, $zero, 4    #Establezco el modo de operacion para syscall 4
	la $a0, aviso
	syscall       
	addi $v0, $zero, 1    #Establezco el modo de operacion para syscall 1
        la $a0, numero
        lw $a0,($a0)
        syscall
        
        add $t0, $a0,0       #Numero a convertir
        
#	la $t0, cadena         #Inicializando contadoral inicio de la cadena (Posicion de memoria, address de la base del arreglo asciiz)
	#add $s0, $sp, 0        #Sacamos un backup de la base de la pila para no perdernos luego y poder recorrerla inversamente
	
	add $s0,$sp,0
	loop:
		beqz $t0, FinLoop
		div $t0,$t0,10	
		mfhi $t4
		add $sp,$sp, -1
		sb $t4,($sp)
		j loop
	FinLoop:
		sub $s3,$s0,$sp     #Numero de caracteres detectados
		addi $v0,$zero 9    #Creando modo de solicitud de memoria en el HEAP
		addi $a0, $s3, 0
		add $a0,$a0,1      #Aumentando 1 caracter para el terminador 0 (los asciiz terminan con el byte 0)
		syscall            #Solicitando la memoria, en este modo, syscall 9 retorna la base de la memoria en $v0
		addi $s1,$v0,0      #Sacando un backup en $s1 de la base del nuevo arreglo de asciiz recien creado por syscall 9
		addi $t0, $s1,0     #Creamos un puntero para ir llenando el arreglo en el siguiente loop
	loop2:
		beq $sp,$s0,finLoop2 #Si el puntero de la pila no ha llegado al origen
		lb $t1,($sp)
		add $t1,$t1,48
		sb $t1,($t0)
		add $t0,$t0,1      #Pasamos al siguiente word en el puintero a la cadena
		add $sp,$sp,1      #Nos movemos al siguiente elemento en la pila, en reversa
		j loop2		
	finLoop2:
		#sb $zero,($t0)     #Agregamos la terminacion el zero (null), del ultimo caracter para formar un asciiz valido		
		#Imprimos el asciiz final
		addi $v0, $zero, 4    #Modo de impresion de asciiz (strings)
		la $a0, saltodelinea  #Dejamos un regnlon imprimiendo el string \n
		syscall            
		la $a0, aviso2        #Imprimimos el aviso de Cadena convertida
		syscall
		add $a0, $s1,0        #Finalmente cargamos la direccion de nuestro numero .word convertido a cadena .asciiz
		syscall
	
	
	
	
