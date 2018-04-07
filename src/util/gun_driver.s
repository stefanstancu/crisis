.equ LEDS, 0xFF200000
.global FLASH_DELAY
.equ FLASH_DELAY, 1000000

#checks to make sure gun is pointing at screen when trigger is pulled
.global _anti_cheat
_anti_cheat: 
	addi sp, sp, -16			#prologue  
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r4, 12(sp)

    mov r4, r0 				#Fills the screen black
    call FillColour		
    call swapBuffers
	call waitForBufferWrite

    movia r16, GPIO 		# gets data from sensor PIN 2 (D1)
    ldwio r17, 0(r16)
    srli r17, r17, 1
    andi r17, r17, 0x01 			

    bgt r17, r0, CHECK_HITS  	# sensor reads low on target
    br ANTI_CHEAT_RETURN

CHECK_HITS:
    movia r4, ZOMBIE_ARRAY
	call _check_zombie_hits

ANTI_CHEAT_RETURN:
    ldw ra, 0(sp)			#Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)	
    ldw r4, 12(sp)		
    addi sp, sp, 16
    ret

