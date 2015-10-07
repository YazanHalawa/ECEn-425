lab1.bin:		lab1final.s
				nasm lab1final.s -o lab1.bin -l lab1.lst  # Step 4, Assemble

lab1final.s:	clib.S lab1asm.S lab1.s
				cat clib.S lab1asm.S lab1.s > lab1final.s # Step 3, Concatenate

lab1.s:			lab1.c
				cpp -xc++ lab1.c lab1.i    # Step 1, Preprocess
				c86 -g lab1.i lab1.s       # Step 2, Compile

clean:  
				rm lab1.bin lab1.lst lab1final.s lab1.s lab1.i

test:
				emu86 lab1.bin
