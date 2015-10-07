# Makefile for ECEn 425 labs

LAB=	lab2.c
LAB_I=	lab2.i
LAB_S=	lab2.s
LAB_FINAL=	lab2final.s
LAB_BIN=	lab2.bin
LAB_LIST=	lab2.lst
OBJS = $(LAB) $(LAB_I) $(LAB_S) $(LAB_FINAL) $(LAB_BIN) $(LAB_LIST)

all:	LAB_S LAB_FINAL LAB_BIN

LAB_BIN:		$(LAB_FINAL)
			nasm $(LAB_FINAL) -o $(LAB_BIN) -l $(LAB_LIST)  # Step 4, Assemble

LAB_FINAL:		clib.s $(LAB_S)
			cat clib.s $(LAB_S) > $(LAB_FINAL) # Step 3, Concatenate

LAB_S:			$(LAB)
			cpp -xc++ $(LAB) $(LAB_I)    # Step 1, Preprocess
			c86 -g $(LAB_I) $(LAB_S)     # Step 2, Compile

clean:  
			rm $(LAB_BIN) $(LAB_LIST) $(LAB_FINAL) $(LAB_S) $(LAB_I)
