.equ WIDTH, 320
.equ HEIGHT, 240
.equ LOG2_BYTES_PER_ROW, 10
.equ LOG2_BYTES_PER_PIXEL, 1

# 160x120, 256 bytes/row, 1 byte per pixel: DE10-Lite
#.equ WIDTH, 160
#.equ HEIGHT, 120
#.equ LOG2_BYTES_PER_ROW, 8
#.equ LOG2_BYTES_PER_PIXEL, 0
# 128 bytes/row, 1 byte per pixel: DE0
#.equ WIDTH, 80
#.equ HEIGHT, 60
#.equ LOG2_BYTES_PER_ROW, 7
#.equ LOG2_BYTES_PER_PIXEL, 0

.equ PIXBUF, 0x08000000		# Pixel buffer. Same on all boards.
.equ CHARBUF, 0x09000000	# Character buffer. Same on all boards.

.data
    SPRITE:
        .incbin "../res/charles.bin"

.text

.global _start
_start:
	movia sp, 0x800000		# Initial stack pointer
	
    LOOP:
        movia r4, 0x0
        call FillColour			# Fill screen with a colour

        movia r4, SPRITE
        movi r5, 40
        movi r6, 40
        call DrawImage

        br LOOP
    # end LOOP

# r4: address
# r5: width
# r6: height
# r7: x position
# r8: y position
DrawImage:
	subi sp, sp, 28
    stw r16, 0(sp)  # width counter
    stw r17, 4(sp)  # height counter
    stw r18, 8(sp)  # color value
    stw r19, 12(sp) # address value
    stw r20, 16(sp) # width total
    stw r21, 20(sp) # height total
    stw ra, 24(sp)

    mov r19, r4                 # init address counter
    mov r20, r5                 # init width
    mov r21, r6                 # init height

	addi r17, r21, -1                 # init height counter
    1:	addi r16, r20, -1             # init width counter
         2: ldh r18, 0(r19)     # load pixel value and increment
            addi r19, r19, 2

            mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel		# Draw one pixel

            addi r16, r16, -1
            bge r16, r0, 2b     # if row is not over

        addi r17, r17, -1
        bge r17, r0, 1b         # if columns not over (i.e. image)

   	ldw ra, 24(sp)				# Epilogue
    ldw r21, 20(sp)
    ldw r20, 16(sp)
    ldw r19, 12(sp)
	ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)    
    addi sp, sp, 20
    ret

# r4: colour
FillColour:
	subi sp, sp, 16
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw ra, 12(sp)			/* Prologue */
    
    mov r18, r4
    						# Two loops to draw each pixel
    movi r16, WIDTH-1
    1:	movi r17, HEIGHT-1
        2:  mov r4, r16
            mov r5, r17
            mov r6, r18
            call WritePixel		# Draw one pixel
            subi r17, r17, 1
            bge r17, r0, 2b
        subi r16, r16, 1
        bge r16, r0, 1b
    
    ldw ra, 12(sp)				/* Epilogue */
	ldw r18, 8(sp)
    ldw r17, 4(sp)
    ldw r16, 0(sp)    
    addi sp, sp, 16
    ret

# r4: col
# r5: row
# r6: character
WriteChar:
	slli r5, r5, 7
    add r5, r5, r4
    movia r4, CHARBUF
    add r5, r5, r4
    stbio r6, 0(r5)
    ret

# r4: col (x)
# r5: row (y)
# r6: colour value
WritePixel:
	movi r2, LOG2_BYTES_PER_ROW		# log2(bytes per row)
    movi r3, LOG2_BYTES_PER_PIXEL	# log2(bytes per pixel)
    
    sll r5, r5, r2
    sll r4, r4, r3
    add r5, r5, r4
    movia r4, PIXBUF
    add r5, r5, r4
    
    bne r3, r0, 1f					# 8bpp or 16bpp?
  	stbio r6, 0(r5)					# Write 8-bit pixel
    ret
    
1:	sthio r6, 0(r5)					# Write 16-bit pixel
	ret

