.equ GPIO, 0xFF200060
.equ LED, 0xFF200000
.equ TIMER, 0xFF202000 
.equ TIGGER_DELAY, 50000000 

# PIN 1 (D0) is trigger data
# PIN 2 (D1) is sensor data


.global _init_interrupts
_init_interrupts:
	addi sp, sp, -12		# moves stack pointer to allow room for program
    stw ra, 0(sp)	
    stw r16, 4(sp)
    stw r19, 8(sp)
	
	#movi r12, 0x00 		# r12 is counter for how many shots fired

	movi r16, 0x00 		#sets direction of GPIO pin D0 to input
	movia r19, GPIO
	stwio r16, 4(r19)

	movi r16, 0x01 		#enables interrupts on pin 1 (D0)
	stwio r16, 8(r19)

	movi r16, 0x801		#enables interrupts on IRQ line 11
	wrctl ctl3, r16 

	movi r16, 0x01  	# enables global interrupts 
	wrctl ctl0, r16				

	movia r19, TIMER
	movia r16, %lo(TIGGER_DELAY)
	stwio r16, 8(r19)
	movia r16, %hi(TIGGER_DELAY)
	stwio r16, 12(r19)

	ldw ra, 0(sp)
	ldw r16, 4(sp)
	ldw r19, 8(sp)
	addi sp, sp, 12
	ret

.section .exceptions, "ax"
my_handler:
	addi sp, sp, -16		#creates space on stack and saves return address and registers
	stwio r16, 0(sp)
	stwio ra, 4(sp)
	stwio r17, 8(sp)
	stwio r18, 12(sp)
				
	rdctl r16, ctl4		#check which device caused interrupt
	andi r17, r16, 0x01
	bgt r17, r0, TRIGGER_RESET
	andi r17, r16, 0x800
	bgt r17, r0, TRIGGER_PULL

TRIGGER_PULL:
	movia r17, TIMER 		#starts timer 
	movi r16, 0x05
	stwio r16, 4(r17)

	call _anti_cheat
	movia r16, 0xFFFFFFFF	#writes 0 to acknowledge bit for GPIO pins
	movia et, GPIO 		
	stwio r16, 12(et)
	br HANDLER_RETURN	

TRIGGER_RESET:
	rdctl r16, ctl3 		#enables trigger interrupts after timer goes off
	ori r16, r16, 0x800
	wrctl r16, ctl3

	movia r17, TIMER 		#acknowledges timer interrupt
	stwio r0, 0(r17)
	br HANDLER_RETURN
	
HANDLER_RETURN:
	ldwio r16, 0(sp)	# recovers correct value for registers, return address and stack pointer 
	ldwio ra, 4(sp)
	ldwio r17, 8(sp)
	ldwio r18, 12(sp)
	addi sp, sp, 16

	addi ea, ea, -4  	
	eret
