#include "clib.h"
extern int KeyBuffer;
static int tickCounter = 0;
void resetIntrHandler(){
	exit(0);
}

void tickIntrHandler(){
	tickCounter++;
	printNewLine();
	printString("Tick ");
	printInt(tickCounter);
	printNewLine();
}

void KeyboardIntrHandler(){
	if (KeyBuffer != 'd'){
		printNewLine();
		printString("KEYPRESS (");
		printChar(KeyBuffer);
		printString(") IGNORED");
		printNewLine();
	}
	else{
		int loopVar = 0;
		printNewLine();
		printString("DELAY KEY PRESSED");
		printNewLine();
		while (loopVar < 5000)
			loopVar++;
		printString("DELAY COMPLETE");
		printNewLine();
	}
}
