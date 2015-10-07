# 1 "primes.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "primes.c" 2



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


# 4 "primes.c" 2




void main(void)
{
    unsigned i, j;
    int flag,lncnt;

    printString("Primes between ");
    printUInt(1001U);
    printString(" and ");
    printUInt(65000U);
    printString(":\n");
    lncnt = 0;

    for (i = 1001U; i < 65000U; i += 2) {
        flag = 0;
        for (j = 3; (j*j) < i; j += 2) {
            if (i % j == 0) {
                flag = 1;
                break;
            }
        }
        if (!flag) {
            printChar(' ');
            printUInt(i);
            lncnt++;
            if (lncnt > 9) {
                printNewLine();
                lncnt = 0;
            }
        }
    }

    printNewLine();
}

