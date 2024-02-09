	.data 
#variables... yay
	num_of_nums:	.asciiz "How many numbers would you like to sort?(1-10): "
	error:		.asciiz "The number you entered was outside the given range, try again: "
	new_line:	.asciiz "\n"
	enter_num:	.asciiz "Enter a number: "
	comma:		.asciiz ", "
	number:		.word 0 
	counter:	.word 0
	array1:		.word 1:10
	array2:		.word 3:10
	num1: 		.word 0
	num2:		.word 0
	temp:		.word 0
	
	.text 
	.globl main

main:
	la $s0, array1		#load first array
	la $t3, array2		#load second array
	lw $t6, number		#set t6 to zero for looping later
	li $t5, 0
	jal Read_nums		#read in how many numbers to take in
	jal Input_nums		#read in the numbers and store into memory
	jal BBsort		#moving around the numbers in memory so that they are in order 
	jal Print_nums		#take the ordered numbers from memory and print them
	
	#---------------------------------------------# end of program
	li $v0, 10
	syscall			#end the program gracefully

Read_nums:
	la $a0, num_of_nums	#print the prompt to get how many numbers the user wants
	li $v0, 4
	syscall
	li $v0, 5		#get the integer as input
	syscall
	move $s1, $v0		#move the result to $s1 as the count for the length of the array
	blt $s1, 1, get_int_error	#if the input is too small
	bgt $s1, 10, get_int_error	#if the input is too big
	jr  $ra

get_int_error:
	la $a0, error		#print error message
	li $v0, 4		
	syscall
	li $v0, 5		#get new input until the new input is right
	syscall
	move $s1, $v0		#move the result to $s1 as the count for the length of the array
	blt $s1, 0, get_int_error	#if the input is too small
	bgt $s1, 10, get_int_error	#if the input is too big
	jr $ra
	
Input_nums:
	la $a0, enter_num
	li $v0, 4
	syscall			#print the prompt for the user
	li $v0, 5
	syscall			#prompt the user the the number
	sw $s0, -44($sp)
	sw $v0, 0($sp)
	sw $v0, ($s0)		# save the number to both the stack pointer and the allotted memory for the array
	addiu $s0, $s0, 4	# add 4 to the address for each byte in memory
	addiu $sp, $sp, -4	#sub 4 from the sp to move up one byte
	addiu $t6, $t6, 1	#add one to the counter for however many numbers the user wants to sort
	blt $t6, $s1, Input_nums
	li $t1, 4
	mult $t1, $s1
	mflo $t1
	addu $sp, $sp, $t1
	lw $s0, -44($sp)	#restore the original value of t0
	jr $ra
	
BBsort:
	lw $s3, temp		#load and store temp for later use
	lw $s4, num1		#load and store num1 for later use
	lw $s5, num2		#load and store num2 for later use
	li $s6, 0		#load in number for looping purposes later
	li $t4, 40
	sw $s0, -8($sp)
	li $s7, 1		
	sw $ra, -12($sp)
	j loop2

loop2:
	addiu $s6, $s6, 1		#add one count to the loop
	blt $s7, $s1, bbsort_loop	#first loop to iterate through the numbers in the list once
	li $s7, 1			#reset the count of the iterating number for the loop to properly reset
	blt $s6, $t4, loop2		#starting the main for-loop over and running it 40 times to make sure the program iterates enough times to sort all the numbers
	lw $ra, -12($sp)		#restore the return address
	jr $ra				#going back to the main function
	
bbsort_loop:
	
	lw $s4, 0($s0)		#storing the numbers into the stack pointer 
	lw $s5, 4($s0)
	subu $t1, $s5, $s4	#subtracting the 1st number from the 2nd in place of blt so I can link back to this part of the program
	bltzal $t1, switch	#if the number is negative i.e. less than zero it will jump to switch and I can link back to this 
	sw $s4, 0($s0)		#storing the result of switch or keeping the numbers as they are 
	sw $s5, 4($s0)
	addiu $s0, $s0, 4	#looking at the different bytes of the array
	addiu $s7, $s7, 1	#adding one to the counter of the for-loop
	blt $s7, $s1, bbsort_loop
	lw $s0, -8($sp)
	j loop2
	
	
switch:
	move $s3, $s4		#set the high number in temp
	move $s4, $s5		#set the low number into the old high number
	move $s5, $s3		#change the old low number to the high number that is in temp
	jr $ra
	
Print_nums:
	lw $a0, 0($s0)		#load each individual number
	li $v0, 1		
	syscall			#print each number... (on the same line)
	la $a0, comma		#load the comma to separate each number
	li $v0, 4
	syscall			#print the comma
	addiu $t5, $t5, 1	#add one to the number for looping
	addiu $s0, $s0, 4	#add four to the array memory location for the next byte
	blt $t5, $s1, Print_nums
	jr $ra