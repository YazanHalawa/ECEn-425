#include "clib.h"
extern int KeyBuffer;
int tick_counter = 0;

void reset() {
	exit(0);
}

void tick() {
	tick_counter++;
	printNewLine();
	printString("TICK ");
	printUInt(tick_counter);
	printNewLine();
}

void keyboard() {
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
