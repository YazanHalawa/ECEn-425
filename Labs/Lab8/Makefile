#####################################################################
# ECEn 425 Lab 8 Makefile

lab8.bin:	labfinal.s
		nasm labfinal.s -o lab8.bin -l lab8.lst

labfinal.s:	clib.s myisr.s myinth.s lab8app.s yakc.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s lab8app.s yaks.s > labfinal.s

myinth.s:	myinth.c
		cpp -xc++ myinth.c myinth.i
		c86 -g myinth.i myinth.s

yakc.s:		yakc.c
		cpp -xc++ yakc.c yakc.i
		c86 -g yakc.i yakc.s
	
lab8app.s:	lab8app.c
		cpp -xc++ lab8app.c lab8app.i
		c86 -g lab8app.i lab8app.s

clean:
		rm lab8.bin lab8.lst labfinal.s myinth.s myinth.i \
		yakc.s yakc.i lab8app.s lab8app.i
