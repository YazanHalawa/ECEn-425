# 1 "lab4c_app.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "lab4c_app.c" 2







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


# 8 "lab4c_app.c" 2
# 1 "./yakk.h" 1










typedef struct taskblock *TCBptr;
typedef struct taskblock
{                
    void *stackptr;        
    int state;            
    int priority;        
    int delay;            
    TCBptr next;        
    TCBptr prev;        
}  TCB;

typedef struct semaphore
{
    int value;            
    TCBptr pend;        
}  YKSEM;

typedef struct msgqueue
{
    void **start;        
    int next_in;        
    int next_out;        
    int qsize;            
    int msgcount;        
    TCBptr pend;        
}  YKQ;


void YKScheduler(int);
void YKDispatcher(int);
void YKEnterISR(void);
void YKExitISR(void);
void YKNewTask(void (*) (void), void *, unsigned char);
void YKInitialize(void);
void YKRun(void);
void YKDelayTask(int);
void YKTickHandler(void);
void YKEnterMutex(void);
void YKExitMutex(void);
void YKSemPend(YKSEM *);
void YKSemPost(YKSEM *);
YKSEM * YKSemCreate(int);
void *YKQPend(YKQ *);
int YKQPost(YKQ *, void *);
YKQ * YKQCreate(void *, int);


extern unsigned YKIdleCount;
extern unsigned YKCtxSwCount;
extern unsigned YKTickNum;

# 9 "lab4c_app.c" 2



int TaskStack[256];      

void Task(void);               

void main(void)
{
    YKInitialize();
    
    printString("Creating task...\n");
    YKNewTask(Task, (void *) &TaskStack[256], 0);

    printString("Starting kernel...\n");
    YKRun();
}

void Task(void)
{
    unsigned idleCount;
    unsigned numCtxSwitches;

    printString("Task started.\n");
    while (1)
    {
        printString("Delaying task...\n");

        YKDelayTask(2);
        YKEnterMutex();
        numCtxSwitches = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKIdleCount = 0;
        YKExitMutex();

        printString("Task running after ");
        printUInt(numCtxSwitches);
        printString(" context switches! YKIdleCount is ");
        printUInt(idleCount);
        printString(".\n");
    }
}


