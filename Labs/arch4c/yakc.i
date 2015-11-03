# 1 "yakc.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "yakc.c" 2
yakc







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


# 9 "yakc.c" 2
# 1 "./yaku.h" 1






# 10 "yakc.c" 2
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


# 11 "yakc.c" 2











unsigned YKIntNestLevel;    
unsigned YKRunFlag;        
unsigned YKIdleCount;        
unsigned YKCtxSwCount;        
unsigned YKTickNum;        
TCBptr YKCurrTask;        
TCBptr YKRdyList;        

TCBptr YKSuspList;        
TCBptr YKAvailTCBList;        
TCB YKTCBArray[6 +1];    
char IdleStk[1024];    
YKSEM YKSemArray[4];    
int YKSAvailCount;        
YKQ YKQArray[1];    
int YKQAvailCount;        

void YKInitIMR(unsigned mask);


# 127 "yakc.c"


# 139 "yakc.c"


void YKScheduler(int i)
{




    if (YKRdyList != YKCurrTask)
    {
        YKCtxSwCount++;
        YKDispatcher(i);
    }
}


# 163 "yakc.c"


void YKEnterISR(void)
{
    YKIntNestLevel++;
}









void YKExitISR(void)
{
    if (--YKIntNestLevel == 0)
    {
        YKScheduler(0);
    }
}








void YKIdleTask(void)
{
    while (1)
    {
        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }
}











void YKNewTask(void (* task) (void),  void *stackptr, unsigned char priority)
{
    TCBptr tmp, tmp2;
    int i;
    unsigned *stktmp;

# 227 "yakc.c"
    YKEnterMutex();
    tmp = YKAvailTCBList;    
    if (tmp == 0x0)
    {
        printString("Ran out of TCB's\n");
        exit(0xff);
    }
    YKAvailTCBList = tmp->next;
    tmp->state = 1;        
    tmp->priority = priority;
    tmp->delay = 0;
    if (YKRdyList == 0x0)    
    {
        YKRdyList = tmp;
        tmp->next = 0x0;
        tmp->prev = 0x0;
    }
    else            
    {
        tmp2 = YKRdyList;    
        while (tmp2->priority < tmp->priority)
            tmp2 = tmp2->next;    
        if (tmp2->prev == 0x0)
            YKRdyList = tmp;
        else
            tmp2->prev->next = tmp;
        tmp->prev = tmp2->prev;
        tmp->next = tmp2;
        tmp2->prev = tmp;
    }
    
    



    stktmp = (unsigned *) stackptr;
    stktmp -= 13;        
    for (i = 0; i < 13; i++)    
        stktmp[i] = 0;
    
    stktmp[9]  = (unsigned) 0x00;
    stktmp[10] = (unsigned) task; 
    stktmp[12] = (unsigned) 0x0200;
    tmp->stackptr = (void *) stktmp; 
    
    if (YKRunFlag)
        YKScheduler(1);
    
    YKExitMutex();
}








void YKInitialize(void)
{
    int i;
    YKEnterMutex();        
    YKInitIMR(0x00);    
    YKIntNestLevel = 0;
    YKRunFlag = 0;
    YKIdleCount = 0;
    YKTickNum = 0;
    YKCtxSwCount = 0;
    YKCurrTask = 0x0;
    YKRdyList = 0x0;
    YKSuspList = 0x0;
    YKSAvailCount = 4;
    YKQAvailCount = 1;
    
    
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < 6; i++)
    {
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[i].prev = 0x0;
    }
    YKTCBArray[6].next = 0x0;
    YKTCBArray[6].prev = 0x0;
    
    
    YKNewTask(YKIdleTask, (void *) &(IdleStk[1024]), 63);
}











void YKRun(void)
{
    YKRunFlag = 1;
    YKScheduler(0);
}




void YKDelayTask(int ticks)
{
    TCBptr tmp;
    YKEnterMutex();
    tmp = YKRdyList;        
    YKRdyList = tmp->next;    
    tmp->next->prev = 0x0;
    tmp->state = 5;    
    tmp->delay = ticks;        
    tmp->next = YKSuspList;    
    YKSuspList = tmp;
    tmp->prev = 0x0;
    if (tmp->next != 0x0)
        tmp->next->prev = tmp;
    YKScheduler(1);
    YKExitMutex();
}







void YKTickHandler(void)
{
    TCBptr tmp, tmp2, nxt;
    YKTickNum++;
    tmp = YKSuspList;
    while (tmp != 0x0)
    {
        tmp->delay--;
        if (tmp->delay == 0)
        {
            tmp->state = 1;    
            nxt = tmp->next;    
            
            
            if (tmp->prev == 0x0)
                YKSuspList = tmp->next;
            else
                tmp->prev->next = tmp->next;
            if (tmp->next != 0x0)
                tmp->next->prev = tmp->prev;
            
            
            tmp2 = YKRdyList;
            while (tmp2->priority < tmp->priority)
                tmp2 = tmp2->next;
            if (tmp2->prev == 0x0)
                YKRdyList = tmp;
            else
                tmp2->prev->next = tmp;
            tmp->prev = tmp2->prev;
            tmp->next = tmp2;
            tmp2->prev = tmp;
            
            
            tmp = nxt;
        }
        else
        {
            tmp = tmp->next;
        }
    }
}

void YKSemPend(YKSEM * sem)
{
    YKEnterMutex();
    if (sem->value-- > 0)
        YKExitMutex();
    else
    {
        TCBptr tmp, tmp2, tmp3;
        
        tmp = YKRdyList;
        YKRdyList = tmp->next;
        tmp->next->prev = 0x0;
        
        
        tmp->state = 3;
        
        
        if (sem->pend == 0x0)    
        {
            sem->pend = tmp;
            tmp->next = 0x0;
            tmp->prev = 0x0;
        }
        else            
        {            
            tmp2 = sem->pend;
            tmp3 = 0x0;
            while (tmp2 != 0x0 && tmp2->priority < tmp->priority)
            {
                tmp3 = tmp2;
                tmp2 = tmp2->next;
            }
            if (tmp2 == 0x0)
            {            
                tmp3->next = tmp;
                tmp->prev = tmp3;
                tmp->next = 0x0;
            }
            else
            {            
                tmp->next = tmp2;
                tmp->prev = tmp3;
                tmp2->prev = tmp;
                if (tmp3 == 0x0)
                    sem->pend = tmp;
                else
                    tmp3->next = tmp;
            }
        }
        YKScheduler(1);
        YKExitMutex();
    }
}

void YKSemPost(YKSEM * sem)
{
    YKEnterMutex();
    if (sem->value++ >= 0)
        YKExitMutex();
    else
    {
        
        TCBptr tmp, tmp2;
        tmp = sem->pend;
        sem->pend = tmp->next;
        if (sem->pend != 0x0)
            sem->pend->prev = 0x0;
        
        
        tmp->state = 1;
        
        
        tmp2 = YKRdyList;
        while (tmp2->priority < tmp->priority)
            tmp2 = tmp2->next;
        if (tmp2->prev == 0x0)
            YKRdyList = tmp;
        else
            tmp2->prev->next = tmp;
        tmp->prev = tmp2->prev;
        tmp->next = tmp2;
        tmp2->prev = tmp;
        
        
        if (YKIntNestLevel == 0)
            YKScheduler(1);
        YKExitMutex();
    }
    
}

YKSEM * YKSemCreate(int value)
{
    YKEnterMutex();
    
    if (YKSAvailCount <= 0)
    {
        YKExitMutex();
        printString("Ran out of semaphores: revise MAXSEMS\n");
        exit(0xff);
    }
    else
    {
        YKSAvailCount--;
        YKSemArray[YKSAvailCount].value = value;
        YKSemArray[YKSAvailCount].pend = 0x0;
    }
    YKExitMutex();
    return (&(YKSemArray[YKSAvailCount]));
}

void *YKQPend(YKQ *queue)
{
    void *msgtmp;
TOP:
    YKEnterMutex();
    
    if (queue->msgcount > 0)
    {                
        msgtmp = queue->start[queue->next_out];
        queue->next_out++;
        if (queue->next_out >= queue->qsize)
            queue->next_out = 0;
        queue->msgcount--;
    }
    else
    {                
        TCBptr tmp, tmp2, tmp3;
        
        tmp = YKRdyList;
        YKRdyList = tmp->next;
        tmp->next->prev = 0x0;
        
        
        tmp->state = 3;
        
        
        if (queue->pend == 0x0) 
        {
            queue->pend = tmp;
            tmp->next = 0x0;
            tmp->prev = 0x0;
        }
        else            
        {            
            tmp2 = queue->pend;
            tmp3 = 0x0;
            while (tmp2 != 0x0 && tmp2->priority < tmp->priority)
            {
                
                tmp3 = tmp2;
                tmp2 = tmp2->next;
            }
            if (tmp2 == 0x0)
            {            
                tmp3->next = tmp;
                tmp->prev = tmp3;
                tmp->next = 0x0;
            }
            else
            {            
                tmp->next = tmp2;
                tmp->prev = tmp3;
                tmp2->prev = tmp;
                if (tmp3 == 0x0)
                    queue->pend = tmp;
                else
                    tmp3->next = tmp;
            }
        }
        YKScheduler(1);
        YKExitMutex();
        goto TOP;
    }
    YKExitMutex();
    return msgtmp;
}

int YKQPost(YKQ *queue, void *msg)
{
    YKEnterMutex();
    if (queue->msgcount >= queue->qsize)
    {
        YKExitMutex();
        return 0;    
    }
    else
    {                
        queue->start[queue->next_in] = msg;
        queue->next_in++;
        if (queue->next_in >= queue->qsize)
            queue->next_in = 0;
        queue->msgcount++;
        if (queue->pend != 0x0)
        {            
            TCBptr tmp, tmp2;
            tmp = queue->pend;
            queue->pend = tmp->next;
            if (queue->pend != 0x0)
                queue->pend->prev = 0x0;
            
            tmp->state = 1;
            
            
            tmp2 = YKRdyList;
            while (tmp2->priority < tmp->priority)
                tmp2 = tmp2->next;
            if (tmp2->prev == 0x0)
                YKRdyList = tmp;
            else
                tmp2->prev->next = tmp;
            tmp->prev = tmp2->prev;
            tmp->next = tmp2;
            tmp2->prev = tmp;
            
            
            if (YKIntNestLevel == 0)
                YKScheduler(1);
        }
        YKExitMutex();
        return 1;
    }
}

YKQ * YKQCreate(void *start, int size)
{
    YKEnterMutex();
    
    if (YKQAvailCount <= 0)
    {
        YKExitMutex();
        printString("Ran out of queues: revise MAXQUEUES\n");
        exit(0xff);
    }
    else
    {
        YKQAvailCount--;
        YKQArray[YKQAvailCount].start = (void **) start;
        YKQArray[YKQAvailCount].next_in = 0;
        YKQArray[YKQAvailCount].next_out = 0;
        YKQArray[YKQAvailCount].qsize = size;
        YKQArray[YKQAvailCount].msgcount = 0;
        YKQArray[YKQAvailCount].pend = 0x0;
    }
    YKExitMutex();
    return &(YKQArray[YKQAvailCount]);
}

