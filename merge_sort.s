#Start is starting address
#$s0 is the size*4
#$s1 is the End address
#$s2 is the step, which is the number of items per pod.
#$s3 is the address for the first (p1)
#$s4 is the address for the second (p2)
#$s5 is "next"

	.data
space:	.asciiz " "
HMI:	.asciiz "How many ints? "
NI:	.asciiz "Next int: "
Start:	.word 0	#First address
	.text
	.globl main
main:
	li	$v0, 4 #Asks how many ints
	la	$a0, HMI
	syscall
	li	$v0, 5	#Input for ints
	syscall

	add	$t0, $zero, $v0 #Saves loop counter
	sll	$t0, $t0, 2	#Shifts loop counter
	add	$s0, $zero, $t0 #Saves permanent Size. 
	la 	$t1, Start	#Loads starting point into a registry for the loop.

loop:	
	li	$v0, 4	#Request Int
	la	$a0, NI
	syscall
	li	$v0, 5	#receives input
	syscall
	
	sw	$v0, 0($t1) #stores word
	add 	$t1, $t1, 4 #increments address for next word
	add	$t0, $t0, -4 #de-increments iterator
	bnez	$t0, loop
#End of loop


	add	$s1, $t1, -4 	#Creating End Address
	li	$s2, 4		#sets step to the initial 4
mCall:	la	$s3, Start	#p1 is start
	add	$s4, $s3, $s2	#p2 is start + step
	slt	$t0, $s2, $s0	#step < size?
	beqz	$t0, Done	#finish if step >= size
sCall:	add	$s5, $s4, $s2	#the next starting point for merge
	jal	merge
loop2:
	slt	$t0, $s1, $s5	#next > end
	bnez	$t0, incStep	#if next > end, then go to incStep
	add	$s3, $s5, 0	#set p1 to next
	add	$s4, $s3, $s2	#set p2 to p1+step
	beqz	$zero, sCall
Done:
	la	$t0, Start	#Loads start address 4 back to make comparison easier
	add	$t0, $t0, -4
ploop:	
	lw	$t1, 4($t0)	#loads word 4 forward to be accurate
	li	$v0, 1		#prints out int and adds a space
	move 	$a0, $t1
	syscall
	li	$v0, 4
	la	$a0, space
	syscall
	add	$t0, $t0, 4	#increments address to next location
	bne	$t0, $s1 ploop	#If not at the end, loop
	li	$v0, 10
	syscall	
incStep:
	sll	$s2, $s2, 1	#doubles the step
	beqz	$zero, mCall	#calls mCall
	






merge:
	add	$t1, $s3, 0
	add	$t2, $s4, 0
	lw	$t3,0($t1)
	lw	$t4 0($t2)
comp:	slt	$t0, $t3, $t4
	beqz	$t0, add2
#add1
	add	$sp, $sp, -4
	sw	$t3, 0($sp)
	add	$t1, $t1, 4
	beq	$t1, $s4, flsh2
	lw	$t3,0($t1)
	beqz	$zero, comp
add2:
	add	$sp, $sp, -4
	sw	$t4, 0($sp)
	add	$t2, $t2, 4
	beq	$t2, $s5, flsh1
	lw	$t4 0($t2)
	beqz	$zero, comp
flsh1:
	add	$sp, $sp, -4
	sw	$t3, 0($sp)
	add	$t1, $t1, 4
	beq	$t1, $s4, mergeD
	lw	$t3,0($t1)
	beqz	$zero, flsh1
flsh2:
	add	$sp, $sp, -4
	sw	$t4, 0($sp)
	add	$t2, $t2, 4
	beq	$t2, $s5, mergeD
	lw	$t4,0($t2)
	beqz	$zero, flsh2
mergeD:
	la	$t6, -4($s5)
loop3:	
	lw	$t7, 0($sp)
	sw	$t7, 0($t6)
	add	$sp, $sp, 4
	add	$t6, $t6, -4
	bne	$t6, $s3 loop3	
	lw	$t7, 0($sp)
	sw	$t7, 0($t6)
	add	$sp, $sp, 4
	add	$t6, $t6, -4
	jr	$ra
