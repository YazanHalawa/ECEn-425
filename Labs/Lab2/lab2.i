# 1 "lab2.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 325 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "lab2.c" 2



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

# 4 "lab2.c" 2

int k;

void a(void)
{
    static int i = 0;
    int j = 0;
    
    i++;
    j++;
    printString("in a(), i = ");
    printInt(i);
    printString(", j = ");
    printInt(j);
    printNewLine();
}

void b(void)
{
    printString("in b()\n");
    a();
}

int fibonacci(int n)
{
    if (n == 1)
        return 1;
    else if (n == 2)
        return 2;
    else
        return fibonacci(n-1) + fibonacci(n-2);
}

void main(void)
{
    a();
    b();
    for (k = 1; k <= 10; k++) {
        printString("Fibonnaci number ");
        printInt(k);
        printString(" is ");
        printInt(fibonacci(k));
        printNewLine();
    }
}
