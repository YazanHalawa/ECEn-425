#include "clib.h"

extern int KeyBuffer;

void reset_inth() {
	exit(0);
}

void tick_inth() {
	static int tickCount = 0;
	tickCount ++;
	print("\nTick ", 6);
	printInt(tickCount);
	printNewLine();
}

void keyboard_inth() {
	int delayCounter = 0;
	if (KeyBuffer != 'd') {
		printNewLine();
		printString("KEPYRESS (");
		printChar(KeyBuffer);
		printString(") IGNORED");
		printNewLine();
	} else {
		printNewLine();
		printString("DELAY KEY PRESSED");
		printNewLine();
		while (delayCounter <= 5000) {
			delayCounter++;
		}
		printString("DELAY COMPLETE");
		printNewLine();
	}
}
