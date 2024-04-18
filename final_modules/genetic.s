.data
NUMDOTS: .word 20
WIDTH: .word 640
HEIGHT: .word 480
MAXVEL: .word 7
MAXSTEP: .word 400
NUMVECTORS: .word 400
GOALX: .word 320 #x location on VGA of center of goal
GOALY: .word 60  #y location on VGA of center of goal
STARTX: .word 320 #x location on VGA of dots' start location
STARTY: .word 420 #y location on VGA of dots' start location
MUTATIONRATE: .word 4 #How likely a dot's vector is to mutate when being born (likely out of 128 by using lfsr rng)
STARTING_ADDR: .word 0x100 #Starting addr for  dots

#GLOBAL VARIABLES TO GO IN MEMORY
#MAXSTEP
#LOCATION OF LIST HEAD

main:
nop
nop
nop
nop
nop
jal init_dots
j run

.data
NUMDOTS: .word 20
START_ADDR: .word 0x1000  

init_dots:
    lw $s0, NUMDOTS       # Load NUMDOTS
    lw $t2, START_ADDR    # Load starting addr
    li $s1, 0             # Initialize counter

loop_dots:
    li $t3, 40            # each dot occupies 10 words; each word 4 bytes = 40 bytes
    mul $t1, $s1, $t3
    add $t1, $t1, $t2     # $t1 now holds the address of the current dot

    # Initialize variables
    sw $zero, 0($t1)      # x position
    sw $zero, 4($t1)      # y position
    sw $zero, 8($t1)      # x velocity
    sw $zero, 12($t1)     # y velocity
    sw $zero, 16($t1)     # dead status
    sw $zero, 20($t1)     # reachedGoal status
    sw $zero, 24($t1)     # champion status
    sw $zero, 28($t1)     # numSteps
    sw $zero, 32($t1)     # fitness

    # Set the next pointer, check if it's not the last dot
    addi $t4, $s1, 1      # next dot index
    mul $t4, $t4, $t3
    add $t4, $t4, $t2
    blt $s1, $s0, update_next  # Jump to update if not the last dot
    sw $zero, 36($t1)     # next pointer of last dot is zilch

    j increment_counter

update_next:
    sw $t4, 36($t1)       # next pointer

increment_counter:
    addi $s1, $s1, 1
    blt $s1, $s0, loop_dots  # Continue loop if not done w dots
    
    j main  # jump to main when done

#make the dots change position
move: #take in address of the dot being moved and its dot number (dot0, dot11, etc)

# If not dead or reachedGoal
lw $t1, $a0, 4 #load dead
lw $t2 $a0, 5 #load reachedGoal
bne $zero, $t1 move_exit #if dead or reachedGoal, exit
bne $zero, $t2 move_exit

# dot.Acceleration = brain[numSteps]
lw $t3, $a0, 7 #$t3 = numSteps
add $t4, $t3, $a0 #$t4 = numSteps+address (getting the acceleration vector address for that step)
lw $t1, $t4, 10 #$t1 = X coordinate of acceleration for that step
lw $t2, $t4, 11 #$t2 = Y coordinate of acceleration for that step

# Numsteps +=1
addi $t3, $t3, 1 #numsteps = numsteps + 1
sw $t3, $a0, 7 #storing incremented numsteps value

# Dot.velocity = dot.velocity + dot.Acceleration
lw $t5, $t4, 2 #$t5 = X coordinate of velocity
lw $t6, $t4, 3 #$t6 = Y coordinate of velocity

add $t5, $t5, $t1 #Xvel = xvel+xacc
add $t6, $t6, $t2 #Yvel = Yvel+Yacc

# If dot.velocity (in either direction) > maxVelocity:
# Set dot.velocity to maxVelocity

addi $t7, $zero, MAXVEL #$t7 = maxvel
sub $t0, $zero, $t7 #$t0 = -MAXVEL

blt $t7, $t5, fix_posx #if xvel > maxvel ($t7)
blt $t5, $t0, fix_negx #if xvel < -maxvel ($t0)
ok_xvel:
blt $t7, $t6, fix_posy #if yvel > maxvel ($t7)
blt $t6, $t0, fix_negy #if yvel < -maxvel ($t0)
j ok_vel

#standardizing velocity within a range
fix_posx:
addi $t5, $zero, MAXVEL #set X vel to MAXVEL
j ok_xvel
fix_negx:
addi $t5, $zero, -MAXVEL #set X vel to -MAXVEL
j ok_xvel

fix_posy:
addi $t6, $zero, MAXVEL #set Y vel to MAXVEL
j ok_vel
fix_negy:
addi $t6, $zero, -MAXVEL #set Y vel to MAXVEL

ok_vel:
# Dot.position = dot.position + dot.velocity
lw $t8, $a0, 0 #x position
lw $t9, $a0, 1 #y position
add $t8, $t8, $t5 #xpos = xpos+xvel
add $t9, $t9, $t6 #ypos = ypos+yvel
sw $t8, $a0, 0 #store x position
sw $t9, $a0, 1 #store y position

#load dot.position into the registers in VGAcontroller
#TODO: change this if we ever change the convention for where the memory mapped goes
sw $t8, $a1, 100 #storing Xpos to corresponding VGA register
sw $t9, $a1, 550 #storing Ypos to corresponding VGA register

# If dot.position outside of boundaries of arena or numSteps >= maxStep:
    # Dot.dead = true
sub $t0, $zero, $t7
addi $t0, $t0, WIDTH #t0 = Width-Maxvel
blt $t8, $t7, make_dead #if xpos(t8) < maxvel($t7) -> left side boundary of arena
blt $t0, $t8, make_dead #if xpos(t8) > Width-maxvel($t0) -> right side boundary of arena
sub $t0, $zero, $t7
addi $t0, $t0, HEIGHT #t0 = height-Maxvel
blt $t9, $t7, make_dead #if ypos(t9) < maxvel($t7) -> top boundary of arena
blt $t0, $t9, make_dead #if Ypos(t9) > Height-maxvel($t0) -> bottom boundary of arena

addi $t0, $zero, MAXSTEP
blt $t0, $t3, make_dead #if MAXSTEP < Numsteps, make dead
j check_at_goal

make_dead:
addi $t1, $zero, 1 #init 1 for set to true
sw $t1, $a0, 4 #setting dead to true
j move_exit

#TODO: wrap this up
# elif dot.position inside of goal:
    # dot.reachedGoal = true
check_at_goal:
addi $t0, $zero, 10
addi $t2, $zero, GOALX #t2 = goalX
add $t2, $t2, $t0 #$t2 = GoalX + 10 (right boundary)
blt $t2, $t8, not_reachedGoal #if Xpos > goal right boundary, not in goal
addi $t2, $zero, GOALY #t2 = goalY
add $t2, $t2, $t0 #$t2 = GoalY + 10 (bottom boundary)
blt $t2, $t9, not_reachedGoal #if Ypos > goal right boundary, not in goal

addi $t0, $zero, -10
addi $t2, $zero, GOALX #t2 = goalX
add $t2, $t2, $t0 #$t2 = GoalX - 10 (left boundary)
blt $t8, $t2, not_reachedGoal #if Xpos < goal left boundary, not in goal
addi $t2, $zero, GOALY #t2 = goalY
add $t2, $t2, $t0 #$t2 = GoalY - 10 (bottom boundary)
blt $t9, $t2, not_reachedGoal #if Ypos < goal top boundary, not in goal

make_reachedGoal:
addi $t1, $zero, 1 #init 1 for set to true
sw $t1, $a0, 5 #setting reachedgoal to true
j move_exit

not_reachedGoal:

move_exit:
jr $ra


calculateFitness: #determine the fitness of every dot
#$a0 is the address of the dot in memory
addi $t0, $zero, 1 
lw $t1, $a0, 5 #load reachedgoal 
bne $t0, $t1, is_dead #if reachedgoal != 1, to do is_read

#Setting fitness to the number of steps taken
lw $t2, $a0, 7 #loading numsteps
sw $t2, $a0, 8
j exit_calcFitness

is_dead:

lw $t3, $a0, 0 #load x position of the dot
lw $t5, $a0, 1 #load y position of the dot
addi, $t4, $zero, GOALX #loading x position of goal
addi, $t6, $zero, GOALY #loading y position of goal

sub $t7, $t4, $t3 #t7 = goalx - xpos
sub $t8, $t6, $t5 #t8 = goaly - ypos
mult $t7, $t7, $t7 #t7 =  xdist^2
mult $t8, $t8, $t8 #t8 =  ydist^2
add $t9, $t7, $t8 #calculating squared distance: dx^2 + dy^2

addi $t2, $t9, 400 #dist+maxsteps
sw $t2, $a0, 8

exit_calcFitness:
jr $ra


#TODO: sort
sort: #sort all of the dots based on fitness
# $a0 = head of list

sortrecur:
addi $t7, $zero, 0          # $t7 = 0
add $t0, $a0, $zero         # $t0 = head
add $t1, $t0, $zero         # $t1 = current
j siguard
sortiter:
lw $t2, 0($t1)              # $t2 = current.data
lw $t3, 0($t6)              # $t3 = current.next.data
blt $t2, $t3, sinext
addi $t7, $zero, 1          # $t7 = 1
lw $t4, 1($t1)              # $t4 = current.prev
bne $t4, $zero, supprev
j supprevd
supprev:
sw $t6, 2($t4)              # current.prev.next = current.next
supprevd:
sw $t4, 1($t6)              # current.next.prev = current.prev
lw $t5, 2($t6)              # $t5 = current.next.next
bne $t5, $zero, supnnprev
j supnnprevd
supnnprev:
sw $t1, 1($t5)              # current.next.next.prev = current
supnnprevd:
sw $t5, 2($t1)              # current.next = current.next.next
sw $t1, 2($t6)              # current.next.next = current
sw $t6, 1($t1)              # current.prev = current.next
bne $t0, $t1, sinext
add $t0, $t6, $zero         # head = current.next
sinext:
add $t1, $t6, $zero         # $t1 = current.next
siguard:
lw $t6, 2($t1)              # $t6 = current.next
bne $t6, $zero, sortiter
add $a0, $t0, $zero
bne $t7, $zero, sortrecur
add $v0, $t0, $zero         # $v0 = head
addi $sp, $sp, -1
lw $ra, 0($sp)
jr $ra




mutate: #mutate the dots based on RNG and stuff






naturalSelection: #sort, mutate, and make new generation (should be a pretty hefty method)










run: #loop over this for all of time

add $s0, $a0, $zero #head of linkedlist
addi $s2, $zero, NUMDOTS #while counter < numdots, we loop move

add $s3, $zero, $zero #counter for which step we're on
addi $s4, $zero, 400 #MAXSTEP

play_generation: #loop through this to play out the entire generation's movement

add $s1, $zero, $zero #counter for which dot we're moving = 0
move_step:
#a0 is already the address of the needed dot
add $a1, $s1, $zero #which dot is being moved
jal move
lw $a0, $a0, 9 #loading dot.next for next loop over the dots
addi $s1, $s1, 1 #increment dotID
blt $s1, $s2, move_step
#before looping need to make sure $a0 is head of linkedlist

add $a0, $s0, $zero #making $a0 the head of the linkedlist
addi $s3, $s3, 1 #increment step counter

blt $s3, $s4, play_generation
inc $zero, $zero, 0 #increment the generation counter

# j run -> TODO uncomment once we have multiple generations programmed, for now just one will do

# /*
# #calculating the fitness of a dot
# #s2 holds the number of dots
# add $s1, $zero, $zero #counter for which dot we're calculating = 0
# #a0 should be head of linkedlist from exiting the move loop above
# fitness_loop:
# jal calculateFitness
# addi $s1, $s1, 1 #increment looper
# lw $a0, $a0, 9 #loading dot.next for next loop over the dots
# blt $s1, $s2, fitness_loop
# */

stop:
nop
nop
nop
j stop
