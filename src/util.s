.global _init
_init:
	movia sp, 0x800000		# Initial stack pointer
    addi sp, sp, -4
    stw ra, 0(sp)

    call _init_graphics
    call _init_zombies
    call _init_interrupts

    ldw ra, 0(sp)
    addi sp, sp, 4

    ret
