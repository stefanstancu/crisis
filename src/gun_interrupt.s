.equ GPIO, 0xFF200060
.equ LED, 0xFF200000

.global _start
_start:
	addi sp, sp, 4000	# moves stack pointer to allow room for program

	movi r16, 0x00 		#sets direction of GPIO pin D0 to input
	movia r19, GPIO
	stwio r16, 4(r19)

	movi r16, 0x01 		#enables interrupts on pin 1 (D0)
	stwio r16, 8(r19)

	movi r16, 0x800		#enables interrupts on IRQ line 11
	wrctl ctl3, r16 

	movi r16, 0x01  	# enables global interrupts 
	wrctl ctl0, r16				
	
	movia r16, LED		# turns Leds off
	stwio r0, 0(r16)
	LOOP:
		br LOOP


.section .exceptions, "ax"
my_handler:
	addi sp, sp, -8		#creates space on stack and saves return address and r16
	stwio r16, 0(sp)
	stwio ra, 4(sp)
				
	movia r16, 0xFFFFFFFF		
	movia et, GPIO 		#writes 0 to acknowledge bit for GPIO pins
	stwio r16, 12(et)


	movia r16, LED 		#reads data from LEDS
	ldwio et, 0(r16)
	andi et, et, 0x03FF 	#gets rid of all the dont care bits
	movi r16, 0x3FF

	beq et, r0, LED_ON			#if LEDS are off turn them on
	beq et, r16, LED_OFF		#if LEDS are on turn them off

LED_ON:
	movi r16, 0x3FF 	
	movia et, LED
	stwio r16, 0(et)
	br RETURN

LED_OFF:
	movi r16, 0x00
	movia et, LED
	stwio r16, 0(et)
	br RETURN

RETURN:
	ldwio r16, 0(sp)	# recovers correct value for r16, return address and stack pointer 
	ldwio ra, 4(sp)
	addi sp, sp, 8	

	addi ea, ea, -4  	
	eret
