.global _init
_init:
	movia sp, 0x800000		# Initial stack pointer

    call _init_graphics

    ret
