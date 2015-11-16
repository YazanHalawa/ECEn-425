#####################################################################
# ECEn 425 Lab 7 Makefile

lab7.bin:	labfinal.s
		nasm labfinal.s -o lab7.bin -l lab7.lst

labfinal.s:	clib.s myisr.s myinth.s lab7app.s yakc.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s lab7app.s yaks.s > labfinal.s

myinth.s:	myinth.c
		cpp -xc++ myinth.c myinth.i
		c86 -g myinth.i myinth.s

yakc.s:		yakc.c
		cpp -xc++ yakc.c yakc.i
		c86 -g yakc.i yakc.s
	
lab7app.s:	lab7app.c
		cpp -xc++ lab7app.c lab7app.i
		c86 -g lab7app.i lab7app.s

clean:
		rm lab7.bin lab7.lst labfinal.s myinth.s myinth.i \
		yakc.s yakc.i lab7app.s lab7app.i
