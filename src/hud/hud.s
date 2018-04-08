.equ HEALTH_COL, 15
.equ HEALTH_ROW, 55

.equ SCORE_COL, 55
.equ SCORE_ROW, 55

.data
    .global PLAYER_HEALTH
    PLAYER_HEALTH:
        .word 100
    SCORE:
        .word 0
    AMMO:
        .word 10

.text

.global _init_hud
_init_hud:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    movi r16, 100
    movia r17, PLAYER_HEALTH
    stw r16, 0(r17)

    movia r17, SCORE
    stw r0, 0(r17)

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Draws all of the hud components*/
.global _draw_hud
_draw_hud:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue
    
    call draw_health
    call draw_score
    
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

draw_health:
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
        ble r16, r0, HEALTH_RETURN
        br draw_health_loop

    HEALTH_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

draw_score:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue
    
    movia r16, SCORE
    ldw r4, 0(r16)
    call _num_to_ascii

    movi r17, SCORE_COL
    movi r16, 3
    draw_score_loop:
        andi r6, r2, 0x00FF
        mov r4, r17
        movi r5, SCORE_ROW
        call WriteChar
        srli r2, r2, 8

        addi r16, r16, -1
        addi r17, r17, 1
        ble r16, r0, SCORE_RETURN
        br draw_score_loop

    SCORE_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
