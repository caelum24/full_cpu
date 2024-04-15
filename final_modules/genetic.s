
.data
NUMDOTS: .word 20
WIDTH: .word 640
HEIGHT: .word 480
MAXVEL: .word 7
NUMVECTORS: .word 400
GOALX: .word 320 #x location on VGA of center of goal
GOALY: .word 60  #y location on VGA of center of goal
STARTX: .word 320 #x location on VGA of dots' start location
STARTY: .word 420 #y location on VGA of dots' start location
MUTATIONRATE: .word 4 #How likely a dot's vector is to mutate when being born (likely out of 128 by using lfsr rng)

#GLOBAL VARIABLES TO GO IN MEMORY
#MAXSTEP
#LOCATION OF LIST HEAD

main:
nop
nop
nop
nop
nop
init:
#create all of the dots
add $t0, $zero, $zero #init to zero

#initialize where all the dots start
addi $t1, $zero, STARTX
addi $t2, $zero, STARTY








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
#TODO: insert the memory mapped store instruction once the hardware has been updated 
# sw $t8, $a1, 10240 #storing Xpos to corresponding VGA register
# sw $t9, $a1, 12288 #storing Ypos to corresponding VGA register


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







sort: #sort all of the dots based on fitness






mutate: #mutate the dots based on RNG and stuff






naturalSelection: #sort, mutate, and make new generation (should be a pretty hefty method)










run: #loop over this for all of time



















stop:
j stop
