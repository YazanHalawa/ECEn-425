;;  YAK Kernel routines that are written in 8086 assembly
;;  (c) James Archibald, Brigham Young University
;;  September 2002

    ;; Using these instead of inline macros just to stick with syntax for these functions
YKEnterMutex:
     cli            ; disable interrupts
     ret

YKExitMutex:
     sti            ; enable interrupts
     ret

;; YKSaveCtx saves registers and the IMR on the stack.  It assumes that
;; interrupts are already disabled.  If the interrupt nesting level is zero,
;; it saves the stack pointer in the TCB of the current task.  It has to 
;; mess with the stack frame to make the return address handling work out correctly.
;; More specifically, it must move the return address to the top of the stack (on top
;; of the frame of saved context), and then it saves the IMR in the slot previously
;; occupied by the return address. 
        
YKSaveCtx:
    push    ax        ; do all CPU registers first
    push    bx
    push    cx
    push    dx
    push    es
    push    ds
    push    si
    push    di
    push    bp

    mov    bp, sp    
    push    word [bp+18]    ; move return address to top of stack

    in    al, 0x21    ; get IMR
    mov    [bp+18], ax    ; save it where return address was

    mov    ax, [YKIntNestLevel]; test for nested interrupts
    cmp    ax, 0
    jg    YKSaveCtx2

    mov    bx,[YKCurrTask]    ; get ptr to current TCB
    mov    bp, sp
    add    bp, 2
    mov    [bx], bp    ; store top of context frame in first field of TCB

YKSaveCtx2:
    ret


;; YKRestCtx restores registers and IMR from the stack.  It assumes that
;; interrupts are disabled at time of call.  It does not restore sp because
;; it wasn't on the stack (it was stored in the TCB and must already have been
;; restored to get to this context).  It has to mess around with the return
;; address to get it on the top of stack at return.

YKRestCtx:
    mov    bp, sp
    mov    ax, [bp+20]    ; restore IMR first, free slot for return address
    out    0x21, al
    pop    word [bp+20]    ; move return address to bottom of this frame
    pop    bp        ; now restore all CPU registers saved
    pop    di
    pop    si
    pop    ds
    pop    es
    pop    dx
    pop    cx
    pop    bx
    pop    ax
    ret

    
;; The dispatcher expects a single parameter. If that parameter is 1, the
;; context of the current task is saved by calling YKSaveCtx (which also
;; saves the stack pointer in the current task's TCB).  If the parameter
;; is 0, the context has already been saved (by an ISR).  After the
;; context is saved, if necessary, the only tasks remaining are to modify
;; YKCurrTask to point to the task about to be dispatched, to restore the
;; context of that task (by calling YKRestCtx), and then to fire up the task.
;; The mechanism for passing control is an iret instruction, chosen because it
;; also enables interrupts.  The tricky part is that it expects IP, CS, and flags
;; to be on the top of the stack (in that order), and you have to make sure that they
;; were placed there correctly. Interrupts are assumed to be disabled when this function
;; is called.

YKDispatcher:
    push    bp        ; save bp so value isn't clobbered
    mov    bp, sp        ; load up bp so argument value can be accessed
    cmp    word [bp+4], 0
    pop    bp        ; restore bp (won't change flags)
    je    YKDisp1        ; jump if argument equals zero

    ;; save flags temporarily, create one more slot on stack.  (Above the old stack
    ;; that we shouldn't mess up, there is a slot for incoming parameter to this
    ;; function that the scheduler will undo, so we can't use it, then a slot for
    ;; the return address.  We need to add one more for IP and one more for CS,
    ;; reorder them so they are IP, CS, and flags, top to bottom.)  First we'll
    ;; create the extra slots, then save the regular context, then make sure the 3
    ;; slots get filled with the right contents.  (Saving the full context first
    ;; means you don't have to worry about clobbering the other register contents.)

    push    cs        ; push cs (in correct slot)
    pushf            ; push flags (not correct slot; fix up later)

    ;; save context of current task 
    call    YKSaveCtx

    ;; now that all registers are available, fix up 3 words at bottom of stack frame
    ;; so that iret can be used later to dispatch saved task 
    ;; 1st, set IF in flags and move to correct slot (bottom)
    ;; 2nd, move return address (RA) to correct slot (top)
    ;; (CS is already in middle slot)

    mov    bp, sp        ; set bp to top of context frame
    mov    bx, [bp+20]    ; put flags in bx
    mov    ax, [bp+24]    ; put return address in ax
    mov    [bp+20], ax    ; put return address in correct slot
    or    bx, 0x200    ; set IF bit in flag register
    mov    [bp+24], bx    ; store new flags (with IF set)
    
YKDisp1:            ; context saved either way now, fire up new task
    mov    bx, [YKRdyList]    ; restore sp for new task
    mov    sp, [bx]
    mov    [YKCurrTask], bx; update CurrTask ptr to new task
    call    YKRestCtx    ; restore registers and IMR
    iret


;; This routine is called by YKInitialize().
;; It sets the IMR to the value passed in as a parameter.

YKInitIMR:
    push    ax
    push    bp
    mov    bp, sp
    mov    al, [bp+6]
    out    0x21, al
    pop    bp
    pop    ax
    ret
