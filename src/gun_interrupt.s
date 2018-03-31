.equ GPIO, 0xFF200060
.equ LED, 0xFF200000
.equ TIMER, 0xFF202000 

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
	addi sp, sp, -16		#creates space on stack and saves return address and r16
	stwio r16, 0(sp)
	stwio ra, 4(sp)
	stwio r17, 8(sp)
	stwio r18, 12(sp)
				
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
	movi r16, 0x3FF 	#stores all 1's into LEDS memory location
	movia et, LED
	stwio r16, 0(et)
	movi r16, 0x00 		#initializes values for the delay loop
	movia et, 1000000 	
	br DELAY

LED_OFF:
	movi r16, 0x00 		#stores all 0's into LEDS memory location
	movia et, LED
	stwio r16, 0(et)
	movi r16, 0x00 		#initializes values for the delay loop
	movia et, 1000000 	
	br DELAY

DELAY:
	addi r16, r16, 0x01 	#loops until r16 == et then returns
	beq r16, et, RETURN 	#this loop is to prevent two interrupts coming from same trigger pull
	br DELAY
/*DELAY:
	movia r17, TIMER	#sets the period of the timer to be 100000
	movia r18, 1000000  
	stwio r18, 8(r17)
	stwio r0, 12(r17)

	movui r18, 4		#starts the timer without continuing or interrupts
	stwio r18, 4(r17)
WAIT:
	ldwio r18, 0(r17)	#keeps checking clock value until it has timed out
	andi r18, r18, 0x01
	beq r18, r0, WAIT
	br RETURN
*/
RETURN:
	ldwio r16, 0(sp)	# recovers correct value for registers, return address and stack pointer 
	ldwio ra, 4(sp)
	ldwio r17, 8(sp)
	ldwio r18, 12(sp)
	addi sp, sp, 16

	addi ea, ea, -4  	
	eret
