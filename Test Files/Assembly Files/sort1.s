nop             # Sort
nop             # Author: Jack Proudfoot
nop             
nop
init:
addi $sp, $zero, 256        # $29 = $sp = 256
addi $27, $zero, 3840       # $27 = 3840 address for bottom of heap
addi $t0, $zero, 50         # $8 = 50
addi $t1, $zero, 3          # $9 = 3
sw $t1, 0($t0)              #storing $9 (3) at location 50 in memory
addi $t1, $zero, 1          # $9 = 1
sw $t1, 1($t0)              #storing $9 (1) at location 51 in memory
addi $t1, $zero, 4          # $9 = 4
sw $t1, 2($t0)              #storing $9 (4) at location 52 in memory
addi $t1, $zero, 2          # $9 = 2
sw $t1, 3($t0)              #storing $9 (2) at location 53 in memory
add $a0, $zero, $t0         #setting $4 to 50

#additional to check that the stores worked properly
lw $t2, 0($t0)              #loading 3 into $10
lw $t3, 1($t0)              #loading 1 into $11
lw $t4, 2($t0)              #loading 4 into $12
lw $t5, 3($t0)              #loading 2 into $13
nop
nop
nop
nop     #nops to make sure the registers propogate properly for check
