/*
 * Entry point for crisis
 * Authors Stefan Stancu, Josh Hartmann
*/

.data
    .global GAME_STATE
    GAME_STATE:
        .word -3
.text

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

    movi r4, GAME_STATE
    ldw r5, 0(r4)
    ble r5, r0, skip

    movia r4, ZOMBIE_ARRAY
    call _update_controller

    movia r4, ZOMBIE_ARRAY
    call _update_zombies

    skip:

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

draw:
    addi sp, sp, -8
    stw ra, 0(sp)

    rdctl r4, ctl0
    stw r4, 4(sp)

    wrctl ctl0, r0

    movi r4, GAME_STATE
    ldw r5, 0(r4)
    ble r5, r0, START_SCREEN

    movia r4, BG_IMAGE
    movi r5, 320
    movi r6, 240
    movi r7, 0
    call DrawImage

    call _draw_hud

    movia r4, ZOMBIE_ARRAY
    call _draw_zombies

    br draw_return

    START_SCREEN:
        movia r4, SS_IMAGE
        movi r5, 320
        movi r6, 240
        movi r7, 0
        call DrawImage
        br draw_return

    draw_return:
    call waitForBufferWrite
    call swapBuffers

    ldw r4, 4(sp)
    wrctl ctl0, r4

    ldw ra, 0(sp)
    addi sp, sp, 8

    ret
