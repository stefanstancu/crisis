.global _init
_init:
    addi sp, sp, -4
    stw ra, 0(sp)

    call _init_graphics
    call _init_zombies
    call _init_interrupts

    ldw ra, 0(sp)
    addi sp, sp, 4

    ret

/* Converts a number into its ascii codes
 * r4: the number
 * r2: the ascii code from right to left
 * ex. 100 ->0x20303031
 */
.global _num_to_ascii
_num_to_ascii:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    movi r16, 10
    movia r2, 0x20202020
     
    char_loop:
        div r17, r4, r16    # Isolate 1st digit
        mul r17, r17, r16
        sub r17, r4, r17

        slli r2, r2, 8      # Store
        addi r18, r17, 0x30
        or r2, r2, r18

        sub r4, r4, r17
        div r4, r4, r16     # Remove the last digit
        ble r4, r0, CONV_RETURN
        br char_loop
        
    CONV_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
