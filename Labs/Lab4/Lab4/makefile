#####################################################################
# ECEn 425 Lab 4 Makefile

lab4.bin:	lab4final.s
		nasm lab4final.s -o lab4.bin -l lab4.lst

lab4final.s:	clib.s myisr.s myinth.s yakc.s lab4b_app.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s yaks.s lab4b_app.s > lab4final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s
		
lab4b_app.s:	lab4b_app.c
		cpp lab4b_app.c lab4b_app.i
		c86 -g lab4b_app.i lab4b_app.s

yakc.s:		yakk.h yaku.h yakc.c  
		cpp yakc.c yakc.i
		c86 -g yakc.i yakc.s

myisr.s: myisr.c
		cpp myisr.c myisr.i
		c86 -g myisr.i myisr.s
clean:
		rm lab4.bin lab4.lst lab4final.s myinth.s myinth.i lab4b_app.s lab4b_app.i yakc.s yakc.i
