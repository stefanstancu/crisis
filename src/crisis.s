/*
 * Entry point for crisis
 * Authors Stefan Stancu, Josh Hartmann
*/

.global _start
_start:
	movia sp, 0x04000000	# Initial stack pointer
    call _init

    game_loop:
        
        call update
        call draw

        br game_loop

update:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r4, ZOMBIE
    call _update_zombie

    movia r4, ZOMBIE_ARRAY
    call _update_zombies

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

draw:
    addi sp, sp, -4
    stw ra, 0(sp)

    call waitForBufferWrite

    movia r4, 0x0
    call FillColour			# Fill screen with a colour

    movia r4, ZOMBIE
    call _draw_zombie

    call swapBuffers

    ldw ra, 0(sp)
    addi sp, sp, 4

    ret
