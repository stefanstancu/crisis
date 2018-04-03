.data
    .global SPRITE_ZOMBIE_WALK_1
    SPRITE_ZOMBIE_WALK_1:
        .incbin "../../res/zombie/zombie_front_1.bin"
    SPRITE_ZOMBIE_WALK_2:
        .incbin "../../res/zombie/zombie_front_2.bin"
    SPRITE_ZOMBIE_WALK_3:
        .incbin "../../res/zombie/zombie_front_3.bin"
    SPRITE_ZOMBIE_WALK_4:
        .incbin "../../res/zombie/zombie_front_4.bin"

    SPRITE_ZOMBIE_DIE_1:
        .incbin "../../res/zombie/zombie_die_1.bin"
    SPRITE_ZOMBIE_DIE_2:
        .incbin "../../res/zombie/zombie_die_2.bin"
    SPRITE_ZOMBIE_DIE_3:
        .incbin "../../res/zombie/zombie_die_3.bin"
    SPRITE_ZOMBIE_DIE_4:
        .incbin "../../res/zombie/zombie_die_4.bin"
    SPRITE_ZOMBIE_DIE_5:
        .incbin "../../res/zombie/zombie_die_5.bin"
    SPRITE_ZOMBIE_DIE_6:
        .incbin "../../res/zombie/zombie_die_6.bin"
    SPRITE_ZOMBIE_DIE_7:
        .incbin "../../res/zombie/zombie_die_7.bin"
    SPRITE_ZOMBIE_DIE_8:
        .incbin "../../res/zombie/zombie_die_8.bin"

    .global ZOMBIE_WALK_AS
    ZOMBIE_WALK_AS:
        .skip 20

    .global ZOMBIE_DIE_AS
    ZOMBIE_DIE_AS:
        .skip 36
.text

/* Inits the zombie animations by placing the correct addresses into the animation sequence
 */
.global _init_zombie_animations
_init_zombie_animations:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    movia r17, ZOMBIE_WALK_AS

    movia r16, SPRITE_ZOMBIE_WALK_1
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_WALK_2
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_WALK_3
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_WALK_4
    stw r16, 0(r17)
    addi r17, r17, 4

    stw r0, 0(r17)                  # Terminate AS with a 0

    .global ZOMBIE_DIE_AS
    movia r17, ZOMBIE_DIE_AS

    movia r16, SPRITE_ZOMBIE_DIE_1
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_2
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_3
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_4
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_5
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_6
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_7
    stw r16, 0(r17)
    addi r17, r17, 4

    movia r16, SPRITE_ZOMBIE_DIE_8
    stw r16, 0(r17)
    addi r17, r17, 4

    stw r0, 0(r17)                  # Terminate AS with a 0

    ldw ra, 0(sp)                    # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Takes a pointer to a zombie object and set its frame pointer appropriately
 * See specsheet for zombie object definition
 * r4: address of the zombie object
*/
.global _animate_zombie
_animate_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4         # Save the zombie object pointer

    # Check the counter
    ldw r16, 8(r18)
    blt r16, r0, DO_ANIMATE         # If the counter is zero, do the animation
    br INC_COUNTER

    INC_COUNTER:
        ldw r17, 12(r18)
        sub r16, r16, r17
        stw r16, 8(r18)
        br ZOMBIE_ANIMATE_RETURN

    DO_ANIMATE:
        mov r4, r18                 # Pass object as parameter
        call set_next_frame_zombie

        movi r16, 1000              # Reset the counter
        stw r16, 8(r18)

    ZOMBIE_ANIMATE_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Sets the next frame in the animation
 * r4: the address of the current object
 * 
*/
set_next_frame_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    ldw r16, 28(r4)                 # Load the animation sequence pointer
    ldw r17, 4(r16)                 # Load the next frame pointer in the sequence
    beq r17, r0, RESET_ANIMATION    # If next frame is zero
    br NEXT_FRAME

    NEXT_FRAME:
        addi r16, r16, 4
        stw r16, 28(r4)             # Increment the animation sequence pointer

        stw r17, 4(r4)              # Store the sprite pointer in the object       
        br NEXT_FRAME_RETURN

    RESET_ANIMATION:
        ldw r16, 24(r4)             # Set the frame
        stw r16, 28(r4)

        ldw r17, 0(r16)
        stw r17, 4(r4)              # Reset the animation sequence pointer to the start of animation
        br NEXT_FRAME_RETURN

    NEXT_FRAME_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

