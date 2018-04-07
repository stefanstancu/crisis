.equ HEALTH_COL, 20
.equ HEALTH_ROW, 55

.data
    .global PLAYER_HEALTH
    PLAYER_HEALTH:
        .word 100
    AMMO:
        .word 10

.text

/* Draws all of the hud components*/
.global _draw_hud
_draw_hud:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue
    
    movia r16, PLAYER_HEALTH
    ldw r4, 0(r16)
    call _num_to_ascii


    movi r17, HEALTH_COL
    movi r16, 3
    draw_health_loop:
        andi r6, r2, 0x00FF
        mov r4, r17
        movi r5, HEALTH_ROW
        call WriteChar
        srli r2, r2, 8

        addi r16, r16, -1
        addi r17, r17, 1
        ble r16, r0, CONT
        br draw_health_loop

    CONT:
    
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
