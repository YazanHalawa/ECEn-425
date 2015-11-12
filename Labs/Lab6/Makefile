#####################################################################
# ECEn 425 Lab 6 Makefile

lab6.bin:	labfinal.s
		nasm labfinal.s -o lab6.bin -l lab6.lst

labfinal.s:	clib.s myisr.s myinth.s lab6app.s yakc.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s lab6app.s yaks.s > labfinal.s

myinth.s:	myinth.c
		cpp -xc++ myinth.c myinth.i
		c86 -g myinth.i myinth.s

yakc.s:		yakc.c
		cpp -xc++ yakc.c yakc.i
		c86 -g yakc.i yakc.s
	
lab6app.s:	lab6app.c
		cpp -xc++ lab6app.c lab6app.i
		c86 -g lab6app.i lab6app.s

clean:
		rm lab6.bin lab6.lst labfinal.s myinth.s myinth.i \
		yakc.s yakc.i lab6app.s lab6app.i
