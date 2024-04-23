main:
nop
nop
nop
# addi $26, $zero, 0
# addi $27, $zero, 131071 #25MHz -> 17 bit immediate -> 131071 largest pos, so shift left 9 to get ~3 second delay before running the code
# sll $27, $27, 9 #191850/4 ~= 47962

# startup:
# addi $26, $26, 1
# blt $26, $27, startup
# nop
# nop

# TODO -> INITIALIZE everything with a prev word
init_dots:
addi $s0, $zero, 4     # Load NUMDOTS
addi $s1, $zero, 0      # Initialize counter for initializing all dots
addi $t2, $zero, 1000   # Load starting addr (head)
add $t1, $zero, $t2     # $t1 = current (initialized to head)
addi $s7, $zero, 0      # $s7 = prev (initialized to 0 for 0th dot)
addi $s3, $zero, 5    # $s3 = NUMVECTORS number of vectors needed to be created 
sll $s3, $s3, 1         # $s3 mult by 2 to account for x and y in each vector (2*NUMVECTORS)
addi $t8, $zero, 320    # $t8 = start location X for dots
addi $t9, $zero, 420    # $t9 = start location Y for dots

# Initialize variables for current dot
loop_dots:
sw $t8, 0($t1)      # x start position
sw $t9, 1($t1)      # y start position
sw $zero, 2($t1)    # x velocity
sw $zero, 3($t1)    # y velocity
sw $zero, 4($t1)    # dead status
sw $zero, 5($t1)    # reachedGoal status
sw $zero, 6($t1)    # champion status
sw $zero, 7($t1)    # numSteps
lw $t5, 99($zero)   # $t5 = getting a random value from the LFSR
nop
nop
sw $t5, 8($t1)    # fitness
# sw $zero, 9($t1)    # nextDot -> not necessary because it comes in update next
sw $s7, 10($t1)   # prevDot

addi $s2, $zero, 0  # initialize random vector creation counter

# Creating the random vectors
loop_random:
lw $t5, 99($zero)   # $t5 = getting a random value from the LFSR
add $t6, $t1, $s2   # $t6 = address to put random value in the brain (current + vector number)
sw $t5, 11($t6)     # 11 is vector 0 of the brain for current dot
addi $s2, $s2, 1    # increment random vector counter
blt $s2,  $s3, loop_random  #if rand counter < 2*NUMVECTORS
# Set the next pointer, check if it's not the last dot
# addi $t4, $s1, 1  # next dot index
addi $t4, $t1, 811  # $t4 = location of next dot (811 total words in a dot -> moving to the next one)

update_next:
sw $t4, 9($t1)      # $t4 = dot.next

increment_counter:
addi $s1, $s1, 1    # increment counter 
addi $s7, $t1, 0    #setting s7 (prev) = current for next loop
addi $t1, $t4, 0    #setting t1 (current) to dot.next for next loop
blt $s1, $s0, loop_dots     # Continue loop if not done w dots
# sw $zero, -802($t1) # next pointer of last dot is zilch -> was written to earlier, but is now set to 0 (have to go back in memory because t1 was set to next) 
sw $zero, 9($s7) # previous dot (last in list) has a .next=0
addi $a0, $t2, 0    # set input to head of the linkedlist



# sort all of the dots based on fitness
sort:

sortrecur:
addi $t7, $zero, 0          # $t7 = 0
add $t0, $a0, $zero         # $t0 = head
add $t1, $t0, $zero         # $t1 = current
j siguard

sortiter:
lw $t2, 8($t1)              # $t2 = current fitness
lw $t3, 8($t6)              # $t3 = current.next fitness
blt $t2, $t3, sinext        # if current fitness < next fitness, go to sinext
addi $t7, $zero, 1          # $t7 = 1
lw $t4, 10($t1)             # $t4 = current.prev
bne $t4, $zero, supprev     # if current.prev != 0, go to supprev
j supprevd

supprev:
sw $t6, 9($t4)             # current.prev.next = current next

supprevd:
sw $t4, 10($t6)             # current.next.prev = current.prev
lw $t5, 9($t6)             # $t5 = current.next.next
bne $t5, $zero, supnnprev   # if current.next.next != 0, go to supnnprev
j supnnprevd

supnnprev:
sw $t1, 10($t5)             # current.next.next.prev = current

supnnprevd:
sw $t5, 9($t1)             # current.next = current.next.next
sw $t1, 9($t6)             # current.next.next = current
sw $t6, 10($t1)             # current.prev = current.next
bne $t0, $t1, sinext        # if head != current, go to sinext
add $t0, $t6, $zero         # head = current.next

sinext:
add $t1, $t6, $zero         # $t1 = current.next

siguard:
lw $t6, 9($t1)              # $t6 = current.next
bne $t6, $zero, sortiter    # if current.next != 0, go to sortiter
add $a0, $t0, $zero         # $a0 = head
bne $t7, $zero, sortrecur   # if $t7 != 0, go to sortrecur
add $v0, $t0, $zero         # $v0 = head

# jr $ra
lw $v0, 9($v0)
lw $v0, 9($v0)
lw $26, 10($v0)
lw $27, 9($v0)
lw $28, 8($v0)
lw $29, 10($27)
lw $30, 9($27)
lw $31, 8($27)
