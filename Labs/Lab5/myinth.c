#include "yakk.h"

extern int KeyBuffer;
extern YKSEM* NSemPtr;

void reset_inth() {
	exit(0);
}

void keyboard_inth() {
	int delayCounter = 0;
	if (KeyBuffer == 'd') {
		printNewLine();
		printString("DELAY KEY PRESSED");
		printNewLine();
		while (delayCounter <= 5000) {
			delayCounter++;
		}
		printString("DELAY COMPLETE");
		printNewLine();

		
	} else if (KeyBuffer == 'p'){
		YKSemPost(NSemPtr);
	} else {
		printNewLine();
		printString("KEPYRESS (");
		printChar(KeyBuffer);
		printString(") IGNORED");
		printNewLine();
	}
}
