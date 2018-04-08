.global GPIO
.equ GPIO, 0xFF200070
.equ LED, 0xFF200000
.equ TIMER, 0xFF202000 
.equ TRIGGER_DELAY, 25000000

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

	movi r16, (1<<12) | (1)		#enables interrupts on IRQ line 12
	wrctl ctl3, r16 

	movi r16, 0x01  	# enables global interrupts 
	wrctl ctl0, r16				

	movia r19, TIMER
	movi r16, %lo(TRIGGER_DELAY)
	stwio r16, 8(r19)
	movi r16, %hi(TRIGGER_DELAY)
	stwio r16, 12(r19)

	ldw ra, 0(sp)
	ldw r16, 4(sp)
	ldw r19, 8(sp)
	addi sp, sp, 12
	ret

.section .exceptions, "ax"
my_handler:
	addi sp, sp, -32		#creates space on stack and saves return address and registers
	stw r16, 0(sp)
	stw ra, 4(sp)
	stw r17, 8(sp)
	stw r18, 12(sp)
    stw r4, 16(sp)
    stw r5, 20(sp)
    stw r6, 24(sp)
    stw r7, 28(sp)
				
	rdctl r16, ctl4		#check which device caused interrupt
	andi r17, r16, 0x01
	bgt r17, r0, TRIGGER_RESET
	andi r17, r16, (1<<12)
	bgt r17, r0, TRIGGER_PULL

TRIGGER_PULL:

    movia r17, GAME_STATE
    ldw r16, 0(r17)
    ble r16, r0, START_GAME

    movi r17, 3
    bge r16, r17, END_GAME_RESET

	rdctl r16, ctl3
	movia r17, ~(1<<12) 
	and r16, r16, r17
	wrctl ctl3, r16			# mask the IRQ Line 12 (off)

	call _anti_cheat

	movia r17, TIMER 		#starts timer 
	movi r16, 0x05
	stwio r16, 4(r17)

	br HANDLER_RETURN	

TRIGGER_RESET:
	movia r17, TIMER 		#acknowledges timer interrupt
	stwio r0, 0(r17)

	movia r16, 0xFFFFFFFF	#writes 0 to acknowledge bit for GPIO pins
	movia et, GPIO 		
	stwio r16, 12(et)
	
	rdctl r16, ctl3 		#enables trigger interrupts after timer goes off
	ori r16, r16, (1<<12)
	wrctl ctl3, r16
	
	movi r16, 0x08			# Stop the timer
	stwio r16, 4(r17)

	br HANDLER_RETURN
	
START_GAME:
    addi r16, r16, 1
    stw r16, 0(r17)

	movia r16, 0xFFFFFFFF	#writes 0 to acknowledge bit for GPIO pins
	movia et, GPIO 		
	stwio r16, 12(et)

    br HANDLER_RETURN

END_GAME_RESET:
	call _init
	br HANDLER_RETURN


HANDLER_RETURN:
	ldw r16, 0(sp)	# recovers correct value for registers, return address and stack pointer 
	ldw ra, 4(sp)
	ldw r17, 8(sp)
	ldw r18, 12(sp)
    ldw r4,16(sp)
    ldw r5,20(sp)
    ldw r6,24(sp)
    ldw r7,28(sp)
	addi sp, sp, 32

	addi ea, ea, -4  	
	eret
