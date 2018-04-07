.text
.global _init_zombies
_init_zombies:
    addi sp, sp, -4
    stw ra, 0(sp)

    call _init_zombie_animations
    call _init_zombie_controller

    # Spawning 1 zombie
    movia r4, ZOMBIE_ARRAY
    movia r5, 0x000A000A
    call _spawn_zombie

    # Spawn another zombie
    movia r4, ZOMBIE_ARRAY
    movia r5, 0x00640032
    call _spawn_zombie

    movia r4, ZOMBIE_ARRAY
    movia r5, 0x00C80064
    call _spawn_zombie

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

/* Creates a zombie at the given address
 * r4: the address to init the zombie
 * r5: xy position
 */
.global _make_zombie
_make_zombie:
    addi sp, sp, -16
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)     # Prologue

    mov r17, r4

    stw r5, 0(r17)                      # Starting position

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

        ldh r16, 0(r18)     # Does the move
        addi r16, r16, 1    #numbers of pixels to move in one step

        movi r19, 0xA0          #if Zombie poition greater 
        bge r16, r19, attack   #than this it is doing damage

        sth r16, 0(r18)         #stores half word so it doesn't touch x pos
        br UPDATE_ZOMBIE_RETURN    

    inc_move_counter:
        ldw r17, 20(r18)    # increments the counter
        sub r16, r16, r17
        stw r16, 16(r18)
        br UPDATE_ZOMBIE_RETURN
        
    attack:
        sth r19, 0(r18)             #sets y postition to lowest zombie postiton
        movia r18, PLAYER_HEALTH
        ldw r19, 0(r18)
        subi r19, r19, 1           #does 10 damage every attack
        stw r19, 0(r18)

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
    movi r5, 56
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

/* Checks if the gun is pointed at the zombie
 * r4: zombie object pointer
 */
.global _check_zombie_hit
_check_zombie_hit:
	addi sp, sp, -16			# Prologue  
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)

    mov r18, r4                 # Save the pointer

    mov r4, r0                  # Fills the screen black
    call FillColour     

    mov r4, r18
    call _draw_zombie_hitbox 

    call swapBuffers
	call waitForBufferWrite

    movia r16, FLASH_DELAY
    delay:
        addi r16, r16, -1
        bgt r16, r0, delay

    # TODO: make a gpio driver for easy function calls
    movia r16, GPIO 		    # Get data from sensor PIN 2 (D1)
    ldwio r17, 0(r16)
    srli r17, r17, 1
    andi r17, r17, 0x01 			

    beq r17, r0, KILL_ZOMBIE
    br CHECK_ZOMBIE_HITS_RETURN

    KILL_ZOMBIE:
        movia r16, ZOMBIE_DIE_AS
        stw r16, 28(r18)


CHECK_ZOMBIE_HITS_RETURN:
	ldw ra, 0(sp)			#Epilogue
    ldw r16, 4(sp)
    ldw r17, 8(sp)	
    ldw r18, 12(sp)		
    addi sp, sp, 16
    ret
