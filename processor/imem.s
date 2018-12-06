addi $26, $0, 0

LOOP:
bne $25, $0, REGISTER_NEW_SCORE
j LOOP

REGISTER_NEW_SCORE:
add $27, $0, $25
addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
addi $0, $0, 0
addi $26, $0, 1 		# ACK the game module
addi $19, $0, 0 		# i in reg 19

blt $20, $27, PUSH_FIVE
blt $21, $27, PUSH_FOUR
blt $22, $27, PUSH_THREE
blt $23, $27, PUSH_TWO
blt $24, $27, PUSH_ONE
addi $26, $0, 0
j LOOP

PUSH_FIVE:
addi $24, $23, 0
addi $23, $22, 0
addi $22, $21, 0
addi $21, $20, 0
addi $20, $27, 0
addi $26, $0, 0    # Should be ACKed by now
j LOOP

PUSH_FOUR:
addi $24, $23, 0
addi $23, $22, 0
addi $22, $21, 0
addi $21, $27, 0
addi $26, $0, 0 # Should be ACKed by now
j LOOP

PUSH_THREE:
addi $24, $23, 0
addi $23, $22, 0
addi $22, $27, 0
addi $26, $0, 0 # Should be ACKed by now
j LOOP

PUSH_TWO:
addi $24, $23, 0
addi $23, $22, 0
addi $26, $0, 0 # Should be ACKed by now
j LOOP

PUSH_ONE:
addi $24, $27, 0
addi $26, $0, 0 # Should be ACKed by now
j LOOP
