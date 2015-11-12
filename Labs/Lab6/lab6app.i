# 1 "lab6app.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "lab6app.c" 2







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


# 8 "lab6app.c" 2
# 1 "./yakk.h" 1





# 1 "./yaku.h" 1






# 6 "./yakk.h" 2


# 17 "./yakk.h"

typedef struct taskblock *TCBptr;
typedef struct taskblock
{
                
    void *stackptr;     
    int state;          
    int priority;       
    unsigned delay;          
    TCBptr next;        
    TCBptr prev;        
}  TCB;

typedef struct sem
{
	int value;
	TCBptr blockedOn;
} YKSEM;

typedef struct ykq 
{
	void ** baseAddress;
	int numOfEntries;
	int addLoc;
	int removeLoc;
	TCBptr blockedOn;
	int numOfMsgs;
} YKQ;

extern unsigned int YKTickNum;
extern unsigned int YKIdleCount;
extern unsigned int YKCtxSwCount;

void YKInitialize();

void YKEnterMutex();

void YKExitMutex();

void YKIdleTask();

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);

void YKRun();

void YKScheduler(int contextIsSaved);

void YKDispatcher(int contextIsSaved);

void YKIMRInit(unsigned a);

void YKEnterISR();

void YKExitISR();

void YKTickHandler(void);

void YKDelayTask(unsigned count);

YKSEM* YKSemCreate(int initialValue);

void YKSemPend(YKSEM *semaphore);

void YKSemPost(YKSEM *semaphore);

YKQ *YKQCreate(void **start, unsigned size);

void *YKQPend(YKQ *queue);

int YKQPost(YKQ *queue, void *msg);



# 9 "lab6app.c" 2
# 1 "./lab6defs.h" 1








struct msg 
{
    int tick;
    int data;
};
# 10 "lab6app.c" 2




struct msg MsgArray[20];  

int ATaskStk[512];      
int BTaskStk[512];
int STaskStk[512];

int GlobalFlag;

void *MsgQ[10];           
YKQ *MsgQPtr;                   

void ATask(void)                
{
    struct msg *tmp;
    int min, max, count;
        
    min = 100;
    max = 0;
    count = 0;
    
    while (1)
    {
        tmp = (struct msg *) YKQPend(MsgQPtr); 
                
        
        if (tmp->tick != count+1)
        {
            print("! Dropped msgs: tick ", 21);
            if (tmp->tick - (count+1) > 1) {
                printInt(count+1);
                printChar('-');
                printInt(tmp->tick-1);
                printNewLine();
            }
            else {
                printInt(tmp->tick-1);
                printNewLine();
            }
        }
                
        
        count = tmp->tick;
                
        
        if (tmp->data < min)
            min = tmp->data;
        if (tmp->data > max)
            max = tmp->data;
                
        
        print("Ticks: ", 7);
        printInt(count);
        print("\t", 1);
        print("Min: ", 5);
        printInt(min);
        print("\t", 1);
        print("Max: ", 5);
        printInt(max);
        printNewLine();
    }
}

void BTask(void)                
{
    int busycount, curval, j, flag, chcount;
    unsigned tickNum;
        
    curval = 1001;
    chcount = 0;
    
    while (1)
    {
        YKDelayTask(2);
        
        if (GlobalFlag == 1)
        {                           
            YKEnterMutex();
            busycount = YKTickNum;
            YKExitMutex();
            
            while (1)
            {
                YKEnterMutex();
                tickNum = YKTickNum;
                YKExitMutex();
                if(tickNum >= busycount + 5) break;                
                
                curval += 2;        
                flag = 0;
                for (j = 3; (j*j) < curval; j += 2)
                {
                    if (curval % j == 0)
                    {
                        flag = 1;
                        break;
                    }
                }
                if (!flag)
                {
                    printChar('.'); 
                    if (++chcount > 75)
                    {
                        printNewLine();
                        chcount = 0;
                    }
                }
            }
            printNewLine();
            chcount = 0;
            GlobalFlag = 0;        
        }
    }
}

void STask(void)                
{
    unsigned max, switchCount, idleCount;
    int tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    YKNewTask(BTask, (void *) &BTaskStk[512], 10);
    YKNewTask(ATask, (void *) &ATaskStk[512], 20);
    
    while (1)
    {
        YKDelayTask(20);
        
        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
}   

void main(void)
{
    YKInitialize();
    
    
    GlobalFlag = 0;
    MsgQPtr = YKQCreate(MsgQ, 10);
    YKNewTask(STask, (void *) &STaskStk[512], 30);
    
    YKRun();
}
