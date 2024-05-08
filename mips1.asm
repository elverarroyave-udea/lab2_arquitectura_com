#Directiva para ubicarnos en la memoria de datos
.data
mns: .asciiz "El valor de t0 es: "

value1: .asciiz "Ingrese el valor 1: "
value2: .asciiz "Ingrese el valor 2: "

#Directiva para ubicarnos en la memoria de instrucciones
.text
	la $a0, value1
	li $v0, 4
	syscall 
	
	la $v0, 5
	syscall
	
	# Moving the integer input to another register
   	move $t0, $v0
	

	
	