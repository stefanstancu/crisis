/* Controller for all zombies */
.equ ZOMBIE_SIZE, 32

.data
    .global ZOMBIE_ARRAY
    ZOMBIE_ARRAY:
        .skip 24        # Save 6 words/ 5 zombies 

    ZOMBIES:
        .skip 160       # sizeof(zombie) * 5

    SPAWN_COUNTER:
        .skip 4

    SPAWN_SPEED:
        .skip 4

.text
.global _init_zombie_controller
_init_zombie_controller:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    movia r17, SPAWN_COUNTER    # Init spawn counter and speed
    movi r16, 1000
    stw r16, 0(r17)
    
    movia r17, SPAWN_SPEED
    movi r16, 50
    stw r16, 0(r17)

    movia r16, ZOMBIE_ARRAY     # Populate the entity table
    movia r17, ZOMBIES
    movi r18, ZOMBIE_SIZE
    
    stw r17, 0(r16)             # Save the addresses of the zombie objects

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

/* Controls the zombie spawning
 * r4: the pointer to the zombie array
 */
.global _update_controller
_update_controller:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    movia r17, SPAWN_COUNTER
    ldw r16, 0(r17)
    bgt r16, r0, inc_spawn_counter
    br spawn

    inc_spawn_counter:
        movia r17, SCORE            # Get the score
        ldw r18, 0(r17)

        movia r17, SPAWN_SPEED      # Add the score and the speed
        ldw r16, 0(r17)
        add r18, r18, r16

        movia r17, SPAWN_COUNTER
        ldw r16, 0(r17)

        sub r16, r16, r18           # Sub from the spawn counter          
        stw r16, 0(r17)             # Store the counter

        br UPDATE_CTL_RETURN

    spawn:
        movi r4, 0
        movi r5, 266
        call _rand
        
        slli r5, r2, 16
        movi r16, 0

        andi r16, r16, 0x0000FFFF
        or r5, r5, r16

        movia r4, ZOMBIE_ARRAY
        movi r6, 500
        call _spawn_zombie

        movi r16, 1000
        movia r17, SPAWN_COUNTER
        stw r16, 0(r17)

        br UPDATE_CTL_RETURN

    UPDATE_CTL_RETURN:
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
        beq r16, r0, update_cont   # If the zombie is flagged as dead
        call _update_zombie

        update_cont:
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
        beq r16, r0, draw_cont   # If the zombie is flagged as dead
        call _draw_zombie

        draw_cont:
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
 * r6: speed
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
            # r6 already contains speed
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

/* Checks all the zombies in the given array for a collision
 * r4: the entity array
 */
.global _check_zombie_hits
_check_zombie_hits:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r18, r4

    check_loop:
        ldw r4, 0(r18)
        beq r4, r0, CHECK_RETURN   # If end of array
        ldw r16, 24(r4)
        beq r16, r0, check_cont   # If the zombie is flagged as dead
        call _check_zombie_hit
        beq r2, r0, CHECK_RETURN

        check_cont:
        addi r18, r18, 4            # Go to next entry
        br check_loop

    CHECK_RETURN:
    ldw ra, 0(sp)       # Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    addi sp, sp, 16

    ret
