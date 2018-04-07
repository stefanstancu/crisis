/* Controller for all zombies */
.equ ZOMBIE_SIZE, 32

.data
    .global ZOMBIE_ARRAY
    ZOMBIE_ARRAY:
        .skip 24        # Save 6 words/ 5 zombies 

    ZOMBIES:
        .skip 160       # sizeof(zombie) * 5

.text
.global _init_zombie_controller
_init_zombie_controller:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    # Populate the entity table
    movia r16, ZOMBIE_ARRAY
    movia r17, ZOMBIES
    movi r18, ZOMBIE_SIZE
    
    stw r17, 0(r16)         # Save the addresses of the zombie objects

    movi r4, 4
    addr_loop:
        add r17, r17, r18
        addi r16, r16, 4
        stw r17, 0(r16)

        addi r4, r4, -1
        bgt r4, r0, addr_loop

    addi r16, r16, 4
    stw r0, 0(r16)

    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Updates all the zombies in the given array
 * r4: the entity array
 */
.global _update_zombies
_update_zombies:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4

    update_loop:
        ldw r4, 0(r18)
        beq r4, r0, UPDATE_RETURN   # If end of array
        ldw r16, 4(r4)
        beq r16, r0, UPDATE_RETURN   # If the zombie is flagged as dead
        call _update_zombie
        addi r18, r18, 4            # Go to next entry
        br update_loop

    UPDATE_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Draws all the zombies in the given array
 * r4: the entity array
 */
.global _draw_zombies
_draw_zombies:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4

    draw_loop:
        ldw r4, 0(r18)
        beq r4, r0, DRAW_RETURN   # If end of array
        ldw r16, 4(r4)
        beq r16, r0, DRAW_RETURN   # If the zombie is flagged as dead
        call _draw_zombie
        addi r18, r18, 4            # Go to next entry
        br draw_loop

    DRAW_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret

/* Spawns a zombie in the next availble slot
 * r4: the entity array
 * r5: xy position
 */
.global _spawn_zombie
_spawn_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4

    spawn_loop:
        ldw r4, 0(r18)
        beq r4, r0, SPAWN_RETURN   # If end of array

        ldw r16, 4(r4)
        beq r16, r0, SPAWN   # If the zombie is flagged as dead
        br CONT

        SPAWN:
            # r5 already contains xy
            call _make_zombie
            br SPAWN_RETURN
        
        CONT:
        addi r18, r18, 4            # Go to next entry
        br spawn_loop

    SPAWN_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
