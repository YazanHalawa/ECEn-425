; Generated by c86 (BYU-NASM) 5.1 (beta) from myinth.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
reset_inth:
	; >>>>> Line:	16
	; >>>>> { 
	jmp	L_myinth_1
L_myinth_2:
	; >>>>> Line:	17
	; >>>>> exit(0); 
	xor	al, al
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
	ALIGN	2
mytick:
	; >>>>> Line:	21
	; >>>>> { 
	jmp	L_myinth_4
L_myinth_5:
	; >>>>> Line:	32
	; >>>>> }	        
	mov	sp, bp
	pop	bp
	ret
L_myinth_4:
	push	bp
	mov	bp, sp
	jmp	L_myinth_5
L_myinth_8:
	DB	") IGNORED",0xA,0
L_myinth_7:
	DB	0xA,"KEYPRESS (",0
	ALIGN	2
keyboard_inth:
	; >>>>> Line:	36
	; >>>>> { 
	jmp	L_myinth_9
L_myinth_10:
	; >>>>> Line:	38
	; >>>>> c = KeyBuffer; 
	mov	al, byte [KeyBuffer]
	mov	byte [bp-1], al
	; >>>>> Line:	40
	; >>>>> if(c == 'a') YKEventSet(charEvent, 0x1); 
	cmp	byte [bp-1], 97
	jne	L_myinth_11
	; >>>>> Line:	40
	; >>>>> if(c == 'a') YKEventSet(charEvent, 0x1); 
	mov	ax, 1
	push	ax
	push	word [charEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_12
L_myinth_11:
	; >>>>> Line:	41
	; >>>>> else if(c == 'b') YKEventSet(charEvent, 0x2); 
	cmp	byte [bp-1], 98
	jne	L_myinth_13
	; >>>>> Line:	41
	; >>>>> else if(c == 'b') YKEventSet(charEvent, 0x2); 
	mov	ax, 2
	push	ax
	push	word [charEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_14
L_myinth_13:
	; >>>>> Line:	42
	; >>>>> else if(c == 'c') YKEventSet(charEvent, 0x4); 
	cmp	byte [bp-1], 99
	jne	L_myinth_15
	; >>>>> Line:	42
	; >>>>> else if(c == 'c') YKEventSet(charEvent, 0x4); 
	mov	ax, 4
	push	ax
	push	word [charEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_16
L_myinth_15:
	; >>>>> Line:	43
	; >>>>> else if(c == 'd') YKEventSet(charEvent, 0x1 | 0x2 | 0x4); 
	cmp	byte [bp-1], 100
	jne	L_myinth_17
	; >>>>> Line:	43
	; >>>>> else if(c == 'd') YKEventSet(charEvent, 0x1 | 0x2 | 0x4); 
	mov	ax, 7
	push	ax
	push	word [charEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_18
L_myinth_17:
	; >>>>> Line:	44
	; >>>>> else if(c == '1') YKEventSet(numEvent, 0x1); 
	cmp	byte [bp-1], 49
	jne	L_myinth_19
	; >>>>> Line:	44
	; >>>>> else if(c == '1') YKEventSet(numEvent, 0x1); 
	mov	ax, 1
	push	ax
	push	word [numEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_20
L_myinth_19:
	; >>>>> Line:	45
	; >>>>> else if(c == '2') YKEventSet(numEvent, 0x2); 
	cmp	byte [bp-1], 50
	jne	L_myinth_21
	; >>>>> Line:	45
	; >>>>> else if(c == '2') YKEventSet(numEvent, 0x2); 
	mov	ax, 2
	push	ax
	push	word [numEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_22
L_myinth_21:
	; >>>>> Line:	46
	; >>>>> else if(c == '3') YKEventSet(numEvent, 0x4); 
	cmp	byte [bp-1], 51
	jne	L_myinth_23
	; >>>>> Line:	46
	; >>>>> else if(c == '3') YKEventSet(numEvent, 0x4); 
	mov	ax, 4
	push	ax
	push	word [numEvent]
	call	YKEventSet
	add	sp, 4
	jmp	L_myinth_24
L_myinth_23:
	; >>>>> Line:	48
	; >>>>> print("\nKEYPRESS (", 11); 
	mov	ax, 11
	push	ax
	mov	ax, L_myinth_7
	push	ax
	call	print
	add	sp, 4
	; >>>>> Line:	49
	; >>>>> printChar(c); 
	push	word [bp-1]
	call	printChar
	add	sp, 2
	; >>>>> Line:	50
	; >>>>> print(") IGNORED\n",  
	mov	ax, 10
	push	ax
	mov	ax, L_myinth_8
	push	ax
	call	print
	add	sp, 4
L_myinth_24:
L_myinth_22:
L_myinth_20:
L_myinth_18:
L_myinth_16:
L_myinth_14:
L_myinth_12:
	mov	sp, bp
	pop	bp
	ret
L_myinth_9:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_myinth_10
