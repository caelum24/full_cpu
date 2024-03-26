nop
nop 				# Test Bypassing into Branch (with loops)
addi $r1, $r0, 5		# r1 = 5
b1: addi $r2, $r2, 1		# r2 += 1
blt $r2, $r1, b1		# if r2 < r1 take branch (5 times) //r2 = 5
b2: addi $r1, $r1, 1		# r1 += 1
addi $r3, $r3, 2		# r3 += 2
blt $r3, $r1, b2		# if r3 < r1 take branch (4 times)
add $r10, $r2, $r3		# r10 = r2 + r3
add $r11, $r10, $r11		# Accumulate r10 score
add $r21, $r20, $r21		# Accumulate r20 score
and $r10, $r0, $r10		# r10 should be 15
and $r20, $r0, $r20		# r20 should be 0
nop
nop 				