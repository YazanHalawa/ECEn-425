#####################################################################
# ECEn 425 Lab 4d Makefile

lab4d.bin:	labfinal.s
		nasm labfinal.s -o lab4d.bin -l lab4d.lst

labfinal.s:	clib.s myisr.s myinth.s lab4d_app.s yakc.s yaks.s
		cat clib.s myisr.s myinth.s yakc.s lab4d_app.s yaks.s > labfinal.s

myinth.s:	myinth.c
		cpp -xc++ myinth.c myinth.i
		c86 -g myinth.i myinth.s

yakc.s:		yakc.c
		cpp -xc++ yakc.c yakc.i
		c86 -g yakc.i yakc.s
	
lab4d_app.s:	lab4d_app.c
		cpp -xc++ lab4d_app.c lab4d_app.i
		c86 -g lab4d_app.i lab4d_app.s

clean:
		rm lab4d.bin lab4d.lst labfinal.s myinth.s myinth.i \
		yakc.s yakc.i lab4d_app.s lab4d_app.i
