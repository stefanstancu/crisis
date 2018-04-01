.data
	.global SPRITE_ZOMBIE_1
    SPRITE_ZOMBIE_1:
        .incbin "../../res/charles.bin"
.text

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
    blt r16, r0, DO_ANIMATE

    INC_COUNTER:
        ldw r17, 12(r18)
        sub r16, r16, r17
        stw r16, 8(r18)
        br ZOMBIE_ANIMATE_RETURN

    DO_ANIMATE:
        ldw r17, 4(r18)             # Load frame
        
        mov r4, r17
        call get_next_frame_zombie
        mov r17, r2                 # Get the next frame

        stw r16, 4(r18)             # Set the frame

    ZOMBIE_ANIMATE_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Gets the next frame in the animation
 * r4: the address of the current zombie frame
 * 
 * r2: the adress of the next zombie frame
*/
get_next_frame_zombie:
    mov r2, r4          # Temp behaviour while testing
    ret  
