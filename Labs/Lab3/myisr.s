
reset:
	call	resetIntrHandler	; Call Handler


tick:
	push	ax					;
	push	bx					;
	push	cx					;
	push	dx					;
	push	si 					; Save Context	
	push	di					;
	push	bp					;
	push	es					;
	push	ds					;

	sti 						; Enable Interrupts
	call 	tickIntrHandler 	; Call Handler
	call 	signalEOI 			; send EOI to PIC
	cli 						; Disable Interrupts

	pop		ds					;
	pop		es					;
	pop		bp					;
	pop		di					;
	pop		si 					; Restore Context
	pop		dx					;
	pop		cx 					;
	pop		bx					;
	pop		ax					;

	iret						; Return



keyboard:
	push	ax					;
	push	bx					;
	push	cx 					;
	push	dx 					;
	push	si 					; Save Context
	push	di 					;
	push	bp					;
	push	es 					;
	push	ds 					;

	sti 						; Enable Interrupts
	call 	KeyboardIntrHandler ; Call Handler
	cli 						; Disable Interrupts
	call 	signalEOI 			; send EOI to PIC

	pop		ds  				;
	pop		es 					;
	pop		bp					;
	pop		di 					;
	pop		si 					; Restore Context
	pop		dx 					; 
	pop		cx 					;
	pop		bx 					;
	pop		ax 					;

	iret						; Return

