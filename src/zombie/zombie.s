.text
.global _init_zombies
_init_zombies:
    addi sp, sp, -4
    stw ra, 0(sp)

    call _init_zombie_animations
    call _init_zombie_controller

    movia r4, ZOMBIE
    call _spawn_zombie

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

/* Creates a zombie at the given address
 * r4: the address to init the zombie
 */
.global _spawn_zombie
_spawn_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r17, r4

    movia r16, 0x000A000A   # Start at position 10, 10
    stw r16, 0(r17)

    movia r16, SPRITE_ZOMBIE_WALK_1     #Starting animation
    stw r16, 4(r17)

    movia r16, 1000                     # Move/animation counters
    stw r16, 8(r17)

    stw r16, 16(r17)

    movia r16, 600                      # Move/animation speeds
    stw r16, 12(r17)

    stw r16, 20(r17)

    movia r16, ZOMBIE_WALK_AS           # Starting animation
    stw r16, 24(r17)
    stw r16, 28(r17)

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

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

    ldw r16, 16(r18)
    ble r16, r0, move_z
    br inc_move_counter

    move_z:
        movi r16, 1000      # reset counter
        stw r16, 16(r18)

        ldw r16, 0(r18)     # Does the move
        addi r16, r16, 0
        stw r16, 0(r18)
        br UPDATE_ZOMBIE_RETURN

    inc_move_counter:
        ldw r17, 20(r18)    # increments the counter
        sub r16, r16, r17
        stw r16, 16(r18)
        br UPDATE_ZOMBIE_RETURN
        

    UPDATE_ZOMBIE_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
/* Draws a given zombie
 * r4: zombie object pointer
*/
.global _draw_zombie
_draw_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4         # Save the object pointer

    ldw r4, 4(r18)
    movi r5, 55
    movi r6, 60
    ldw r7, 0(r18)
    call DrawImage      # Draw the sprite

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
/* Draws a given zombie hitbox
 * r4: zombie object pointer
*/
.global _draw_zombie_hitbox
_draw_zombie_hitbox:
addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4         # Save the object pointer

    ldw r4, 4(r18)
    movi r5, 30
    movi r6, 60
    ldw r7, 0(r18)
    movia r16, (12<<16)
    add r7, r7, r16       # Offset the x by 12
    call DrawCollisionBox      # Draw the sprite

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
