# Makefile for ECEn 425 labs

LAB=	question3.c
LAB_I=	question3.i
LAB_S=	question3.s
LAB_FINAL=	question3Final.s
LAB_BIN=	question3.bin
LAB_LIST=	question3.lst
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
