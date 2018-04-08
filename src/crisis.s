/*
 * Entry point for crisis
 * Authors Stefan Stancu, Josh Hartmann
*/

.global _start
_start:
	movia sp, 0x04000000	# Initial stack pointer
    call _init
    game_loop:
        
        movi r5, 500           #here to test random number generator
        movi r4, 200

        call _get_random_number
        call update
        call draw

        br game_loop

update:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r4, ZOMBIE_ARRAY
    call _update_zombies

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

draw:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r4, BG_IMAGE
    movi r5, 320
    movi r6, 240
    movi r7, 0
    call DrawImage

    call _draw_hud

    movia r4, ZOMBIE_ARRAY
    call _draw_zombies

    call swapBuffers
    call waitForBufferWrite

    ldw ra, 0(sp)
    addi sp, sp, 4

    ret
