YKEnterMutex:
	cli
	ret

YKExitMutex:
	sti
	ret

YKSaveContext:
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push 	si
	push	di
	push 	bp

	mov		bp, sp
	push	word[bp+18] ;move return address to top of stack
	mov		[bp+18], cx

	mov cx, [nestingLevel]
	cmp cx, 0
	jg	YKRet

	mov bx, [YKCurTask]
	mov bp, sp
	add	bp, 2
	mov [bx], bp

YKRet:
	ret

YKDispatcher:
	
	push bp 	
	mov bp, sp	
	cmp	word[bp+4], 0		; compare arg1 with 0
	pop bp
	je	YKDispatcherExtra ; if arg1 == 0, do the extra dispatch code.
	
	push cs
	pushf
	call YKSaveContext

	mov	bp, sp
	mov	bx, [bp+20]
	mov	cx, [bp+24]
	mov	[bp+24], cx
	or bx, 0x00200
	mov	[bp+24], bx

YKDispatcherExtra:
	mov bx, [YKRdyList]
	mov sp, [bx]
	mov	[YKCurTask], bx
	call	YKRestoreContext
	iret
	
YKRestoreContext:
	
	; pop registers
	
	mov	bp, sp
	mov cx, [bp+20]
	pop	word[bp+20]
	
	pop		bp
	pop		di
	pop		si
	pop		ds
	pop		es
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	ret

YKIMRInit:
	push ax
	push bp
	mov bp, sp
	mov al, [bp+6]
	pop bp
	pop ax
	ret
