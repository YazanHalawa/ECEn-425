; Generated by c86 (BYU-NASM) 5.1 (beta) from myinth.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
reset_inth:
	; >>>>> Line:	5
	; >>>>> void reset_inth() { 
	jmp	L_myinth_1
L_myinth_2:
	; >>>>> Line:	6
	; >>>>> exit(0xff); 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_myinth_1:
	push	bp
	mov	bp, sp
	jmp	L_myinth_2
L_myinth_7:
	DB	"DELAY COMPLETE",0
L_myinth_6:
	DB	"DELAY KEY PRESSED",0
L_myinth_5:
	DB	") IGNORED",0
L_myinth_4:
	DB	"KEPYRESS (",0
	ALIGN	2
keyboard_inth:
	; >>>>> Line:	9
	; >>>>> void keyboard_inth() { 
	jmp	L_myinth_8
L_myinth_9:
	; >>>>> Line:	11
	; >>>>> if (KeyBuffer != 'd') { 
	mov	word [bp-2], 0
	; >>>>> Line:	11
	; >>>>> if (KeyBuffer != 'd') { 
	cmp	word [KeyBuffer], 100
	je	L_myinth_10
	; >>>>> Line:	12
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	13
	; >>>>> printString("KEPYRESS ("); 
	mov	ax, L_myinth_4
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	14
	; >>>>> printChar(KeyBuffer); 
	push	word [KeyBuffer]
	call	printChar
	add	sp, 2
	; >>>>> Line:	15
	; >>>>> printString(") IGNORED"); 
	mov	ax, L_myinth_5
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	16
	; >>>>> printNewLine(); 
	call	printNewLine
	jmp	L_myinth_11
L_myinth_10:
	; >>>>> Line:	18
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	19
	; >>>>> printString("DELAY KEY PRESSED"); 
	mov	ax, L_myinth_6
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	20
	; >>>>> printNewLine(); 
	call	printNewLine
	; >>>>> Line:	21
	; >>>>> while (delayCounter <= 5000) { 
	jmp	L_myinth_13
L_myinth_12:
	; >>>>> Line:	22
	; >>>>> delayCounter++; 
	inc	word [bp-2]
L_myinth_13:
	cmp	word [bp-2], 5000
	jle	L_myinth_12
L_myinth_14:
	; >>>>> Line:	24
	; >>>>> printString("DELAY COMPLETE" 
	mov	ax, L_myinth_7
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	25
	; >>>>> printNewLine(); 
	call	printNewLine
L_myinth_11:
	mov	sp, bp
	pop	bp
	ret
L_myinth_8:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_myinth_9
