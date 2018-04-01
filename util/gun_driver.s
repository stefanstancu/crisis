.equ GPIO1, 0xFF200060
.equ LEDS, 0xFF200000

#checks to make sure gun is pointing at screen when trigger is pulled
.global _anti_cheat
_anti_cheat: 
	addi sp, sp, -12			#prologue  
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)

    call waitForBufferWrite

    mov r4, r0 				#Fills the screen black
    call FillColour 			

    call swapBuffers

    movia r16, GPIO1 		# gets data from sensor PIN 2 (D1)
    ldwio r17, 0(r16)
    srli r17, r17, 1
    andi r17, r17, 0x01 			

    beq  r17, r0, CHECK_HITS  	# assuming sensor reads high on target, may have to change later
    br ANTI_CHEAT_RETURN

CHECK_HITS:

	call waitForBufferWrite

    movia r4, WHITE 	#Fills the screen white, test to see that anti cheat works
    call FillColour 			

    call swapBuffers
	#call _check_zombie_hits

ANTI_CHEAT_RETURN:
    ldw ra, 0(sp)			#Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)			
    addi sp, sp, 12
    ret

#checks to see if gun is pointed at zombie when trigger is pulled
    .global _check_zombie_hits
_check_zombie_hits: 

