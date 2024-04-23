
# THIS TEST PROVED THAT THE DOTS ARE TRANSFERRING THEIR DATA TO THE REGISTERS EFFECTIVELY FOR VISUALIZATION
nop
nop
addi $a1, $zero, 0
addi $t8, $zero, 480
addi $t9, $zero, 400
sw $t8, 100($a1) #storing Xpos to corresponding VGA register
sw $t9, 550($a1) #storing Ypos to corresponding VGA register
addi $a1, $zero, 1
addi $t8, $zero, 200
addi $t9, $zero, 100
sw $t8, 100($a1) #storing Xpos to corresponding VGA register
sw $t9, 550($a1) #storing Ypos to corresponding VGA register
addi $a1, $zero, 2
addi $t8, $zero, 310
addi $t9, $zero, 50
sw $t8, 100($a1) #storing Xpos to corresponding VGA register
sw $t9, 550($a1) #storing Ypos to corresponding VGA register

stop:
nop
nop
j stop