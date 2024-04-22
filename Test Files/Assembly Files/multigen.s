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
addi $26, $zero, 0
addi $27, $zero, 131071 #25MHz -> 17 bit immediate -> 131071 largest pos, so shift left 9 to get ~3 second delay before running the code
sll $27, $27, 9 #191850/4 ~= 47962

startup:
addi $26, $26, 1
blt $26, $27, startup
nop
nop

# TODO -> INITIALIZE everything with a prev word
init_dots:
addi $s0, $zero, 38     # Load NUMDOTS
addi $s1, $zero, 0      # Initialize counter for initializing all dots
addi $t2, $zero, 1000   # Load starting addr (head)
add $t1, $zero, $t2     # $t1 = current (initialized to head)
addi $s7, $zero, 0      # $s7 = prev (initialized to 0 for 0th dot)
addi $s3, $zero, 400    # $s3 = NUMVECTORS number of vectors needed to be created 
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
sw $zero, 8($t1)    # fitness
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

j run   #jump to run when done


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
lw $t1, 11($t4) #$t1 = X coordinate of acceleration for that step
lw $t2, 12($t4) #$t2 = Y coordinate of acceleration for that step

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

# TODO: this logic could be wrong
addi $t0, $zero, 400 #MAXSTEP
# blt $t0, $t3, make_dead #if MAXSTEP < Numsteps, make dead
blt $t3, $t0, check_at_goal #if Numsteps < MAXSTEP, check at goal (else make dead)
# j check_at_goal

make_dead:
addi $t1, $zero, 1 #init 1 for set to true
sw $t1, 4($a0) #setting dead to true
j move_exit

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



calculateFitness: #determine the fitness of every dot
#  $a0 is the address of the dot in memory
addi $t0, $zero, 1 
lw $t1, 5($a0) #load reachedgoal 
bne $t0, $t1, is_dead #if reachedgoal != 1, go to is_read

#  Setting fitness to the number of steps taken if we found the goal
lw $t2, 7($a0) #loading numsteps
sw $t2, 8($a0)
j exit_calcFitness

is_dead:
lw $t3, 0($a0) #load x position of the dot
lw $t5, 1($a0) #load y position of the dot
addi, $t4, $zero, 320 #loading x position of goal
addi, $t6, $zero, 60 #loading y position of goal

sub $t7, $t4, $t3 #t7 = goalx - xpos
sub $t8, $t6, $t5 #t8 = goaly - ypos
nop
nop #for some reason, the mult doesn't work without a buffer-> must be a bypassing issue
nop
mul $t7, $t7, $t7 #t7 =  xdist^2
mul $t8, $t8, $t8 #t8 =  ydist^2
add $t9, $t7, $t8 #calculating squared distance: dx^2 + dy^2
# mul $28, $t7, $t7 #t7 =  xdist^2
# mul $29, $t8, $t8 #t8 =  ydist^2
# add $t9, $28, $29 #calculating squared distance: dx^2 + dy^2

addi $t2, $t9, 400 #dist+maxsteps
sw $t2, 8($a0) #store fitness

exit_calcFitness:
jr $ra


# SORT TODO:
    #add a prev word for each dot in the linkedlist
    #test the new implementation to make sure nothing broke horribly
    #implement sorting algorithm


# sort all of the dots based on fitness
sort:
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
add $t0, $t6, $zero         # head = current next

sinext:
add $t1, $t6, $zero         # $t1 = current.next

siguard:
lw $t6, 9($t1)              # $t6 = current.next
bne $t6, $zero, sortiter    # if current.next != 0, go to sortiter
add $a0, $t0, $zero         # $a0 = head
bne $t7, $zero, sortrecur   # if $t7 != 0, go to sortrecur
add $v0, $t0, $zero         # $v0 = head

sortrecur:
# addi $sp, $sp, -1
# lw $ra, 0($sp)
jr $ra



mutate: #must be passed $a0-> address of parent, $a1, address of child

addi $t0, $zero, 0 #counter for total vector location
addi $t1, $zero, 800 #NUMVECTORS*2

#RESETTING THE INIT VALUES FOR THE CHILD DOT
addi $t8, $zero, 320    # $t8 = start location X for dots
addi $t9, $zero, 420    # $t9 = start location Y for dots

# Initialize variables for current dot
sw $t8, 0($a1)      # x start position
sw $t9, 1($a1)      # y start position
sw $zero, 2($a1)    # x velocity
sw $zero, 3($a1)    # y velocity
sw $zero, 4($a1)    # dead status
sw $zero, 5($a1)    # reachedGoal status
sw $zero, 6($a1)    # champion status
sw $zero, 7($a1)    # numSteps
sw $zero, 8($a1)    # fitness

mutate_loop:

lw $t9, 99($zero)   # $t9 = getting a random value from the LFSR
addi $t8, $zero, -6 #mutation rate (blt random, mutationrate) (basically 1/15 odds for every)
blt $t9, $t8, rand_mutate

keep_same:
add $t2, $t0, $a0 #address of parent vector
lw $t3, 11($t2) #getting the nth x_vector 
add $t4, $t0, $a1 #address of child vector
sw $t3, 11($t4) #storing the nth x_vector for child
lw $t3, 12($t2) #getting the nth y_vector
sw $t3, 12($t4) #storing the nth y_vector for child
j copy_comp

rand_mutate:
add $t4, $t0, $a1 #address of child vector
lw $t9, 99($zero)   # $t9 = getting a random value from the LFSR
sw $t9, 11($t4) #storing the nth x_vector for child
lw $t9, 99($zero)   # $t9 = getting a random value from the LFSR
sw $t3, 12($t4) #storing the nth y_vector for child


copy_comp:
addi $t0, $t0, 2 #incrementing t0 by 2 (for x and y)
blt $t0, $t1, mutate_loop #counter < numvectors*2

jr $ra


run: #loop over this for all of time
# a0 is the head of the linkedlist
# addi $sp, $zero, 3 #testing
add $s0, $a0, $zero #head of linkedlist
addi $s2, $zero, 38 #while counter < NUMDOTS, we loop move

addi $s3, $zero, 0 #counter for which step we're on
addi $s4, $zero, 400 #MAXSTEP

# RUNNING A GENERATION (ALL DOTS MOVE UNTIL DEAD)
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
# before looping need to make sure $a0 is head of linkedlist

add $a0, $s0, $zero #making $a0 the head of the linkedlist
addi $s3, $s3, 1 #increment step counter
# addi $sp, $zero, 7 #testing
inc $zero, $zero, 0 #increment the generation counter

# TODO: modify this to get dots to move slower
addi $26, $zero, 0
addi $27, $zero, 47962 #12*1600 63950 ns per line of VGA -> 747400 instructions to == nanoseconds -> /4 because brand and 2 nops
# sll $27, $27, 2 #191850/4 ~= 47962
sll $27, $27, 3 #arbitrary to make it 2 times slower than it was with above instruction
waiter:
addi $26, $26, 1
blt $26, $27, waiter

blt $s3, $s4, play_generation

# CALCULATING THE FITNESS OF A DOT
# ## s2 holds the number of dots
add $s1, $zero, $zero #counter for which dot we're calculating = 0
# ## a0 should be head of linkedlist from exiting the move loop above
fitness_loop:
jal calculateFitness
addi $s1, $s1, 1 #increment looper
lw $a0, 9($a0) #loading dot.next for next loop over the dots
blt $s1, $s2, fitness_loop


# # SORTING ALL OF THE DOTS BASED ON THEIR FITNESS
add $a0, $s0, $zero #making $a0 the head of the linkedlist
jal sort
add $s0, $v0, $zero #making s0 head of sorted linkedlist
lw $t0, 10($a0) #previous
lw $26, 0($a0) #xloc
lw $27, 1($a0) #yloc
lw $a0, 9($a0) #next
lw $28, 0($a0) #xloc
lw $29, 1($a0) #yloc
lw $a0, 9($a0) #next
lw $30, 0($a0) #xloc
lw $31, 1($a0) #yloc



# #RESETTING THE INIT VALUES FOR THE Champion
# addi $t8, $zero, 320    # $t8 = start location X for dots
# addi $t9, $zero, 420    # $t9 = start location Y for dots
# addi $t7, $zero, 1
# # Initialize variables for current dot
# sw $t8, 0($s0)      # x start position
# sw $t9, 1($s0)      # y start position
# sw $zero, 2($s0)    # x velocity
# sw $zero, 3($s0)    # y velocity
# sw $zero, 4($s0)    # dead status
# sw $zero, 5($s0)    # reachedGoal status
# sw $t7, 6($s0)    # champion status -> champion = 1
# sw $zero, 7($s0)    # numSteps
# sw $zero, 8($s0)    # fitness

# # TODO: choose how to give each dot their offspring
# # TODO: MAKE 7 SEG DISPLAY RESET PROPERLY

# # CREATING NEW DOT OFFSPRING AND MUTATING THEM
# # TODO -> for now, just copying the best dot each time... not an 
# lw $s5, 9($s0) #getting next of linkedlist
# add $a0, $s0, $zero #making $a0 the head of the linkedlist
# add $a1, $s5, $zero #making $a1 the next value of the linkedlist (child)

# child_create:
# jal mutate
# lw $a1, 9($a1) #new child = child.next
# nop
# nop #nops just in case
# bne $zero, $a1, child_create #if next child isn't at 0, we need to create/mutate it

# inc $zero, $zero, 0 #increment the generation counter

# add $a0, $s0, $zero #setting a0 to head of linkedlist 
# j run

stop:
nop
nop
nop
j stop

