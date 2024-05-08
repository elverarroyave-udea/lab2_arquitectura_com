#--------------------entero-------------------- 
.data
 #Tipos de variables en MIPS
 	numero: .word 5
 .text
 	main:
 	li $v0, 1
 	lw $a0, numero
 	syscall
# -------------------flotante---------------------
 .data
 #Tipos de variables en MIPS
 	flotante: .float 5.5
 .text
 	main:
 	li $v0,2
 	lwc1 $f12, flotante
 	syscall
 #-----------------------double-------------------
 .data
 #Tipos de variables en MIPS
 	flotante: .double 5.24
 .text
 	main:
 	li $v0,3
 	ldc1 $f12, flotante
 	syscall
#----------------------palabra--------------------
 .data
 #Tipos de variables en MIPS
 	palabra: "Hola mundo"
 .text
 	main:
 	li $v0,4
 	la $a0, palabra
 	syscall
 #--------------------input-entero------------------
  .data
 #Tipos de variables en MIPS
 	mensaje1: .asciiz "ingresa tu numero"
 	mensaje2: .asciiz "Este es tu numero" 
 .text
 	main:
 	li $v0,4
 	la $a0, mensaje1
 	syscall
 	li $v0, 5
 	move $t0, $v0
 	syscall
 	li $v0,4
 	la $a0, mensaje2
 	syscall
 	li $v0,1
 	move $a0,$t0
 	syscall
