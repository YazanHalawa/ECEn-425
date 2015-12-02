reset:
	call	reset_inth

tick:
	call	YKSaveContext
	call	YKEnterISR

	sti 			; enable interrupts
	call	mytick
	call	YKTickHandler
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

keyboard:
	call	YKSaveContext
	call	YKEnterISR

	sti				; enable interrupts
	call	keyboard_inth
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

gameOver:
	call	YKSaveContext
	call	YKEnterISR

	sti				; enable interrupts
	call	setGameOver
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

newPiece:
	call	YKSaveContext
	call	YKEnterISR

	sti				; enable interrupts
	call	gotNewPiece_handler
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

receivedCommand:
	call	YKSaveContext
	call	YKEnterISR

	sti				; enable interrupts
	call	setReceivedCommand_handler
	cli 			; disable interrupts

	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

touchDown: ;Ignored
	push	ax
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al
	pop	ax
	iret

lineClear: ;Ignored
	push	ax
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al
	pop	ax
	iret
