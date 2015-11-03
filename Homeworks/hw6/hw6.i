# 1 "HW6.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "HW6.c" 2
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

# 2 "HW6.c" 2

int main(){
    int var;
    switch(var){
        case 200: 
            printString("this is 0\n");
            break;
        case 313:
            printString("this is 1\n");
            break;
        case 467: 
            printString("this is 2\n");
            break;
        case 897: 
            printString("this is 3\n"); 
            break;
        case 999: 
            printString("this is 4\n"); 
            break;
        case 550: 
            printString("this is 5\n"); 
            break;
        case 600: 
            printString("this is 6\n"); 
            break;
        case 768: 
            printString("this is 7\n"); 
            break;
        default: 
            printString("this is default\n"); 
            break;
    }   
    return 0;
}
