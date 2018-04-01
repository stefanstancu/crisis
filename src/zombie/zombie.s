.data
	.global ZOMBIE
    ZOMBIE:
        .skip 16

.text
/* Initializes the zombies*/
.global _init_zombies
_init_zombies:
    # Inits one zombie for testing

    movia r17, ZOMBIE

    mov r16, r0
    stw r16, 0(r17)

    movia r16, SPRITE_ZOMBIE_1
    stw r16, 4(r17)

    movia r16, 1000
    stw r16, 8(r17)

    movia r16, 10
    stw r16, 12(r17)

    ret

/* Updates a given zombie
 * r4: zombie object pointer
*/
.global _update_zombie
_update_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4            # Save the zombie object pointer

    mov r4, r18
    call _animate_zombie    # Update the animation

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

.global _draw_zombie
_draw_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4         # Save the object pointer

    ldw r4, 4(r18)
    movi r5, 40
    movi r6, 40
    ldw r7, 0(r18)
    call DrawImage      # Draw the sprite

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
