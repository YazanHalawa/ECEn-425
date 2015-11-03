# 1 "question3.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "question3.c" 2
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

# 2 "question3.c" 2






char a[][58] = { "a short string", "a very, very, VERY long string, yea, exceeding all others", "a nice string of medium length", "a shortish string" };
char *b[]    = { "a short string", "a very, very, VERY long string, yea, exceeding all others", "a nice string of medium length", "a shortish string" };

int mystrlen(char *s)
{   
    int i;
    for (i = 0; s[i] != '\0'; i++);
    return i;
}

void main(void)
{
    int i;
    printString("Contents of a[][]\n");
    for (i = 0; i < 4; i++)
    {
        printString(" <");
        printInt(mystrlen(a[i]));
        printString("> ");
        printString(a[i]);
        printNewLine();
    }
    printString("Contents of *b[]\n");
    for (i = 0; i < 4; i++)
    {
        printString(" <");
        printInt(mystrlen(b[i]));
        printString("> ");
        printString(b[i]);
        printNewLine();
    }
}


