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
addi $s3, $zero, 4 #s3 has the NUMVECTORS number of vectors needed to be created
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

j run #jump to run when done


#make the dots change position
move: #take in address of the dot being moved (a0) and its dot number (a1) (dot0, dot11, etc)

# If not dead or reachedGoal
lw $t1, 4($a0) #load dead
lw $t2, 5($a0) #load reachedGoal
bne $zero, $t1 move_exit #if dead or reachedGoal, exit
bne $zero, $t2 move_exit

# dot.Acceleration = brain[numSteps]
lw $t3, 7($a0) #$t3 = numSteps
add $t4, $t3, $a0 #$t4 = numSteps+address (getting the acceleration vector address for that step)
lw $t1, 10($t4) #$t1 = X coordinate of acceleration for that step
lw $t2, 11($t4) #$t2 = Y coordinate of acceleration for that step

# Numsteps +=1
addi $t3, $t3, 1 #numsteps = numsteps + 1
sw $t3, 7($a0) #storing incremented numsteps value

# Dot.velocity = dot.velocity + dot.Acceleration
lw $t5, 2($t4) #$t5 = X coordinate of velocity
lw $t6, 3($t4) #$t6 = Y coordinate of velocity

add $t5, $t5, $t1 #Xvel = xvel+xacc
add $t6, $t6, $t2 #Yvel = Yvel+Yacc

# If dot.velocity (in either direction) > maxVelocity:
# Set dot.velocity to maxVelocity

addi $t7, $zero, 7 #$t7 = maxvel
sub $t0, $zero, $t7 #$t0 = -MAXVEL

blt $t7, $t5, fix_posx #if xvel > maxvel ($t7)
blt $t5, $t0, fix_negx #if xvel < -maxvel ($t0)
ok_xvel:
blt $t7, $t6, fix_posy #if yvel > maxvel ($t7)
blt $t6, $t0, fix_negy #if yvel < -maxvel ($t0)
j ok_vel

#standardizing velocity within a range
fix_posx:
addi $t5, $zero, 7 #set X vel to MAXVEL
j ok_xvel
fix_negx:
addi $t5, $zero, -7 #set X vel to -MAXVEL
j ok_xvel

fix_posy:
addi $t6, $zero, 7 #set Y vel to MAXVEL
j ok_vel
fix_negy:
addi $t6, $zero, -7 #set Y vel to MAXVEL

ok_vel:
# Dot.position = dot.position + dot.velocity
lw $t8, 0($a0) #x position
lw $t9, 1($a0) #y position
add $t8, $t8, $t5 #xpos = xpos+xvel
add $t9, $t9, $t6 #ypos = ypos+yvel
sw $t8, 0($a0) #store x position
sw $t9, 1($a0) #store y position

#load dot.position into the registers in VGAcontroller
# TODO: change this if we ever change the convention for where the memory mapped goes
sw $t8, 100($a1) #storing Xpos to corresponding VGA register
sw $t9, 550($a1) #storing Ypos to corresponding VGA register

# If dot.position outside of boundaries of arena or numSteps >= maxStep:
    # Dot.dead = true
sub $t0, $zero, $t7
addi $t0, $t0, 640 #t0 = Width-Maxvel
blt $t8, $t7, make_dead #if xpos(t8) < maxvel($t7) -> left side boundary of arena
blt $t0, $t8, make_dead #if xpos(t8) > Width-maxvel($t0) -> right side boundary of arena
sub $t0, $zero, $t7
addi $t0, $t0, 480 #t0 = height-Maxvel
blt $t9, $t7, make_dead #if ypos(t9) < maxvel($t7) -> top boundary of arena
blt $t0, $t9, make_dead #if Ypos(t9) > Height-maxvel($t0) -> bottom boundary of arena

addi $t0, $zero, 400
blt $t0, $t3, make_dead #if MAXSTEP < Numsteps, make dead
j check_at_goal

make_dead:
addi $t1, $zero, 1 #init 1 for set to true
sw $t1, 4($a0) #setting dead to true
j move_exit

# TODO: wrap this up
# elif dot.position inside of goal:
    # dot.reachedGoal = true
check_at_goal:
addi $t0, $zero, 10
addi $t2, $zero, 320 #t2 = goalX
add $t2, $t2, $t0 #$t2 = GoalX + 10 (right boundary)
blt $t2, $t8, not_reachedGoal #if Xpos > goal right boundary, not in goal
addi $t2, $zero, 60 #t2 = goalY
add $t2, $t2, $t0 #$t2 = GoalY + 10 (bottom boundary)
blt $t2, $t9, not_reachedGoal #if Ypos > goal right boundary, not in goal

addi $t0, $zero, -10
addi $t2, $zero, 320 #t2 = goalX
add $t2, $t2, $t0 #$t2 = GoalX - 10 (left boundary)
blt $t8, $t2, not_reachedGoal #if Xpos < goal left boundary, not in goal
addi $t2, $zero, 60 #t2 = goalY
add $t2, $t2, $t0 #$t2 = GoalY - 10 (bottom boundary)
blt $t9, $t2, not_reachedGoal #if Ypos < goal top boundary, not in goal

make_reachedGoal:
addi $t1, $zero, 1 #init 1 for set to true
sw $t1, 5($a0) #setting reachedgoal to true
j move_exit

not_reachedGoal:

move_exit:
jr $ra




run: #loop over this for all of time
# addi $sp, $zero, 3 #testing
add $s0, $a0, $zero #head of linkedlist
addi $s2, $zero, 2 #while counter < NUMDOTS, we loop move

addi $s3, $zero, 0 #counter for which step we're on
addi $s4, $zero, 4 #MAXSTEP

play_generation: #loop through this to play out the entire generation's movement

add $s1, $zero, $zero #counter for which dot we're moving = 0

move_step:
# a0 is already the address of the needed dot
add $a1, $s1, $zero #which dot is being moved
jal move
lw $a0, 9($a0) #loading dot.next for next loop over the dots
addi $s1, $s1, 1 #increment dotID
# addi $sp, $zero, 6 #testing
blt $s1, $s2, move_step
#before looping need to make sure $a0 is head of linkedlist

add $a0, $s0, $zero #making $a0 the head of the linkedlist
addi $s3, $s3, 1 #increment step counter
# addi $sp, $zero, 7 #testing
inc $zero, $zero, 0 #increment the generation counter
blt $s3, $s4, play_generation
inc $zero, $zero, 0 #increment the generation counter

stop:
nop
nop
nop
j stop



# move:
# nop
# addi $30, $zero, 69
# nop
# jr $ra

