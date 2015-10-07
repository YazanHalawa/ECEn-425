; Modify AsmFunction to perform the calculation gvar+(a*(b+c))/(d-e).
; Keep in mind the C declaration:
; int AsmFunction(int a, char b, char c, int d, int e);

	CPU	8086
	align	2

AsmFunction:
	push	bp
	mov		bp,sp
	push	bx
	push	cx
	mov	cx,  [bp+10]
	sub	cx,  [bp+12]
	mov	al, byte [bp+6]
	add	al, byte [bp+8]
	cbw
	imul	word [bp+4]
	idiv	cx
	add	ax, [gvar]
	pop	cx
	pop bx
	mov sp,bp
	pop bp
	ret

