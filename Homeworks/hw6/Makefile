#####################################################################
# ECEn 425 Lab 3 Makefile

hw6.bin:	hw6final.s
		nasm hw6final.s -o hw6.bin -l hw6.lst

hw6final.s:	clib.s hw6.s
		cat clib.s hw6.s > hw6final.s

hw6.s:		HW6.c
		cpp -xc++ HW6.c hw6.i
		c86 -g hw6.i hw6.s

clean:
		rm hw6.bin hw6.lst hw6final.s \
		hw6.s hw6.i
