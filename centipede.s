#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# -Point System (influenced by original centipede): 
#	centipede head - 100 points
#	centipede body - 10 points
#	mushroom - 4 points
#	flea - 200 points
#
#	note: Max score is 999999 (6 digits)
#	
# -Controls:
#	j - move left
#	k - move right
#	x - shoot
#	r - restart
#	c - exit
#
# -Color Scheme: 
#	centipede head - pink
#	centipede body - light green
#	mushroom - red (0 hits), orange(1 hit), brown(2 hits)
#	flea - yellow
# 	text/lives/blaster - purple
#	blast - light blue (cyan)
#
#####################################################################
.data
	displayAddress:	.word	0x10008000
	backgroundColor: .word  0x000000
	
  	textColor: .word  0xb300b3
  	
	blasterColor: .word 0x8b008b
	blastColor: .word 0x00ffff
	blasterAddress: .word 0x10011080
	blastAddress: .word 0x10011300
	
	mushroomAddress: .word 0x10010080
	mushroomColor: .word 0xff0000
	mushroomColor2: .word 0xffae1a
	mushroomColor3: .word 0x9a4d00
	numMushrooms: .word 52
	
	screenHeight: .word 64
	screenWidth: .word 64
	
	centipedeAddress: .word 0x10010880
	centipedeHeadAddress: .word 0x10010980
	centipedeColor: .word 0x00b300
	centipedeHeadColor: .word 0xff4fa7
	
	heartsColor: .word 0xffffff
	
	fleaAddress: .word 0x10011100
	fleaColor: .word 0xffff00
	
#####################################################################
# s0 is score
# s1 is the number of mushrooms
# s2 is the number of centipede segments
# s3 is the number of lives
# s4 is counter necessary for creating centipedes
# s5 is the number of centipede heads
# s6 is the number of fleas
# s7 is the number of blasts
#####################################################################

.globl main
.text
main:
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 5
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $s7, 0
	
############################################################################################
# draw background
# t2 color

draw_bg:
	lw $t0, displayAddress
	addi $t1, $t0, 16384
	lw $t2, backgroundColor

draw_bg_loop:
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	blt $t0, $t1, draw_bg_loop
	
############################################################################################
# draw mushrooms
# t1 numMushrooms / counter
# t2 mushroomAddress
# a0 color

mushroom_main:
	lw $t1, numMushrooms
	lw $t2, mushroomAddress
	li $t4, 10

mushroom_init_loop:
	jal get_random_x
	sll $a0, $a0, 1
	addi $a0, $a0, 2
	addi $t5, $a0, 0
	
unique_mushroom_x:
	jal get_random_x
	sll $a0, $a0, 1
	addi $a0, $a0, 2
	sub $t7, $a0, $t5
	ble $t7, $zero, check_negative
	
check_positive:
	li $t0, 2
	ble $t7, $t0, unique_mushroom_x
	j continue_mushroom

check_negative:
	li $t0, -2
	bge $t7, $t0, unique_mushroom_x
	j continue_mushroom
	
continue_mushroom:
	
	addi $t6, $a0, 0
	
	sh $t4, 0($t2)		# Offset is 8 (for text) + 4 (for centipede)
	sh $t5, 2($t2)		
	addi $s1, $s1, 1
	
	sh $t4, 4($t2)
	sh $t6, 6($t2)
	addi $s1, $s1, 1
	
	addi $t4, $t4, 2
	addi $t2, $t2, 8
	blt $s1, $t1, mushroom_init_loop
	
draw_mushroom_main:
	li $t1, 0
	lw $t2, mushroomAddress
	lw $a0, mushroomColor
	
draw_mushroom_loop:
	lh $a1, 0($t2)				# Platform Y
	sll $a1, $a1, 6				# Platform Y * 64
	lh $t3, 2($t2)				# Platform X
	add $a1, $a1, $t3			# Platform Y * 64 + Platform X
	sll $a1, $a1, 2				# (Platform Y * 64 + Platform X) * 4
	add $a1, $a1, $gp			# $gp + (p.y * 64 + p.x)*4   
	
	jal draw_square
	
	addi $t1, $t1, 1
	addi $t2, $t2, 4
	blt $t1, $s1, draw_mushroom_loop
	
############################################################################################
# draw text
# t0 color
draw_text:
	lw $a0, textColor
	
	jal draw_score_text
	
	jal draw_score_num
	
	
	addi $t0, $zero, 7
	sll $t0, $t0, 6
	li $t1, 0
	add $t0, $t0, $t1
	sll $t0, $t0, 2	
	add $t0, $t0, $gp
	
	li $t1, 0
	li $t2, 64
	
line_loop:
	sw $a0, 0($t0)
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	blt $t1, $t2, line_loop
	


############################################################################################
# draw lives
# a0 color
draw_lives:
	lw $a0, textColor
	li $t0, 116
	sll, $t1, $t0, 2
	add $t1, $gp, $t1
	
draw_heart:
	sw $a0, 4($t1)		# first layer
	sw $a0, 8($t1)
	sw $a0, 16($t1)
	sw $a0, 20($t1)

	sw $a0, 256($t1)	# second layer
	sw $a0, 260($t1)
	sw $a0, 264($t1)
	sw $a0, 268($t1)
	sw $a0, 272($t1)
	sw $a0, 276($t1)
	sw $a0, 280($t1)
		
	sw $a0, 516($t1)	# third layer
	sw $a0, 520($t1)
	sw $a0, 524($t1)
	sw $a0, 528($t1)
	sw $a0, 532($t1)
	
	sw $a0, 776($t1)	# fourth layer
	sw $a0, 780($t1)
	sw $a0, 784($t1)
	
	sw $a0, 1036($t1)	# fifth layer
	
	jal draw_lives_num


############################################################################################
new_game:
	jal start_blaster
	jal draw_score_num
	li $s4, 0
	li $t9, 100
	li $t7, 0
	
game_loop_main:
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	j update_assets
	
keyboard_input:
	lw $t8, 0xffff0004
	beq $t8, 0x6A, keyboard_left	# `j` -> move left
	beq $t8, 0x6B, keyboard_right	# `k` -> move right
	beq $t8, 0x78, keyboard_shoot	# `x` -> shoot
    	beq $t8, 0x72, keyboard_restart # `r` -> restart the game
   	beq $t8, 0x63, Exit 		# `c` -> terminate the program


update_assets:
	bgt $t9, $zero, continue_update
	li $t9, 101
	jal update_blast
	jal update_centipede_head
	jal update_centipede
	jal update_flea
	
	li $t0, 10
	bge $s4, $t0, randomize_flea
	jal start_centipede

randomize_flea:
	jal create_flea
	li $t7, 0
	
continue_update:	
	subi $t9, $t9, 1
	li $v0, 32
	li $a0, 1
	syscall
	
	j game_loop_main

keyboard_right:
	jal erase_blaster
	lw $t0, blasterAddress
	
	lh $t1, 0($t0)
	li $a0, 62
	addi $a1, $t1, 2
	
	jal check_square_safe
	
	li $t2, 1
	beq $a2, $t2, blaster_hit
	
	li $t2, 63
	addi $t1, $t1, 2
	blt $t1, $t2, blaster_right_safe
	li $t1, 62
	
blaster_right_safe:
	lw $t0, blasterAddress
	sh $t1, 0($t0)
	
	jal draw_blaster
	
	j update_assets
	
	
keyboard_left:
	jal erase_blaster
	lw $t0, blasterAddress
	
	lh $t1, 0($t0)
	li $a0, 62
	addi $a1, $t1, -3
	
	jal check_square_safe
	
	li $t2, 1
	beq $a2, $t2, blaster_hit
	
	li $t2, 1
	addi $t1, $t1, -2
	bgt $t1, $t2, blaster_left_safe
	li $t1, 2
	
blaster_left_safe:
	lw $t0, blasterAddress
	sh $t1, 0($t0)
	
	jal draw_blaster
	
	j update_assets

keyboard_shoot:	
	bne $t7, $zero, update_assets
	li $t7, 1
	
	lw $t0, blastAddress
	sll $t1, $s7, 2
	add $t0, $t0, $t1
	
	lw $t1, blasterAddress
	li $t2, 62
	lh $t3, 0($t1)
	
	sh $t2, 0($t0)
	sh $t3, 2($t0)
	addi $s7, $s7, 1
	
	j update_assets
	
	
keyboard_restart:
	j main

############################################################################################
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
	
############################################################################################
blaster_hit:
	bgt $s3, $zero, reset_round
	jal draw_game_over
	
loop_input:
	li $v0, 32
	li $a0, 10
	syscall
	lw $t8, 0xffff0000
	beq $t8, 1, reset_or_exit
	j loop_input
	
reset_or_exit:
	lw $t8, 0xffff0004
    	beq $t8, 0x72, keyboard_restart # `r` -> restart the game
   	beq $t8, 0x63, Exit 		# `c` -> terminate the program
   	j loop_input
   	
reset_round:
	subi $s3, $s3, 1
	jal draw_lives_num
	jal draw_score_num
	jal erase_blaster
	
	lw $t1, blastAddress
	li $t7, 0
	beq $s7, $t7, skip_blast_erase
erase_blast_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	addi $t2, $a0, 0	# copy values
	addi $t3, $a1, 0
	
	li $t5, 62
	beq $t2, $t5, erase_blast_loop
	
	addi $a0, $t7, 0
	
	addi $a0, $t7, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	jal erase_blast	
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $t7, $t7, 1
	blt $t7, $s7, erase_blast_loop
	
skip_blast_erase:
	addi $s7, $zero, 0 
	
	lw $t1, fleaAddress
	li $t7, 0
	beq $s6, $t7, skip_flea_erase
flea_erase_loop:
	
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	lw $t5, fleaColor
	lw $t4, 0($a1)
	bne $t4, $t5, no_erase_flea
	
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal erase_square
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	

no_erase_flea:
	addi $t7, $t7, 1
	addi $t1, $t1, 4
	
	blt $t7, $s6, flea_erase_loop
	
skip_flea_erase:
	addi $s6, $zero, 0
	
	
	
	li $t7, 0
	lw $t1, centipedeAddress
	beq $s2, $t7, skip_centipede_erase
	
centipede_erase_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal erase_square
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $t1, $t1, 4
	addi $t7, $t7, 1
	blt $t7, $s2, centipede_erase_loop
	
skip_centipede_erase:
	addi $s2, $zero, 0
	
	
	li $t7, 0
	lw $t1, centipedeHeadAddress
	beq $s5, $t7, skip_head_erase
head_erase_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal erase_square
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $t1, $t1, 4
	addi $t7, $t7, 1
	blt $t7, $s5, head_erase_loop
	
skip_head_erase:
	addi $s5, $zero, 0
	
	j new_game
	
############################################################################################
# a0 is index of blast
# a1 is index of flea
blast_flea:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	addi $t8, $a1, 0
	
	jal erase_blast
	jal delete_blast
	
	lw $t0, fleaAddress
	sll $t1, $t8, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	
	jal erase_square_unsafe
	
	addi $a0, $t8, 0
	jal delete_flea
	
	addi $s0, $s0, 200
	
	
	jal draw_score_num
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	
	jr $ra

############################################################################################
# a0 is index of blast
# a1 is index of mushroom
blast_mushroom:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	addi $t8, $a1, 0
	
	jal erase_blast
	jal delete_blast
	
	lw $t0, mushroomAddress
	sll $t1, $t8, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	lw $t1, 0($a1)
	lw $t3, mushroomColor
	lw $t4, mushroomColor2
	lw $t5, mushroomColor3
	
	beq $t1, $t3, stage1_mushroom
	beq $t1, $t4, stage2_mushroom
	
stage3_mushroom:
	jal erase_square_unsafe
	addi $a0, $t8, 0
	jal delete_mushroom
	addi $s0, $s0, 4

	
	jal draw_score_num
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

stage1_mushroom:
	addi $a0, $t4, 0 
	jal draw_square
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

stage2_mushroom:
	addi $a0, $t5, 0 
	jal draw_square
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################
# a0 is index of blast
# a1 is index of head
blast_head:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	addi $t8, $a1, 0

	jal erase_blast
	jal delete_blast
	
	lw $t0, centipedeHeadAddress
	sll $t1, $t8, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	lw $a0, mushroomAddress
	
	sll $t3, $s1, 2
	add $a0, $a0, $t3
	sh $t1, 0($a0)
	sh $t2, 2($a0)
	addi $s1, $s1, 1
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	
	lw $a0, mushroomColor
	jal draw_square
	
	addi $a0, $t8, 0

	jal head_make_next_head
	
	addi $a0, $t8, 0
	jal delete_head
	
	addi $s0, $s0, 100
	
	jal draw_score_num
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra
	

############################################################################################
# a0 is index of blast
# a1 is index of centipede
blast_centipede:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	addi $t8, $a1, 0

	jal erase_blast
	jal delete_blast
	
	lw $t0, centipedeAddress
	sll $t1, $t8, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
		
	lw $a0, mushroomAddress
	
	sll $t3, $s1, 2
	add $a0, $a0, $t3
	sh $t1, 0($a0)
	sh $t2, 2($a0)
	addi $s1, $s1, 1
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	
	lw $a0, mushroomColor
	jal draw_square

	addi $a0, $t8, 0

	jal centipede_make_next_head
	
	addi $a0, $t8, 0
	jal delete_centipede
	addi $s0, $s0, 10
	
	jal draw_score_num
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################	
# a2 is index of body to turn to head
# create a new centipede head
create_new_head:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	lw $t0, centipedeAddress
	sll $t1, $a2, 2
	add $a0, $t0, $t1
	
	lh $t2, 0($a0)
	lh $t3, 2($a0)
	
	addi $a0, $a2, 0
	
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	jal delete_centipede
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	
	lw $t0, centipedeHeadAddress
	sll $t1, $s5, 2
	add $t0, $t0, $t1
	
	sh $t2, 0($t0)
	sh $t3, 2($t0)
	
	addi $s5, $s5, 1
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	
	jr $ra

############################################################################################
# a0 is index of current body shot
centipede_make_next_head:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	subi $a1, $s2, 1
	beq $a0, $a1, made_head

	lw $t0, centipedeAddress
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	addi $t5, $t1, 0
	
	addi $t0, $t0, 4
	
	lh $t3, 0($t0)
	lh $t4, 2($t0)
	
	sub $t1, $t1, $t3
	sub $t2, $t2, $t4
	
	li $a1, 4
	div $t5, $a1
	mfhi $a1
	
	beq $a1, $zero, check_right
	
check_left:
	li $t7, 2
	bne $t1, $zero, check_up
	bne $t2, $t7, check_up
	addi $a2, $a0, 1
	j make_head
	
check_right:
	li $t7, -2
	bne $t1, $zero, check_up
	bne $t2, $t7, check_up
	addi $a2, $a0, 1
	j make_head

check_up:
	bne $t2, $zero, check_special
	li $t5, 2
	bne $t1, $t5, check_special
	addi $a2, $a0, 1
	j make_head
	
check_special:
	bne $t2, $t7, made_head
	li $t7, 2
	bne $t1, $t7, made_head
	addi $a2, $a0, 1
	j make_head
	
make_head:
	jal create_new_head
	
made_head:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra
############################################################################################
# a0 is index of current head shot
head_make_next_head:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	addi $t8, $a0, 0

	lw $t0, centipedeHeadAddress
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	li $t3, 4
	div $t1, $t3
	mfhi $a1
	beq $a1, $zero, check_moving_left
	
check_moving_right:
	addi $a0, $t1, 0
	addi $a1, $t2, -2
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	bne $a2, $s2, next_head_found
	
	addi $a0, $t1, -2
	addi $a1, $t2, -2
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	beq $a2, $s2, check_moving_down
	j make_head
	
check_moving_left:
	addi $a0, $t1, 0
	addi $a1, $t2, 2
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	bne $a2, $s2, next_head_found
	
	addi $a0, $t1, -2
	addi $a1, $t2, 2
	
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	
	beq $a2, $s2, check_moving_down
	j make_head
	
check_moving_down:
	addi $a0, $t1, -2
	addi $a1, $t2, 0
	
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	beq $a2, $s2, made_head
	j make_head
	
next_head_found:
	j make_head

## Make head and made head are under centipede_make_next_head

	
############################################################################################
# a0 is index of blast
blast_boundary:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	jal erase_blast
	jal delete_blast
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################
# overites t0-t5, a0-a1, t7	
update_blast:
	li $t7, 0
	lw $t1, blastAddress
	beq $s7, $t7, no_blast
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
blast_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	addi $t2, $a0, 0	# copy values
	addi $t3, $a1, 0
	
	addi $a0, $t7, 0
	
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal erase_blast
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	
	
move_blast_up:
	addi $a0, $t2, -1	
	addi $a1, $t3, 0
	
	li $t6, 9
	beq $a0, $t6, check_blast_special_case
	
continue_normal_case:
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a0, $a0, $gp
	
	lw $a1, 0($a0)
	
	lw $a0, mushroomColor
	beq $a0, $a1, mushroom_case
	lw $a0, mushroomColor2
	beq $a0, $a1, mushroom_case
	lw $a0, mushroomColor3
	beq $a0, $a1, mushroom_case
	
	lw $a0, textColor
	beq $a0, $a1, boundary_case
	
	lw $a0, centipedeHeadColor
	beq $a0, $a1, head_case
	
	lw $a0, centipedeColor
	beq $a0, $a1, centipede_case
	
	lw $a0, fleaColor
	beq $a0, $a1, flea_case
	
safe_blast:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	sh $a0, 0($t1)
	sh $a1, 2($t1)
	
	addi $a0, $t7, 0
	
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal draw_blast
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	
	addi $t7, $t7, 1
	addi $t1, $t1, 4
	
no_increment_blast:
	blt $t7, $s7, blast_loop
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)

no_blast:
	jr $ra
	
check_blast_special_case:
	li $t6, 40
	bne $a1, $t6, continue_normal_case
	addi $a0, $t7, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_boundary
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast
	
mushroom_case:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_mushroom
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $t7, 0
	addi $a1, $a2, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_mushroom
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast
	
boundary_case:
	addi $a0, $t7, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_boundary
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast
	
head_case:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_head
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $t7, 0
	addi $a1, $a2, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_head
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast
	
centipede_case:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $t7, 0
	addi $a1, $a2, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast

flea_case:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_flea
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $t7, 0
	addi $a1, $a2, 0
	
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_flea
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_blast
	
############################################################################################
# a0 is index of blast to be drawn
# overwrites t0-t2, a0
draw_blast:
	lw $t0, blastAddress
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $t1, $t1, $gp
	
	lw $t2, blastColor
	sw $t2, 0($t1)
	
	jr $ra

	
############################################################################################
# a0 is index of blast to be erased
# overwrites t0, t1, t6, a0
erase_blast:
	lw $t0, blastAddress
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t6, 2($t0)
	
	li $t5, 62
	beq $t1, $t5, done_erase_blast
	
	sll $t1, $t1, 6
	add $t1, $t1, $t6
	sll $t1, $t1, 2
	add $t1, $t1, $gp
	
	li $t6, 1
	sw $t6, 0($t1)

done_erase_blast:	
	jr $ra


############################################################################################
# overwrites t0
delete_blaster:
	lw $t0, blastAddress
	sh $zero, 0($t0)
	
	jr $ra
	
	
############################################################################################
# a0 is index of mushroom to be deleted
# overwrites t0-t3, a0
delete_mushroom:
	lw $t0, mushroomAddress
	addi, $t2, $a0, 0
	sll $a0, $a0, 2
	add $t0, $t0, $a0
	
	sw $zero, 0($t0)
	addi $s1, $s1, -1
	
	beq $t2, $s1, delete_mushroom_end
	
delete_mushroom_loop:
	addi $t1, $t0, 4
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	
	blt $t2, $s1, delete_mushroom_loop
	
delete_mushroom_end:
	jr $ra
	
############################################################################################
# a0 is index of blast to be deleted
# overwrites t0-t3, a0
delete_blast:
	lw $t0, blastAddress
	addi, $t2, $a0, 0
	sll $a0, $a0, 2
	add $t0, $t0, $a0
	
	sw $zero, 0($t0)
	addi $s7, $s7, -1
	
	beq $t2, $s7, delete_blast_end
	
delete_blast_loop:
	addi $t1, $t0, 4
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	
	blt $t2, $s7, delete_blast_loop
	
delete_blast_end:
	jr $ra

############################################################################################
# a0 is index of body to be deleted
# overwrites t0-t3, a0
delete_centipede:
	lw $t0, centipedeAddress
	addi $t2, $a0, 0
	sll $a0, $a0, 2
	add $t0, $t0, $a0
	
	sw $zero, 0($t0)
	addi $s2, $s2, -1
	
	beq $t2, $s2, delete_centipede_end
	
delete_centipede_loop:
	addi $t1, $t0, 4
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	
	blt $t2, $s2, delete_centipede_loop
	
delete_centipede_end:
	jr $ra

############################################################################################
# a0 is index of head to be deleted
# overwrites t0-t3, a0
delete_head:
	lw $t0, centipedeHeadAddress
	addi, $t2, $a0, 0
	sll $a0, $a0, 2
	add $t0, $t0, $a0
	
	sw $zero, 0($t0)
	addi $s5, $s5, -1
	
	beq $t2, $s5, delete_head_end
	
delete_head_loop:
	addi $t1, $t0, 4
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	
	blt $t2, $s5, delete_head_loop
	
delete_head_end:
	jr $ra
	

############################################################################################
# a0 is index of flea to be deleted
# overwrites t0-t3, a0
delete_flea:
	lw $t0, fleaAddress
	addi, $t2, $a0, 0
	sll $a0, $a0, 2
	add $t0, $t0, $a0
	
	sw $zero, 0($t0)
	addi $s6, $s6, -1
	
	beq $t2, $s6, delete_flea_end
	
delete_flea_loop:
	addi $t1, $t0, 4
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	
	addi $t2, $t2, 1
	addi $t0, $t0, 4
	
	blt $t2, $s6, delete_flea_loop
	
delete_flea_end:
	jr $ra
	
############################################################################################
# overwrites t0-t3, a0-a2
create_flea:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	jal get_random_chance
	
	li $t0, 1
	bne $a0, $t0, end_flea

	jal get_random_x
	sll $t3, $a0, 1
	sll $a0, $a0, 1
	li $a1, 8
	
	jal check_square_safe
	
	li $t0, 2
	beq $a2, $t0, continue_flea_create
	bne $a2, $zero, end_flea
	
continue_flea_create:
	li $t2, 6
	lw $t0, fleaAddress
	sll $t1, $s6, 2
	add $t0, $t0, $t1
	
	sh $t2, 0($t0)
	sh $t3, 2($t0)

	addi $s6, $s6, 1

end_flea:
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra
	
############################################################################################
# overites t0-t5, a0-a1, t7	
update_flea:
	li $t7, 0
	lw $t1, fleaAddress
	beq $s6, $t7, no_flea
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
flea_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	addi $t2, $a0, 0	# copy values
	addi $t3, $a1, 0
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	lw $t5, fleaColor
	lw $t4, 0($a1)
	bne $t4, $t5, move_down
	
	lw $t4, 256($a1)
	bne $t4, $t5, move_down
	
	lw $t4, 260($a1)
	bne $t4, $t5, move_down
	
	jal erase_square_unsafe
	
move_down:
	li $t5, 62
	beq $t2, $t5, hit_bottom
	
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	jal check_square_safe
	
	li $t5, 2
	beq $a2, $t5, flea_safe
	bne $a2, $zero, flea_collision
	
flea_safe:		
	addi $t2, $t2, 2
	j continue_flea_loop
	
	
flea_collision:
	li $t5, 3
	beq $a2, $t5, flea_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_flea

	li $t5, 62
	beq $t2, $t5, hit_bottom

	j hit_object

	
hit_bottom:
	addi $a0, $t7, 0
	
	sw $t0, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	
	jal delete_flea
	
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t0, 0($sp)
	
	j no_increment_flea
	
hit_object:
	addi $t2, $t2, 2
	sh $t2, 0($t1)		
	sh $t3, 2($t1)
	j increment_flea
	
continue_flea_loop:
	sh $t2, 0($t1)		# Y offset
	sh $t3, 2($t1)		# X offset
	
	addi $a0, $t7, 0
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal draw_flea
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
increment_flea:
	addi $t7, $t7, 1
	addi $t1, $t1, 4

no_increment_flea:
	blt $t7, $s6, flea_loop
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

no_flea:
	jr $ra
	
blast_hit_flea:
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_blast
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $a2, 0
	
	addi $a1, $t7, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_flea
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_flea

flea_hit_blaster:
	jal blaster_hit
	
	
############################################################################################
# a0 is the index of the flea in flea address
# overites t0-t2, a0, a1
draw_flea:
	lw $t0, fleaAddress
	
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)		#Y offset
	lh $t2, 2($t0)		#X offset
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp

	lw $a0, fleaColor
	
	sw $a0, 0($a1)
	addi $a1, $a1, 256
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	
	jr $ra
	

############################################################################################	
#a0 is index of current body
# a2 is 0 -> if its not last body, 1-> if last body
check_last_centipede:
	sw $ra, 0($sp)
	addi $sp, $sp, -4

	subi $a1, $s2, 1
	beq $a0, $a1, last_centipede

	lw $t0, centipedeAddress
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	addi $t5, $t1, 0
	
	addi $t0, $t0, 4
	
	lh $t3, 0($t0)
	lh $t4, 2($t0)
	
	sub $t0, $t0, 4
	sub $t1, $t1, $t3
	sub $t2, $t2, $t4
	
	li $a1, 4
	div $t5, $a1
	mfhi $a1
	
	beq $a1, $zero, centipede_right
	
centipede_left:
	li $t7, 2
	bne $t1, $zero, centipede_up
	bne $t2, $t7, centipede_up
	j not_last_centipede
	
centipede_right:
	li $t7, -2
	bne $t1, $zero, centipede_up
	bne $t2, $t7, centipede_up
	j not_last_centipede

centipede_up:
	bne $t2, $zero, centipede_special
	li $t5, 2
	bne $t1, $t5, centipede_special
	j not_last_centipede
	
centipede_special:
	bne $t2, $t5, centipede_corner
	li $t7, 2
	bne $t1, $t7, centipede_corner
	j not_last_centipede
	
centipede_corner:
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	li $t7, 60
	beq $t1, $t7, not_last_centipede
	li $t7, 62
	beq $t1, $t7, not_last_centipede
	
	j last_centipede
	
last_centipede:
	li $a2, 1
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	jr $ra
	
not_last_centipede:
	li $a2, 0
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	jr $ra
			
############################################################################################
# overites t0-t5, a0-a1, t7
update_centipede:
	li $t7, 0
	lw $t1, centipedeAddress
	beq $s2, $t7, no_centipede
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
movement_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	addi $t2, $a0, 0	# copy values
	addi $t3, $a1, 0
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	lw $t5, centipedeColor
	lw $t4, 0($a1)
	bne $t4, $t5, continue_loop
	
	addi $a0, $t7, 0
	
	sw $t2, 0($sp)
	addi $sp, $sp, -4
	
	sw $t3, 0($sp)
	addi $sp, $sp, -4
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal check_last_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	
	addi $sp, $sp, 4
	lw $t2, 0($sp)
	
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	bne $a2, $zero, unsafe_erase_centipede
	
safe_erase_centipede:
	jal erase_square
	j continue_loop
	
unsafe_erase_centipede:
	jal erase_square_unsafe
	
continue_loop:
	li $a0, 4
	div $t2, $a0
	mfhi $a0
	
	beq $a0, $zero, move_left
	
move_right:
	addi $a3, $zero, -2
	li $t5, 62
	beq $t3, $t5, collision
	
	addi $a0, $t2, 0	# copy values
	addi $a1, $t3, 2
	
	jal check_square_safe
	
	bne $a2, $zero, collision
			
	addi $t3, $t3, 2
	j continue_movement_loop
	
	
move_left:
	addi $a3, $zero, 2
	beq $t3, $zero, collision
	
	addi $a0, $t2, 0	
	addi $a1, $t3, -2
	
	jal check_square_safe
	
	addi $a0, $t2, 0	
	addi $a1, $t3, -2
	
	bne $a2, $zero, collision
	
	addi $t3, $t3, -2
	j continue_movement_loop
	
collision:
	li $t5, 3
	beq $a2, $t5, centipede_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_centipede

	li $t5, 62
	beq $t2, $t5, collision_bottom
	
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	jal check_square_safe
	
	addi $a0, $t2, 2	
	addi $a1, $t3, 0
	
	addi $t5, $zero, 0
	beq $a2, $t5, centipede_safe
	
	li $t5, 3
	beq $a2, $t5, centipede_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_centipede
	
	add $t3, $t3, $a3
	
centipede_safe:
	addi $t2, $t2, 2
	j continue_movement_loop
	
collision_bottom:
	addi $a0, $t2, -2
	addi $a1, $t3, 0
	
	jal check_square_safe
	
	beq $a2, $zero, centipede_safe_2
	
	add $t3, $t3, $a3
	
centipede_safe_2:
	addi $t2, $t2, -2
	j continue_movement_loop
	
continue_movement_loop:
	li $t5, 62
	bgt $t2, $t5, unsafe_centipede_y
	bgt $t3, $t5, unsafe_centipede_x
	j save_centipede_move

unsafe_centipede_y:
	li $t2, 62
	bgt $t3, $t5, unsafe_centipede_x
	j save_centipede_move
	
unsafe_centipede_x:
	li $t3, 62
	
save_centipede_move:
	sh $t2, 0($t1)		# Y offset
	sh $t3, 2($t1)		# X offset
	
	addi $a0, $t7, 0
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal draw_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
increment_centipede_loop:
	addi $t7, $t7, 1
	addi $t1, $t1, 4

no_increment_centipede:	
	blt $t7, $s2, movement_loop
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

no_centipede:
	jr $ra
	
blast_hit_centipede:

	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_blast
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)

	addi $a0, $a2, 0

	addi $a1, $t7, 0
	
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_centipede
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_centipede

centipede_hit_blaster:
	jal blaster_hit

############################################################################################
# overites t0-t5, a0-a1, t7
update_centipede_head:
	li $t7, 0
	lw $t1, centipedeHeadAddress
	beq $s5, $t7, no_centipede_head
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
head_movement_loop:
	lh $a0, 0($t1)		# Y offset
	lh $a1, 2($t1)		# X offset
	
	addi $t2, $a0, 0	# copy values
	addi $t3, $a1, 0
	
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $a1, $a0, $gp
	
	jal erase_square
	
	li $a0, 4
	div $t2, $a0
	mfhi $a0
	
	beq $a0, $zero, head_left
	
head_right:
	li $t5, 62
	beq $t3, $t5, collision_right
	
	li $t5, 2
	addi $a0, $t2, 0
	addi $a1, $t3, 2
	
	jal check_square_safe
	
	addi $a0, $t2, 0
	addi $a1, $t3, 2
	
	beq $a2, $t5, safe_for_head_right
	bne $a2, $zero, collision_right
	
safe_for_head_right:
	addi $t3, $t3, 2	
	j continue_head_loop
	
	
head_left:
	beq $t3, $zero, collision_left
	
	li $t5, 2
	addi $a0, $t2, 0	
	addi $a1, $t3, -2
	
	jal check_square_safe
	
	addi $a0, $t2, 0	
	addi $a1, $t3, -2
	
	beq $a2, $t5, safe_for_head_left
	bne $a2, $zero, collision_left
	
safe_for_head_left:
	addi $t3, $t3, -2
	j continue_head_loop
	
collision_right:
	li $t5, 3
	beq $a2, $t5, head_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_head
	
	li $t5, 62
	beq $t2, $t5, collision_bottom_head
	
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	jal check_square_safe
	
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	addi $t5, $zero, 0
	beq $a2, $t5, collision_right_safe
	
	li $t5, 2
	beq $a2, $t5, collision_right_safe
	
	li $t5, 3
	beq $a2, $t5, head_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_head
	
	addi $t3, $t3, -2
	
collision_right_safe:
	addi $t2, $t2, 2
	j continue_head_loop
	
collision_left:
	li $t5, 3
	beq $a2, $t5, head_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_head
	
	addi $a0, $t2, 2
	addi $a1, $t3, 0
	
	jal check_square_safe
	
	addi $a0, $t2, 2	
	addi $a1, $t3, 0
	
	beq $a2, $zero, collision_left_safe
	
	li $t5, 2
	beq $a2, $t5, collision_left_safe
	
	li $t5, 3
	beq $a2, $t5, head_hit_blaster
	
	li $t5, 4
	beq $a2, $t5, blast_hit_head
	
	addi $t3, $t3, 2
	
collision_left_safe:
	addi $t2, $t2, 2
	j continue_head_loop
	
collision_bottom_head:
	addi $t2, $t2, -2
	j continue_head_loop	
	
continue_head_loop:
	li $t5, 62
	bgt $t2, $t5, unsafe_head_y
	bgt $t3, $t5, unsafe_head_x
	j save_head_move

unsafe_head_y:
	li $t2, 62
	bgt $t3, $t5, unsafe_head_x
	j save_head_move
	
unsafe_head_x:
	li $t3, 62
	
save_head_move:
	sh $t2, 0($t1)		# Y offset
	sh $t3, 2($t1)		# X offset
	
	addi $a0, $t7, 0
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal draw_centipede_head
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $t7, $t7, 1
	addi $t1, $t1, 4

no_increment_head:	
	blt $t7, $s5, head_movement_loop
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

no_centipede_head:
	addi $s4, $zero, 0
	jr $ra
	
blast_hit_head:
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal find_blast
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	addi $a0, $a2, 0
	
	addi $a1, $t7, 0
	
	sw $t7, 0($sp)
	addi $sp, $sp, -4
	
	sw $t1, 0($sp)
	addi $sp, $sp, -4
	
	jal blast_head
	
	addi $sp, $sp, 4
	lw $t1, 0($sp)
	
	addi $sp, $sp, 4
	lw $t7, 0($sp)
	
	j no_increment_head
	
head_hit_blaster:
	jal blaster_hit

############################################################################################
# overwrites t0
start_centipede:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	beq $s4, $zero, first_centipede
	
middle_centipede:
	lw $t0, centipedeAddress
	sll $t1, $s2, 2
	add $t0, $t0, $t1
	
	li $t1, 8
	li $t2, 40
	sh $t1, 0($t0)
	sh $t2, 2($t0)
	
	addi $a0, $s2, 0
	jal draw_centipede
	addi $s2, $s2, 1
	j finsh_drawing_centipede
	
first_centipede:
	lw $t0, centipedeHeadAddress
	sll $t1, $s5, 2
	add $t0, $t0, $t1
	
	li $t1, 8
	li $t2, 40
	sh $t1, 0($t0)
	sh $t2, 2($t0)
	
	addi $a0, $s5, 0
	jal draw_centipede_head
	addi $s5, $s5, 1
	
finsh_drawing_centipede:
	addi $s4, $s4, 1
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################
# a0 is the index of the centipede in centipede address
# overites t0-t5, a0, a1
draw_centipede:
	lw $t0, centipedeAddress
	
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)		#Y offset
	lh $t2, 2($t0)		#X offset
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp

	lw $a0, centipedeColor
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	jal draw_square
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	
	jr $ra
	

############################################################################################
# a0 is the index of the centipede in centipede address
# overites t0-t2, a0, a1
draw_centipede_head:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	lw $t0, centipedeHeadAddress
	addi $t8, $a0, 0
	
	sll $t1, $a0, 2
	add $t0, $t0, $t1
	
	lh $a0, 0($t0)		#Y offset
	lh $a1, 2($t0)		#X offset
	
	jal find_mushroom
	
	bne $a2, $s1, mushroom_overlap
	
overlap_resolved:
	lw $t0, centipedeHeadAddress
	sll $t1, $t8, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)		#Y offset
	lh $t2, 2($t0)		#X offset
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	
	lw $a0, centipedeHeadColor
	
	jal draw_square
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	
	jr $ra
	
mushroom_overlap:	
	lw $t0, mushroomAddress
	sll $t1, $a2, 2
	add $t0, $t0, $t1
	
	lh $t1, 0($t0)
	lh $t2, 2($t0)
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $a1, $t1, $gp
	
	jal erase_square_unsafe
	
	addi $a0, $a2, 0
	
	jal delete_mushroom
	
	j overlap_resolved
	

############################################################################################
# overwrites t1, t0
start_blaster:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	lw $t0, blasterAddress
	addi $t1, $zero, 30
	
	sh $t1, 0($t0)
	
	jal draw_blaster
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################
# overides t0, ra, t1, a0, t2
draw_blaster:
	lw $a0, blasterColor
	lw $t0, blasterAddress
	lh $t1, 0($t0)
	
	addi $t2, $zero, 63
	sll $t2, $t2, 6
	add $t2, $t2, $t1
	sll $t2, $t2, 2
	add $t2, $t2, $gp
	
	sw $a0, -4($t2)
	sw $a0, 4($t2)
	sw $a0, -256($t2)
	
	jr $ra
	
############################################################################################
# overides t0, ra, t1, a0, t2
erase_blaster:
	li $a0, 1
	lw $t0, blasterAddress
	lh $t1, 0($t0)
	
	addi $t2, $zero, 63
	sll $t2, $t2, 6
	add $t2, $t2, $t1
	sll $t2, $t2, 2
	add $t2, $t2, $gp
	
	sw $a0, -4($t2)
	sw $a0, 4($t2)
	sw $a0, -256($t2)
	
	jr $ra

############################################################################################# 
# s0 is score
# overwrites t0-t3, t6, t7, a0
draw_score_num:
	sw $ra, 0($sp)
	addi $sp, $sp, -4	#save return address
	
	jal reset_score
	
	lw $a0, textColor
	
	li $t0, 107		#first number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1

	li $t2, 10
	
	div $s0, $t2		
	mfhi $a2
	jal check_number
	
	mflo $t3
	
	subi $t0, $t0, 4	#second number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	
	div $t3, $t2
	mfhi $a2
	jal check_number
	
	mflo $t3
	
	subi $t0, $t0, 4	#third number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	
	div $t3, $t2
	mfhi $a2
	jal check_number
	
	mflo $t3
	
	subi $t0, $t0, 4	#fourth number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	
	div $t3, $t2
	mfhi $a2
	jal check_number
	
	mflo $t3
	
	subi $t0, $t0, 4	#fifth number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	
	div $t3, $t2
	mfhi $a2
	jal check_number
	
	mflo $t3
	
	subi $t0, $t0, 4	#sixth number
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	
	div $t3, $t2
	mfhi $a2
	jal check_number

	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra

############################################################################################
# overwrites t0, t1, a1, a0, t2

reset_score:
	sw $ra, 0($sp)
	addi $sp, $sp, -4
	
	li $t0, 107
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	li $t2, 6
	
reset_score_loop:
	jal reset_num
	subi $t0, $t0, 4
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	subi $t2, $t2, 1
	bgt $t2, $zero, reset_score_loop
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra
	

############################################################################################

draw_lives_num:
	sw $ra, 0($sp)
	addi $sp, $sp, -4	#save return address
	
	li $t0, 124		#reset lives
	sll, $t1, $t0, 2
	add $a1, $gp, $t1
	jal reset_num
	
	lw $a0, textColor
	addi $a2, $s3, 0
	jal check_number
	
	addi $sp, $sp, 4
	lw $ra, 0($sp)
	jr $ra
	


############################################################################################
# a1 is address
# overwrites a0

reset_num:
	lw $a0, backgroundColor
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 768($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra

############################################################################################
# $a0 is color
# overwirites t0-t1
draw_score_text:
	li $t0, 65

layer_1:
	sll, $t1, $t0, 2
	add $t1, $gp, $t1

	sw $a0, 0($t1)
	sw $a0, 4($t1)
	sw $a0, 8($t1)
	sw $a0, 16($t1)
	sw $a0, 20($t1)
	sw $a0, 24($t1)
	sw $a0, 32($t1)
	sw $a0, 36($t1)
	sw $a0, 40($t1)
	sw $a0, 48($t1)
	sw $a0, 52($t1)
	sw $a0, 64($t1)
	sw $a0, 68($t1)
	sw $a0, 72($t1)
	
layer_2:
	addi $t0, $t0, 64
	sll, $t1, $t0, 2
	add $t1, $gp, $t1
	
	sw $a0, 0($t1)
	sw $a0, 16($t1)
	sw $a0, 32($t1)
	sw $a0, 40($t1)
	sw $a0, 48($t1)
	sw $a0, 56($t1)
	sw $a0, 64($t1)

layer_3:
	addi $t0, $t0, 64
	sll, $t1, $t0, 2
	add $t1, $gp, $t1
	
	sw $a0, 0($t1)
	sw $a0, 4($t1)
	sw $a0, 8($t1)
	sw $a0, 16($t1)
	sw $a0, 32($t1)
	sw $a0, 40($t1)
	sw $a0, 48($t1)
	sw $a0, 52($t1)
	sw $a0, 64($t1)
	sw $a0, 68($t1)
	sw $a0, 72($t1)
	sw $a0, 80($t1)

layer_4:
	addi $t0, $t0, 64
	sll, $t1, $t0, 2
	add $t1, $gp, $t1
	
	sw $a0, 8($t1)
	sw $a0, 16($t1)
	sw $a0, 32($t1)
	sw $a0, 40($t1)
	sw $a0, 48($t1)
	sw $a0, 56($t1)
	sw $a0, 64($t1)
	
layer_5:
	addi $t0, $t0, 64
	sll, $t1, $t0, 2
	add $t1, $gp, $t1

	sw $a0, 0($t1)
	sw $a0, 4($t1)
	sw $a0, 8($t1)
	sw $a0, 16($t1)
	sw $a0, 20($t1)
	sw $a0, 24($t1)
	sw $a0, 32($t1)
	sw $a0, 36($t1)
	sw $a0, 40($t1)
	sw $a0, 48($t1)
	sw $a0, 56($t1)
	sw $a0, 64($t1)
	sw $a0, 68($t1)
	sw $a0, 72($t1)
	sw $a0, 80($t1)
	
	jr $ra

############################################################################################
# a0 is color
# a1 is address of top left pixel of square
# overwrites a1
draw_square:	
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	addi $a1, $a1, 256
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	
	jr $ra

############################################################################################
# a1 is address of top left pixel of square
# overwrites a1
erase_square_unsafe:
	li $a0, 1
	
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	addi $a1, $a1, 256
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	
	jr $ra

############################################################################################
# a1 is address of top left pixel of square
# overwrites a1
erase_square:
	lw $a0, backgroundColor
	
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	addi $a1, $a1, 256
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	
	jr $ra


############################################################################################
#overwrites a0 - a1, v0
get_random_chance:
  	li $v0, 42        
  	li $a0, 0          
  	li $a1, 30
  	syscall             
  	jr $ra

############################################################################################
#overwrites a0 - a1, v0
get_random_x:
  	li $v0, 42        
  	li $a0, 0          
  	li $a1, 30
  	syscall             
  	jr $ra
  	

############################################################################################
# a0 is Y offset
# a1 is X offset
# overides a0, a1, t6, a2
# return a2, with 0->safe, 1->unsafe, 2->safe for head/flea, 3->blaster, 4-> blast
check_square_safe:
	sll $a0, $a0, 6
	add $a0, $a0, $a1
	sll $a0, $a0, 2
	add $t6, $a0, $gp
	
	lw $a0, 0($t6)
	lw $a1, backgroundColor
	bne $a0, $a1, unsafe
	
	lw $a0, 4($t6)
	bne $a0, $a1, unsafe
	
	lw $a0, 256($t6)
	bne $a0, $a1, unsafe
	
	lw $a0, 260($t6)
	bne $a0, $a1, unsafe
	
	addi $a2, $zero, 0
	jr $ra
	
unsafe:
	lw $a1, blasterColor
	lw $a0, 0($t6)
	beq $a0, $a1, blaster
	
	lw $a0, 4($t6)
	beq $a0, $a1, blaster
	
	lw $a0, 256($t6)
	beq $a0, $a1, blaster
	
	lw $a0, 260($t6)
	beq $a0, $a1, blaster
	
	lw $a1, blastColor
	lw $a0, 0($t6)
	beq $a0, $a1, blast
	
	lw $a0, 4($t6)
	beq $a0, $a1, blast
	
	lw $a0, 256($t6)
	beq $a0, $a1, blast
	
	lw $a0, 260($t6)
	beq $a0, $a1, blast
	
	li $a1, 1
	lw $a0, 0($t6)
	beq $a0, $a1, special
	
	lw $a0, 4($t6)
	beq $a0, $a1, special
	
	lw $a0, 256($t6)
	beq $a0, $a1, special
	
	lw $a0, 260($t6)
	beq $a0, $a1, special
	
	addi $a2, $zero, 1
	jr $ra
	
special:
	addi $a2, $zero, 2
	jr $ra
	
blaster:
	addi $a2, $zero, 3
	jr $ra
	
blast:
	addi $a2, $zero, 4
	jr $ra

############################################################################################
# a0 is y offset, a1 is x offset of top left of square with even y that contains the blast
# a2 is index of blast
# overwrites t0-t4, a2
find_blast:
	lw $t0, blastAddress
	li $t1, 0
	
find_blast_loop:
	lh $t2, 0($t0)
	lh $t3, 2($t0)
	
	bne $t2, $a0, continue_find_blast_loop
	bne $t3, $a1, continue_find_blast_loop

	j found_blast
	
continue_find_blast_loop:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $s7, find_blast_loop
	
found_blast:
	addi $a2, $t1, 0
	jr $ra


############################################################################################
# a0 is y offset, a1 is x offset of top left of square that contains mushroom
# a2 is index of mushroom
# overwrites t0-t3, a2
find_mushroom:
	lw $t0, mushroomAddress
	li $t1, 0
	
find_mushroom_loop:
	lh $t2, 0($t0)
	lh $t3, 2($t0)
	
	bne $t2, $a0, continue_find_mushroom_loop
	bne $t3, $a1, continue_find_mushroom_loop
	j found_mushroom
	
continue_find_mushroom_loop:
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	blt $t1, $s1, find_mushroom_loop
	
found_mushroom:
	addi $a2, $t1, 0
	jr $ra

############################################################################################
# a0 is y offset, a1 is x offset of top left of square that contains head
# a2 is index of head
# overwrites t0-t3, a2
find_head:
	lw $t0, centipedeHeadAddress
	li $t1, 0
	
find_head_loop:
	lh $t2, 0($t0)
	lh $t3, 2($t0)
	
	bne $t2, $a0, continue_find_head_loop
	bne $t3, $a1, continue_find_head_loop
	j found_head
	
continue_find_head_loop:
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	blt $t1, $s5, find_head_loop
	
found_head:
	addi $a2, $t1, 0
	jr $ra



############################################################################################
# a0 is y offset, a1 is x offset of top left of square that contains centipede
# a2 is index of centipede
# overwrites t0-t3, a2
find_centipede:
	lw $t0, centipedeAddress
	li $t1, 0
	beq $t1, $s2, found_centipede
	
find_centipede_loop:
	lh $t2, 0($t0)
	lh $t3, 2($t0)
	
	bne $t2, $a0, continue_find_centipede_loop
	bne $t3, $a1, continue_find_centipede_loop
	j found_centipede
	
continue_find_centipede_loop:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $s2, find_centipede_loop
	
found_centipede:
	addi $a2, $t1, 0
	jr $ra


############################################################################################
# a0 is y offset, a1 is x offset of top left of square that contains flea
# a2 is index of flea
# overwrites t0-t3, a2
find_flea:
	lw $t0, fleaAddress
	li $t1, 0
	
find_flea_loop:
	lh $t2, 0($t0)
	lh $t3, 2($t0)
	
	bne $t2, $a0, continue_find_flea_loop
	bne $t3, $a1, continue_find_flea_loop
	j found_flea
	
continue_find_flea_loop:
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	blt $t1, $s6, find_flea_loop
	
found_flea:
	addi $a2, $t1, 0
	jr $ra



############################################################################################
# a0 is color
# a1 is top left of number (address)
# a2 is number
# overwrites t6, t7

check_number:
	add $t7, $zero, $zero 
	beq $a2, $t7, draw_0
	addi $t7, $t7, 1
	beq $a2, $t7, draw_1
	addi $t7, $t7, 1
	beq $a2, $t7, draw_2
	addi $t7, $t7, 1
	beq $a2, $t7, draw_3
	addi $t7, $t7, 1
	beq $a2, $t7, draw_4
	addi $t7, $t7, 1
	beq $a2, $t7, draw_5
	addi $t7, $t7, 1
	beq $a2, $t7, draw_6
	addi $t7, $t7, 1
	beq $a2, $t7, draw_7
	addi $t7, $t7, 1
	beq $a2, $t7, draw_8
	addi $t7, $t7, 1
	beq $a2, $t7, draw_9

draw_0:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 520($a1)
	sw $a0, 768($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_1:
	sw $a0, 8($a1)
	sw $a0, 264($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_2:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 768($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_3:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_4:
	sw $a0, 0($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_5:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_6:
	sw $a0, 0($a1)
	sw $a0, 256($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 768($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_7:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 264($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_8:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 768($a1)
	sw $a0, 776($a1)
	sw $a0, 1024($a1)
	sw $a0, 1028($a1)
	sw $a0, 1032($a1)
	jr $ra
	
draw_9:
	sw $a0, 0($a1)
	sw $a0, 4($a1)
	sw $a0, 8($a1)
	sw $a0, 256($a1)
	sw $a0, 264($a1)
	sw $a0, 512($a1)
	sw $a0, 516($a1)
	sw $a0, 520($a1)
	sw $a0, 776($a1)
	sw $a0, 1032($a1)
	jr $ra
	

############################################################################################
draw_game_over:
	lw $t0, displayAddress
	addi $t0, $t0, 2048
	addi $t1, $t0, 14336
	lw $t2, backgroundColor
	
erase_background_loop:
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	blt $t0, $t1, erase_background_loop
	
draw_game_over_text:
	lw $a0, textColor
	lw $t0, displayAddress
	
	addi $t1, $zero, 26
	addi $t2, $zero, 6
	
	sll $t1, $t1, 6
	add $t1, $t1, $t2
	sll $t1, $t1, 2
	add $t0, $t1, $t0
	
	sw $a0, 4($t0)		# Draw G
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 256($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 768($t0)
	sw $a0, 776($t0)
	sw $a0, 780($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1040($t0)
	sw $a0, 1280($t0)
	sw $a0, 1296($t0)
	sw $a0, 1536($t0)
	sw $a0, 1552($t0)
	sw $a0, 1796($t0)
	sw $a0, 1800($t0)
	sw $a0, 1804($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw A
	sw $a0, 4($t0)		
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 528($t0)
	sw $a0, 768($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1028($t0)
	sw $a0, 1032($t0)
	sw $a0, 1036($t0)
	sw $a0, 1040($t0)
	sw $a0, 1280($t0)
	sw $a0, 1296($t0)
	sw $a0, 1536($t0)
	sw $a0, 1552($t0)
	sw $a0, 1792($t0)
	sw $a0, 1808($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw M
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 260($t0)
	sw $a0, 268($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 520($t0)
	sw $a0, 528($t0)
	sw $a0, 768($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1040($t0)
	sw $a0, 1280($t0)
	sw $a0, 1296($t0)
	sw $a0, 1536($t0)
	sw $a0, 1552($t0)
	sw $a0, 1792($t0)
	sw $a0, 1808($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw E
	sw $a0, 4($t0)		
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 512($t0)
	sw $a0, 768($t0)
	sw $a0, 772($t0)
	sw $a0, 776($t0)
	sw $a0, 780($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1280($t0)
	sw $a0, 1536($t0)
	sw $a0, 1792($t0)
	sw $a0, 1796($t0)
	sw $a0, 1800($t0)
	sw $a0, 1804($t0)
	sw $a0, 1808($t0)
	
	addi $t0, $t0, 20
	
	addi $t0, $t0, 20	# Draw Space
	
	sw $a0, 0($t0)		# Draw O
	sw $a0, 4($t0)		
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 528($t0)
	sw $a0, 768($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1040($t0)
	sw $a0, 1280($t0)
	sw $a0, 1296($t0)
	sw $a0, 1536($t0)
	sw $a0, 1552($t0)
	sw $a0, 1792($t0)
	sw $a0, 1796($t0)
	sw $a0, 1800($t0)
	sw $a0, 1804($t0)
	sw $a0, 1808($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw V
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 528($t0)
	sw $a0, 768($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1040($t0)
	sw $a0, 1280($t0)
	sw $a0, 1284($t0)
	sw $a0, 1292($t0)
	sw $a0, 1296($t0)
	sw $a0, 1540($t0)
	sw $a0, 1544($t0)
	sw $a0, 1548($t0)
	sw $a0, 1800($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw E
	sw $a0, 4($t0)		
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 16($t0)
	sw $a0, 256($t0)
	sw $a0, 512($t0)
	sw $a0, 768($t0)
	sw $a0, 772($t0)
	sw $a0, 776($t0)
	sw $a0, 780($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1280($t0)
	sw $a0, 1536($t0)
	sw $a0, 1792($t0)
	sw $a0, 1796($t0)
	sw $a0, 1800($t0)
	sw $a0, 1804($t0)
	sw $a0, 1808($t0)
	
	addi $t0, $t0, 24
	
	sw $a0, 0($t0)		# Draw R
	sw $a0, 4($t0)
	sw $a0, 8($t0)
	sw $a0, 12($t0)
	sw $a0, 256($t0)
	sw $a0, 272($t0)
	sw $a0, 512($t0)
	sw $a0, 528($t0)
	sw $a0, 768($t0)
	sw $a0, 784($t0)
	sw $a0, 1024($t0)
	sw $a0, 1028($t0)
	sw $a0, 1032($t0)
	sw $a0, 1036($t0)
	sw $a0, 1280($t0)
	sw $a0, 1296($t0)
	sw $a0, 1536($t0)
	sw $a0, 1552($t0)
	sw $a0, 1792($t0)
	sw $a0, 1808($t0)
	
	jr $ra











