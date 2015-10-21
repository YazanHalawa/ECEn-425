reset:
	call	reset_inth

tick:
	call	YKSaveContext
	call	YKEnterISR
	mov		bp, sp
	mov		ax, [bp+18]
	or		al, 0xfe
	sti 			; enable interrupts
	call	YKTickHandler
	call	tick_inth
	cli 			; disable interrupts
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret

keyboard:
	call	YKSaveContext
	call	YKEnterISR
	mov		bp, sp
	mov		ax, [bp+18]
	mov		al, 0xfc
	sti				; enable interrupts
	call	keyboard_inth
	cli 			; disable interrupts
	mov	al, 0x20	; Load nonspecific EOI value (0x20) into register al
	out	0x20, al	; Write EOI to PIC (port 0x20)
	call	YKExitISR
	call	YKRestoreContext
	iret
