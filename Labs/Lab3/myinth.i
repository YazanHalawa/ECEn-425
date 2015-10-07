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

