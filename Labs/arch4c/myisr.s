    ;; upon entry to any ISR, the flags, CS, and IP registers will already
    ;; be pushed on the stack.  Interrupts will already be disabled (the IF bit
    ;; in the flag register).
    ;;  Basic ISR template:
    ;;   (1) save context by pushing registers onto the stack
    ;;   (1.5) call YKEnterISR
    ;;   (2) enable interrupts at higher priorities
    ;;   (3) call the interrupt handler (C code)
    ;;   (3.5) disable interrupts
    ;;   (4) send the EOI command to the PIC, indicating that the handler is done
    ;;   (4.5) call YKExitISR
    ;;   (5) restore the context stored in (1) above
    ;;   (6) execute the iret instruction

    ;; -------------------------------------------------------------------------
    ;; The reset ISR     --     priority 0
    ;; -------------------------------------------------------------------------

myresetISR:        
    call    myreset        ; don't save state


    ;; -------------------------------------------------------------------------
    ;; The tick ISR      --     priority 1
    ;; -------------------------------------------------------------------------

mytickISR:
    call    YKSaveCtx    ; (1) save all registers, including IMR

    call    YKEnterISR
    mov    bp, sp        ; (2) revise IMR  --  (get it from stack first)
    mov    ax, [bp+18]
    or      al, 0xfe    ;     disable interrupts at current and lower priorities
    sti            ;     enable interrupts

    call    YKTickHandler    ; (3) call YAK tick handler
    call    mytick        ; (3) call user tick handler

    cli            ;  disable interrupts prior to cleanup code execution
    
    mov    al, 0x20    ; (4) send EOI command
    out    0x20, al

    call    YKExitISR

    call    YKRestCtx       ; (5) restore context, starting with IMR

    iret            ; return


    ;; -------------------------------------------------------------------------
    ;; The keypress ISR   --    priority 2
    ;; -------------------------------------------------------------------------

mykeypressISR:
    call    YKSaveCtx    ; (1) save all registers, including IMR

    call    YKEnterISR

    mov    bp, sp        ; (2) revise IMR  --  (get it from stack first)
    mov    ax, [bp+18]
    or      al, 0xfc    ;     disable interrupts at current and lower priorities
    sti            ;     enable interrupts

    call    mykeybrd    ; (3) call handler

    cli            ;  disable interrupts prior to cleanup code execution
    
    mov    al, 0x20    ; (4) send EOI command
    out    0x20, al

    call    YKExitISR

    call    YKRestCtx       ; (5) restore context, starting with IMR

    iret            ; return

    ;; -------------------------------------------------------------------------
    ;; The gameover ISR   --    priority 3
    ;; -------------------------------------------------------------------------