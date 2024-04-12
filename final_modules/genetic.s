
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









move: #make the dots change position











calculateFitness: #determine the fitness of every dot







sort: #sort all of the dots based on fitness






mutate: #mutate the dots based on RNG and stuff






naturalSelection: #sort, mutate, and make new generation (should be a pretty hefty method)










run: #loop over this for all of time



















