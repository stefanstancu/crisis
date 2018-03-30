.equ GPIO, 0xFF200060
.equ LED, 0xFF200000

.global _start
_start:
	addi sp, sp, 4000	/* moves stack pointer to allow room for program*/

	movi r16, 0x00 		/* sets direction of GPIO pin D0 to input*/
	movia r19, GPIO1
	stwio r16, 4(r19)

	movi r16, 0x01 		/*enables interrupts on pin 1 (D0)*/
	stwio r16, 8(r19)

	movi r16, 0x400		/* enables interrupts on IRQ line 11*/
	wrctl ctl3, r16 

	movi r16, 0x01  	/* enables global interrupts */
	wrctl ctl0, r16				
	
	movia r16, LED		/* turns Leds off*/
	stwio r0, 0(r16)

	LOOP:
		br LOOP


.section .exceptions, "ax"
my_handler: