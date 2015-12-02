; Generated by c86 (BYU-NASM) 5.1 (beta) from lab8app.i
	CPU	8086
	ALIGN	2
	jmp	main	; Jump to program start
	ALIGN	2
setReceivedCommand_handler:
	; >>>>> Line:	72
	; >>>>> void setReceivedCommand_handler(void){ 
	jmp	L_lab8app_1
L_lab8app_2:
	; >>>>> Line:	73
	; >>>>> YKSemPost(nextCommandPtr); 
	push	word [nextCommandPtr]
	call	YKSemPost
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_lab8app_1:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_2
L_lab8app_4:
	DB	"not enough pieces",0xD,0xA,0
	ALIGN	2
gotNewPiece_handler:
	; >>>>> Line:	76
	; >>>>> void gotNewPiece_handler(void){ 
	jmp	L_lab8app_5
L_lab8app_6:
	; >>>>> Line:	77
	; >>>>> if (availablePieces <= 0){ 
	cmp	word [availablePieces], 0
	jg	L_lab8app_7
	; >>>>> Line:	78
	; >>>>> printString("not enough pieces\r\n"); 
	mov	ax, L_lab8app_4
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	79
	; >>>>> exit (0xff); 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
L_lab8app_7:
	; >>>>> Line:	81
	; >>>>> availablePieces--; 
	dec	word [availablePieces]
	; >>>>> Line:	82
	; >>>>> pieces[availablePieces].id = NewPieceID; 
	mov	ax, word [availablePieces]
	mov	cx, 3
	shl	ax, cl
	mov	si, ax
	add	si, pieces
	mov	ax, word [NewPieceID]
	mov	word [si], ax
	; >>>>> Line:	83
	; >>>>> pieces[availablePieces].type = NewPieceType; 
	mov	ax, word [availablePieces]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 2
	mov	ax, word [NewPieceType]
	mov	word [si], ax
	; >>>>> Line:	84
	; >>>>> pieces[availablePieces].orientation = NewPieceOrientation; 
	mov	ax, word [availablePieces]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 4
	mov	ax, word [NewPieceOrientation]
	mov	word [si], ax
	; >>>>> Line:	85
	; >>>>> pieces[availablePiec 
	mov	ax, word [availablePieces]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	mov	si, ax
	add	si, 6
	mov	ax, word [NewPieceColumn]
	mov	word [si], ax
	; >>>>> Line:	87
	; >>>>> YKQPost(pieceQPtr, (void*) &(pieces[availablePieces])); 
	mov	ax, word [availablePieces]
	mov	cx, 3
	shl	ax, cl
	add	ax, pieces
	push	ax
	push	word [pieceQPtr]
	call	YKQPost
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_lab8app_5:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_6
L_lab8app_9:
	DB	"GAME OVER!",0
	ALIGN	2
setGameOver:
	; >>>>> Line:	90
	; >>>>> void setGameOver(void){ 
	jmp	L_lab8app_10
L_lab8app_11:
	; >>>>> Line:	91
	; >>>>> printString("GAME OVER!"); 
	mov	ax, L_lab8app_9
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	92
	; >>>>> exit(0xff); 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
	mov	sp, bp
	pop	bp
	ret
L_lab8app_10:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_11
L_lab8app_13:
	DB	"not enough moves",0xD,0xA,0
	ALIGN	2
createMove:
	; >>>>> Line:	97
	; >>>>> void createMove(unsigned idOfPiece, int action){ 
	jmp	L_lab8app_14
L_lab8app_15:
	; >>>>> Line:	98
	; >>>>> if (availableMoves <= 0){ 
	cmp	word [availableMoves], 0
	jg	L_lab8app_16
	; >>>>> Line:	99
	; >>>>> printString("not enough moves\r\n"); 
	mov	ax, L_lab8app_13
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	100
	; >>>>> exit(0xff); 
	mov	al, 255
	push	ax
	call	exit
	add	sp, 2
L_lab8app_16:
	; >>>>> Line:	102
	; >>>>> availableMoves--; 
	dec	word [availableMoves]
	; >>>>> Line:	103
	; >>>>> moves[availableMoves].idOfPiece = idOfPiece; 
	mov	ax, word [availableMoves]
	shl	ax, 1
	shl	ax, 1
	add	ax, moves
	mov	si, ax
	add	si, 2
	mov	ax, word [bp+4]
	mov	word [si], ax
	; >>>>> Line:	104
	; >>>>> moves[availableMoves].action = action; 
	mov	ax, word [availableMoves]
	shl	ax, 1
	shl	ax, 1
	mov	si, ax
	add	si, moves
	mov	ax, word [bp+6]
	mov	word [si], ax
	; >>>>> Line:	106
	; >>>>> YKQPost(moveQPtr, (void*) &(moves[availableMoves])); 
	mov	ax, word [availableMoves]
	shl	ax, 1
	shl	ax, 1
	add	ax, moves
	push	ax
	push	word [moveQPtr]
	call	YKQPost
	add	sp, 4
	mov	sp, bp
	pop	bp
	ret
L_lab8app_14:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_15
	ALIGN	2
placementTask:
	; >>>>> Line:	111
	; >>>>> Ptr); 
	jmp	L_lab8app_18
L_lab8app_19:
	; >>>>> Line:	114
	; >>>>> while(1){ 
	jmp	L_lab8app_21
L_lab8app_20:
	; >>>>> Line:	115
	; >>>>> temp = (PIECE*)YKQPend(pieceQPtr);  
	push	word [pieceQPtr]
	call	YKQPend
	add	sp, 2
	mov	word [bp-2], ax
	; >>>>> Line:	116
	; >>>>> availablePieces++; 
	inc	word [availablePieces]
	; >>>>> Line:	119
	; >>>>> id = temp->id; 
	mov	si, word [bp-2]
	mov	ax, word [si]
	mov	word [bp-4], ax
	; >>>>> Line:	120
	; >>>>> type = temp->type; 
	mov	si, word [bp-2]
	add	si, 2
	mov	ax, word [si]
	mov	word [bp-10], ax
	; >>>>> Line:	121
	; >>>>> orient = temp->orientation; 
	mov	si, word [bp-2]
	add	si, 4
	mov	ax, word [si]
	mov	word [bp-8], ax
	; >>>>> Line:	122
	; >>>>> col = temp->column; 
	mov	si, word [bp-2]
	add	si, 6
	mov	ax, word [si]
	mov	word [bp-6], ax
	; >>>>> Line:	125
	; >>>>> if (type == 0){ 
	mov	ax, word [bp-10]
	test	ax, ax
	jne	L_lab8app_23
	; >>>>> Line:	126
	; >>>>> createMove(id, 0); 
	xor	ax, ax
	push	ax
	push	word [bp-4]
	call	createMove
	add	sp, 4
	jmp	L_lab8app_24
L_lab8app_23:
	; >>>>> Line:	129
	; >>>>> createMove(id, 1); 
	mov	ax, 1
	push	ax
	push	word [bp-4]
	call	createMove
	add	sp, 4
L_lab8app_24:
L_lab8app_21:
	jmp	L_lab8app_20
L_lab8app_22:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_18:
	push	bp
	mov	bp, sp
	sub	sp, 10
	jmp	L_lab8app_19
	ALIGN	2
communicationTask:
	; >>>>> Line:	134
	; >>>>> void communicationTask(void){  
	jmp	L_lab8app_26
L_lab8app_27:
	; >>>>> Line:	136
	; >>>>> while(1){ 
	jmp	L_lab8app_29
L_lab8app_28:
	; >>>>> Line:	137
	; >>>>> YKSemPend(nextCommandPtr); 
	push	word [nextCommandPtr]
	call	YKSemPend
	add	sp, 2
	; >>>>> Line:	138
	; >>>>>  
	push	word [moveQPtr]
	call	YKQPend
	add	sp, 2
	mov	word [bp-2], ax
	; >>>>> Line:	139
	; >>>>> availableMoves++; 
	inc	word [availableMoves]
	; >>>>> Line:	142
	; >>>>> if (temp->action == 0){ 
	mov	si, word [bp-2]
	mov	ax, word [si]
	test	ax, ax
	jne	L_lab8app_31
	; >>>>> Line:	143
	; >>>>> SlidePiece(temp->idOfPiece, 0); 
	xor	ax, ax
	push	ax
	add	si, 2
	push	word [si]
	call	SlidePiece
	add	sp, 4
	jmp	L_lab8app_32
L_lab8app_31:
	; >>>>> Line:	144
	; >>>>> } else if (temp->action == 1){ 
	mov	si, word [bp-2]
	cmp	word [si], 1
	jne	L_lab8app_33
	; >>>>> Line:	145
	; >>>>> SlidePiece(temp->idOfPiece, 1); 
	mov	ax, 1
	push	ax
	add	si, 2
	push	word [si]
	call	SlidePiece
	add	sp, 4
	jmp	L_lab8app_34
L_lab8app_33:
	; >>>>> Line:	146
	; >>>>> } else if (temp->action == 2){ 
	mov	si, word [bp-2]
	cmp	word [si], 2
	jne	L_lab8app_35
	; >>>>> Line:	147
	; >>>>> RotatePiece(temp->idOfPiece, 1); 
	mov	ax, 1
	push	ax
	add	si, 2
	push	word [si]
	call	RotatePiece
	add	sp, 4
	jmp	L_lab8app_36
L_lab8app_35:
	; >>>>> Line:	149
	; >>>>> RotatePiece(temp->idOfPiece, 0); 
	xor	ax, ax
	push	ax
	mov	si, word [bp-2]
	add	si, 2
	push	word [si]
	call	RotatePiece
	add	sp, 4
L_lab8app_36:
L_lab8app_34:
L_lab8app_32:
L_lab8app_29:
	jmp	L_lab8app_28
L_lab8app_30:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_26:
	push	bp
	mov	bp, sp
	push	cx
	jmp	L_lab8app_27
L_lab8app_42:
	DB	"% >",0xD,0xA,0
L_lab8app_41:
	DB	", CPU: ",0
L_lab8app_40:
	DB	"<CS: ",0
L_lab8app_39:
	DB	"Determining CPU capacity",0xD,0xA,0
L_lab8app_38:
	DB	"Welcome to the YAK kernel",0xD,0xA,0
	ALIGN	2
statisticsTask:
	; >>>>> Line:	154
	; >>>>> void statisticsTask(void){  
	jmp	L_lab8app_43
L_lab8app_44:
	; >>>>> Line:	158
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	159
	; >>>>> dleCount = YKIdleCount 
	mov	ax, L_lab8app_38
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	160
	; >>>>> printString("Determining CPU capacity\r\n"); 
	mov	ax, L_lab8app_39
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	161
	; >>>>> YKDelayTask(1); 
	mov	ax, 1
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	162
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	163
	; >>>>> YKDelayTask(5); 
	mov	ax, 5
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	164
	; >>>>> max = YKIdleCount / 25; 
	mov	ax, word [YKIdleCount]
	xor	dx, dx
	mov	cx, 25
	div	cx
	mov	word [bp-4], ax
	; >>>>> Line:	165
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	168
	; >>>>> SeedSimptris(37428L); 
	mov	ax, 37428
	xor	dx, dx
	push	dx
	push	ax
	call	SeedSimptris
	add	sp, 4
	; >>>>> Line:	169
	; >>>>> StartSimptris(); 
	call	StartSimptris
	; >>>>> Line:	172
	; >>>>> YKNewTask(placement, (void*) &placement[512], 1); 
	mov	al, 1
	push	ax
	mov	ax, (placement+1024)
	push	ax
	mov	ax, placement
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	173
	; >>>>> YKNewTask(communication, (void*) &communication[512], 2); 
	mov	al, 2
	push	ax
	mov	ax, (communication+1024)
	push	ax
	mov	ax, communication
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	175
	; >>>>> while(1){ 
	jmp	L_lab8app_46
L_lab8app_45:
	; >>>>> Line:	177
	; >>>>> YKDelayTask(20); 
	mov	ax, 20
	push	ax
	call	YKDelayTask
	add	sp, 2
	; >>>>> Line:	179
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	180
	; >>>>> switchCount = YKCtxSwCount; 
	mov	ax, word [YKCtxSwCount]
	mov	word [bp-6], ax
	; >>>>> Line:	181
	; >>>>> idleCount = YKIdleCount 
	mov	ax, word [YKIdleCount]
	mov	word [bp-2], ax
	; >>>>> Line:	182
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
	; >>>>> Line:	184
	; >>>>> printString("<CS: "); 
	mov	ax, L_lab8app_40
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	185
	; >>>>> printInt((int)switchCount); 
	push	word [bp-6]
	call	printInt
	add	sp, 2
	; >>>>> Line:	186
	; >>>>> printString(", CPU: "); 
	mov	ax, L_lab8app_41
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	187
	; >>>>> tmp = (int) (idleCount/max); 
	mov	ax, word [bp-2]
	xor	dx, dx
	div	word [bp-4]
	mov	word [bp-8], ax
	; >>>>> Line:	188
	; >>>>> printInt(100-tmp); 
	mov	ax, 100
	sub	ax, word [bp-8]
	push	ax
	call	printInt
	add	sp, 2
	; >>>>> Line:	189
	; >>>>> printString("% >\r\n"); 
	mov	ax, L_lab8app_42
	push	ax
	call	printString
	add	sp, 2
	; >>>>> Line:	191
	; >>>>> YKEnterMutex(); 
	call	YKEnterMutex
	; >>>>> Line:	192
	; >>>>> YKCtxSwCount = 0; 
	mov	word [YKCtxSwCount], 0
	; >>>>> Line:	193
	; >>>>> YKIdleCount = 0; 
	mov	word [YKIdleCount], 0
	; >>>>> Line:	194
	; >>>>> YKExitMutex(); 
	call	YKExitMutex
L_lab8app_46:
	jmp	L_lab8app_45
L_lab8app_47:
	mov	sp, bp
	pop	bp
	ret
L_lab8app_43:
	push	bp
	mov	bp, sp
	sub	sp, 8
	jmp	L_lab8app_44
	ALIGN	2
main:
	; >>>>> Line:	203
	; >>>>> { 
	jmp	L_lab8app_49
L_lab8app_50:
	; >>>>> Line:	204
	; >>>>> YKInitialize(); 
	call	YKInitialize
	; >>>>> Line:	207
	; >>>>> YKNewTask(statisticsTask, (void *) &statistics[512], 0); 
	xor	al, al
	push	ax
	mov	ax, (statistics+1024)
	push	ax
	mov	ax, statisticsTask
	push	ax
	call	YKNewTask
	add	sp, 6
	; >>>>> Line:	208
	; >>>>> nextCommandPtr = YKSemCreate(0); 
	xor	ax, ax
	push	ax
	call	YKSemCreate
	add	sp, 2
	mov	word [nextCommandPtr], ax
	; >>>>> Line:	209
	; >>>>> pieceQPtr = YK 
	mov	ax, 10
	push	ax
	mov	ax, pieceQ
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [pieceQPtr], ax
	; >>>>> Line:	210
	; >>>>> moveQPtr = YKQCreate(moveQ, 10); 
	mov	ax, 10
	push	ax
	mov	ax, moveQ
	push	ax
	call	YKQCreate
	add	sp, 4
	mov	word [moveQPtr], ax
	; >>>>> Line:	211
	; >>>>> availablePieces = 10; 
	mov	word [availablePieces], 10
	; >>>>> Line:	212
	; >>>>> availableMoves = 10; 
	mov	word [availableMoves], 10
	; >>>>> Line:	214
	; >>>>> YKRun(); 
	call	YKRun
	mov	sp, bp
	pop	bp
	ret
L_lab8app_49:
	push	bp
	mov	bp, sp
	jmp	L_lab8app_50
	ALIGN	2
nextCommandPtr:
	TIMES	2 db 0
pieceQ:
	TIMES	20 db 0
pieceQPtr:
	TIMES	2 db 0
moveQ:
	TIMES	20 db 0
moveQPtr:
	TIMES	2 db 0
placement:
	TIMES	1024 db 0
communication:
	TIMES	1024 db 0
statistics:
	TIMES	1024 db 0
pieces:
	TIMES	80 db 0
availablePieces:
	TIMES	2 db 0
moves:
	TIMES	40 db 0
availableMoves:
	TIMES	2 db 0
