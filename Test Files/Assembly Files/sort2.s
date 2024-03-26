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
##WE KNOW THE ABOVE WORKS PROPERLY 1) -> 17 insns
j main    #jumping to main 


#malloc method
malloc:                     # $a0 = number of words to allocate
sub $27, $27, $a0           # allocate $a0 words of memory
blt $sp, $27, mallocep      # check for heap overflow
mallocep:
add $v0, $27, $zero         #returns the current address for bottom of heap
jr $ra


buildlist:                  # $a0 = memory address of input data
sw $ra, 0($sp)              # store return address in memory
addi $sp, $sp, 1            # increment the stack -> $sp = 257
add $t0, $a0, $zero         # index of input data -> $t0 = 50
add $t1, $zero, $zero       # current list pointer -> $t1 = 0 (was 2)
addi $a0, $zero, 0          # a0 = 0
jal malloc                  # r27 = 3840 before this -> $v0 = 3840 after
addi $t3, $v0, -3           # list head pointer $t3 = 3837
lw $t2, 0($t0)              # load first data value -> $t2 = 3
##WE KNOW UP TO THIS POINT WORKS PROPERLY 2)
## DIDN'T CHECK IF THE SAVES WORKED, BUT THEY SHOULD'VE
j blguard

##
blstart:
addi $a0, $zero, 3          #param to make space for 3 items
jal malloc                  #making space for 3 items
sw $t2, 0($v0)              # set new[0] = data
sw $t1, 1($v0)              # set new[1] = prev
sw $zero, 2($v0)            # set new[2] = next
sw $v0, 2($t1)              # set curr.next = new
addi $t0, $t0, 1            # increment input data index
lw $t2, 0($t0)              # load next input data value
add $t1, $zero, $v0         # set curr = new
blguard:
bne $t2, $zero, blstart
add $v0, $t3, $zero         # set $v0 = list head
addi $sp, $sp, -1
lw $ra, 0($sp)
jr $ra


#MAKES UP MAIN PART OF SORT ALGORITHM: BUILD, SORT, FINISH (FREE SPACE I THINK)
main: 
#got here!
jal buildlist       #ra for main is 49 (will probably change when I add sort)
add $t0, $v0, $zero         # $t0 = head of list
add $a0, $t0, $zero         # $a0 = head of list
# jal sort
add $t0, $v0, $zero         # $t0 = head of sorted list
add $t5, $zero, $zero
add $t6, $zero, $zero
add $t1, $t0, $zero
# j procguard



