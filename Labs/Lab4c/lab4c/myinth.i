# 1 "myinth.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "myinth.c" 2
# 1 "./clib.h" 1



void print(char *string, int length); 
void printNewLine(void);              
void printChar(char c);               
void printString(char *string);       


void printInt(int val);
void printLong(long val);
void printUInt(unsigned val);
void printULong(unsigned long val);


void printByte(char val);
void printWord(int val);
void printDWord(long val);


void exit(unsigned char code);        


void signalEOI(void);                 


# 2 "myinth.c" 2

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

