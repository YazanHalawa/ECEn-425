YKEnterMutex:
	cli
	ret

YKExitMutex:
	sti
	ret

YKDispatcher:
			;update YKCurTask
	iret
	
