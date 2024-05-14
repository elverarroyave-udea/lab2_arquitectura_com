	.text
	.globl main
	
main:
    	# HOW TO WRITE INTO A FILE
    	
    	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,1           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,toWrite		# the string that will be written
    	la $a2,21		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall

#STRINGS
.data
toWrite: .asciiz "Hello Wor   ld was her edddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
fileName: .asciiz "C:/mips/input_file2.txt"
