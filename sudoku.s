#James Galante, Josh Wienick

.data
newline:.asciiz "\n"		# useful for printing commands
star:	.asciiz "*"
board1: .word 128 511 511 16 511 511 4 2 511 64 511 4 1 511 511 8 511 511 1 2 511 511 511 256 511 511 128 32 16 511 511 256 4 511 128 511 511 256 511 511 511 511 511 1 511 511 128 511 32 2 511 511 256 4 2 511 511 8 511 511 511 32 64 511 511 32 511 511 128 1 511 2 511 64 8 511 511 32 511 511 16
board2: .word 128 8 256 16 32 64 4 2 1 64 32 4 1 128 2 8 16 256 1 2 16 4 8 256 32 64 128 32 16 1 64 256 4 2 128 8 4 256 2 128 16 8 64 1 32 8 128 64 32 2 1 16 256 4 2 1 128 8 4 16 256 32 64 16 4 32 256 64 128 1 8 2 256 64 8 2 1 32 128 4 16
	
.text
# main function
main:
	sub  	$sp, $sp, 4
	sw   	$ra, 0($sp) # save $ra on stack

	# test singleton (true case)
    li    $a0, 0x010 ##sigleton value 16
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1

	# test singleton (false case)
    li    $a0, 0x10b ##not a sigleton value
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# test get_singleton 
	li	$a0, 0x010
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
#	# this should print 4

	# test get_singleton 
	li	$a0, 0x008
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 3

	# test board_done (true case)
	la	$a0, board2
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1
	
	# test board_done (false case)
	la	$a0, board1
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# print a newline
	li	$v0, 4
	la	$a0, newline
	syscall

	# test print_board
	la	$a0, board1
	jal	print_board

	# should print the following:
	# 8**5**32*
	# 7*31**4**
	# 12***9**8
	# 65**93*8*
	# *9*****1*
	# *8*62**93
	# 2**4***67
	# **6**81*2
	# *74**6**5

	lw   	$ra, 0($sp) 	# restore $ra from stack
	add  	$sp, $sp, 4
	jr	$ra

print_int_and_space:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element

	li   	$a0, 32        	# print a black space (ASCII 32)
	li   	$v0, 11        	# load the syscall option for printing chars
	syscall              	# print the char
	
	jr      $ra          	# return to the calling procedure

print_newline:
	li	$v0, 4		# at the end of a line, print a newline char.
	la	$a0, newline
	syscall	    
	jr	$ra

print_star:
	li	$v0, 4		# print a "*"
	la	$a0, star
	syscall
	jr	$ra
	
	
# ALL your code goes below this line.
#
# We will delete EVERYTHING above the line; DO NOT delete 
# the line.
#
# ---------------------------------------------------------------------
	
## bool singleton(int value) {  // This function checks whether
##   return (value != 0) && !(value & (value - 1));

##}


##li $t0, 0x010  ## value = 16
singleton:
    addi $sp, $sp, -8    #2 stack itens
    sw   $ra, 4($sp)        #return address
    sw   $a0, 0($sp)    #parameter

    beq $a0, $0, zeroCase        #0 go to zeroCase
    bne $a0, $0, oneCase        #1 jump to oneCase

zeroCase:
    li $v0, 0    #return 0
    j  EndCase

oneCase:
    sub $t0, $a0, 1    #value - 1
    and  $t0, $a0, $t0    #value & (value - 1)
    beq $t0, $0, case3      #zeroCase
    bne $t0, $0, zeroCase     #case3

case3:
    li $v0, 1   #ruturn 1
    j  EndCase

EndCase:
    lw   $a0, 0($sp) #remove from stack
    lw   $ra, 4($sp) #remove from stack
    addi $sp, $sp, 8 #remove from stack

jr    $ra


## int get_singleton(int value) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
##      if (value == (1<<i)) {
##         return i;
##      }
##   }
##   return 0;
## }
get_singleton:
    addi $sp, $sp, -8    #2 stack itens
    sw   $ra, 4($sp)        #return address
    sw   $a0, 0($sp)    #parameter

    li $t0, 0
    li $t1, 9
Loop:
    beq $t0, $t1, LOOPDONE
    li $s1, 1
    sll $t2, $s1, $t0 #shift 1 left by i bits
    addi $t0, $t0, 1 #i++
    bne $a0, $t2, Loop
    sub $t0, $t0, $s1  #make up for early addition of i before bne
    move $v0, $t0
    j Exit

    LOOPDONE: li $v0, 0
Exit:
    lw   $a0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8

    jr    $ra



## bool
## board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		if (!singleton(board[i][j])) {
## 		  return false;
## 		}
## 	 }
##   }
##   return true;
## }

board_done:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $a0, 0($sp)

    move $s0, $a0 #put parameter into s0
    li $t0, 4   #index calculating
    li $t1, 0 #i
    li $t3, 9 #gridSquared

iLoop:
    li $t2, 0
    beq $t1, $t3, trueCase #true
jLoop:
    beq $t2, $t3, iPlusPlus #end loop if 9
    mul $t4, $t1, $t3 #ix9
    add $t4, $t4, $t2 # ix9+j
    mul $t4, $t4, 4 #(ix9+j)*4
    add $t6, $s0, $t4 #Board[i][j]
    lw $t7, 0($t6)
    add $a0, $t7, $0
    jal singleton #call singleton
    beq $v0, $0, falseCase #return false
    addi, $t2, $t2, 1 #j++


iPlusPlus:
    addi $t1, $t1, 1 #i++
    j iLoop

falseCase:
    li $v0, 0
    j END

trueCase:
    li $v0, 1
    j END

END:
    lw $ra, 8($sp)
    lw $s0, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 12
    jr    $ra



## void
## print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {

## 		int value = board[i][j];
## 		char c = '*';
## 		if (singleton(value)) {
## 		  c = get_singleton(value) + '1';
## 		}
## 		printf("%c", c);
## 	 }
## 	 printf("\n");
##   }


## }

print_board:
    addi $sp, $sp, -28 #space on stack for vars
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s3, 12($sp)
    sw $s3, 8($sp)
    sw $s4, 4($sp)
    sw $a0, 0($sp)


    move $s0, $a0  #save parameter as s0
    li $t0, 4        #4 for index
    li $s2, 0        #i loop var
    li $s4, 9        #GRID_SQUARED

boardLoop:
    li $s3, 0        #j loop var
    beq $s2,$s4,EndBoard    #true

BoardPrint1:
    beq $s3,$s4,PrintAndAdd    #End inner loop go to outer if j=9
    mul $t4,$s2,$s4        #ix9
    add $t4,$t4,$s3        #ix9+j
    mul $t4,$t4,4        #(ix9+j)*4
	add $t6,$s0,$t4        #Board[i][j]
    lw  $t7, 0($t6)
    li  $s1, 42        #c = *
    add $a0,$t7,$0        #Setting  parameter for singleton
    jal singleton        #singleton(value)
    addi $s3,$s3,1        #j++
    bne $v0, $0, char        #if(!singleton(board[i][j]))
    j charPrint

char:
    addi $a0, $t7, 0    #Board[i][j]
    jal get_singleton
    addi $s1, $v0, 49    #c = get_singleton(value) + '1'
    j charPrint

charPrint:
    addi  $a0, $s1, 0    #set argument = c
    li    $v0, 11        #allows to print chars
    syscall
    j BoardPrint1

PrintAndAdd:
    addi $s2,$s2,1        #i++
    jal print_newline
    j boardLoop

falseCase2:
    li $v0,0
    j EndBoard

PrintBoardReturn:
    li $v0,1
    j EndBoard

EndBoard:
    lw $ra,24($sp) ##remove everyting from stack
    lw $s1,20($sp)
    lw $s2,16($sp)
    lw $s3,12($sp)
    lw $s4,8($sp)
    lw $s4,4($sp)
    lw $a0,0($sp)
    addi $sp, $sp, 28
    jr    $ra


