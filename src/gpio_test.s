.equ GPIO, 0xFF200060
.equ LED, 0xFF200000

.global _start
_start:
	movia r8, LED

	movia r7, GPIO			/* set D0 to input, set D1 to output */
	movi r6, 0x02
	stwio r6, 4(r7)
	
	LOOP:
		ldwio r6, 0(r7)		/* Read value from pins */
		stwio r6, 0(r8)
		br LOOP