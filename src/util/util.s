.equ TIMER2, 0xFF202020
.equ RANDOM_NUM_MAX, 0x1388 #5000
.global _init
_init:
    addi sp, sp, -4
    stw ra, 0(sp)

    call _init_graphics
    call _init_zombies
    call _init_interrupts
    call _init_random_number_generator

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

#max random number possible rn is 5000 (can change)
#parameters
#r4->lower bound for random number
#r5->upper bound for random number
.global _get_random_number
_get_random_number:
    addi sp, sp, -20
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)     # Prologue

    sub r5, r5, r4      #stores difference between upper and lower bound
    movia r16, TIMER2
    ldh r17, 16(r16)    #lower 16 bits of timer snapshot->r17
    ldh r18, 20(r16)    #upper 16 bits of timer snapshot->r18

    slli r19, r18, 16   #cancatonates the timer snapshot together
    or r19, r19, r17

    div r17, r19, r5    #stores r19 modulo r5->r17
    mul r17, r17, r5
    sub r17, r19, r17

    add r17, r17, r4    #random number between bounds

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    addi sp, sp, 20
    ret

.global _init_random_number_generator
_init_random_number_generator:
    addi sp, sp, -20
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)     # Prologue

    movia r16, TIMER2                   #sets period of timer to RANDOM_NUM_MAX
    movia r17, %lo(RANDOM_NUM_MAX)
    movia r18, %hi(RANDOM_NUM_MAX)
    stwio r17, 8(r16)
    stwio r18, 12(r16)

    movi r17, 0x06             #starts timer so it keeps repeating after timeout
    stwio r17, 4(r16)

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    addi sp, sp, 20
    ret