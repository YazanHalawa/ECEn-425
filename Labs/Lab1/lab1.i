# 1 "lab1.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "lab1.c"
# 1 "clib.h" 1



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
# 2 "lab1.c" 2

int AsmFunction(int a, char b, char c, int d, int e);

int gvar;

void main(void)
{
    gvar = 0;

    printString("Hello, world!\r\n");

    gvar = AsmFunction(10, 35, 3, 123, 100);
    print("Result 1 is: ", 13);
    printInt(gvar);
    printNewLine();

    gvar = AsmFunction(14, -10, 126, 32, 15);
    print("Result 2 is: ", 13);
    printInt(gvar);
    printNewLine();

    gvar = AsmFunction(17, 18, -121, 130, 118);
    print("Result 3 is: ", 13);
    printInt(gvar);
    printNewLine();

    printNewLine();
}
