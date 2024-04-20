# .data
# NUMDOTS: .word 200
# WIDTH: .word 640
# HEIGHT: .word 480
# MAXVEL: .word 7
# MAXSTEP: .word 400
# NUMVECTORS: .word 400
# GOALX: .word 320 #x location on VGA of center of goal
# GOALY: .word 60  #y location on VGA of center of goal
# STARTX: .word 320 #x location on VGA of dots' start location
# STARTY: .word 420 #y location on VGA of dots' start location
# MUTATIONRATE: .word 4 #How likely a dot's vector is to mutate when being born (likely out of 128 by using lfsr rng)
# # STARTING_ADDR: .word 0x100 #Starting addr for  dots
# START_ADDR: .word 1000 

#GLOBAL VARIABLES TO GO IN MEMORY
#MAXSTEP
#LOCATION OF LIST HEAD

main:
nop
nop
nop
nop
nop

init_dots:
addi $s0, $zero, 2       # Load NUMDOTS
addi $s1, $zero, 0 # Initialize counter for initializing all dots
addi $t2, $zero, 1000    # Load starting addr (head)
add $t1, $zero, $t2 #t1 is current (initialized to head)
addi $s3, $zero, 4 #s3 has the number of vectors needed to be created
sll $s3, $s3, 1 #multiply s3 by 2 to account for x and y in each vector = 2*NUMVECTORS

addi $t8, $zero, 320 #start location X for dots
addi $t9, $zero, 420 #start location Y for dots

loop_dots:

# Initialize variables for current dot
sw $t8, 0($t1)      # x start position
sw $t9, 1($t1)      # y start position
sw $zero, 2($t1)      # x velocity
sw $zero, 3($t1)     # y velocity
sw $zero, 4($t1)     # dead status
sw $zero, 5($t1)     # reachedGoal status
sw $zero, 6($t1)     # champion status
sw $zero, 7($t1)     # numSteps
sw $zero, 8($t1)     # fitness

addi $s2, $zero, 0 #initialize random vector creation counter
loop_random: #creating the random vectors
lw $t5, 99($zero) #getting a random value from the LFSR
add $t6, $t1, $s2 #t6 is the address to put random value in the brain (current+vector number)
sw $t5, 10($t6) #10 is vector 0 of the brain for current dot
addi $s2, $s2, 1 #increment random vector counter
blt $s2,  $s3, loop_random #if rand counter < 2*NUMVECTORS

# Set the next pointer, check if it's not the last dot
# addi $t4, $s1, 1      # next dot index
addi $t4, $t1, 810 #810 total words in a dot-> moving to the next one t4 = location of next dot
update_next:
sw $t4, 9($t1)       # dot.next = t4

increment_counter:
addi $s1, $s1, 1
addi $t1, $t4, 0 #setting t1 to dot.next for next loop
blt $s1, $s0, loop_dots  # Continue loop if not done w dots
sw $zero, -801($t1)  # next pointer of last dot is zilch -> was written to earlier, but is now set to 0 (have to go back in memory because t1 was set to next) 

addi $a0, $t2, 0 #set input to head of the linkedlist
# addi $sp, $zero, 2 #testing
lw $sp, 9($a0)
run:
nop
nop
j run
