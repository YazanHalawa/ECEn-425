# 1 "yakc.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "yakc.c" 2
# 1 "./yakk.h" 1




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


# 5 "./yakk.h" 2
# 1 "./yaku.h" 1






# 6 "./yakk.h" 2


# 20 "./yakk.h"




typedef struct taskblock *TCBptr;
typedef struct taskblock
{
                
    void *stackptr;     
    int state;          
    int priority;       
    unsigned delay;          
    TCBptr next;        
    TCBptr prev;        
    unsigned flags;
    int waitMode;
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

typedef struct eventGroup
{
	unsigned flags; 
	TCBptr waitingOn;
} YKEVENT;

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

int checkConditions(unsigned eventFlags, unsigned eventMask, int waitMode);

YKEVENT *YKEventCreate(unsigned initialValue);

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);

void YKEventSet(YKEVENT *event, unsigned eventMask);

void YKEventReset(YKEVENT *event, unsigned eventMask);


# 2 "yakc.c" 2

TCBptr YKRdyList;       
TCBptr YKCurTask;       
                
TCBptr YKSuspList;      
TCBptr YKAvailTCBList;      
TCB    YKTCBArray[4 +1];  

unsigned int running;
int idleStk[2048];
unsigned int YKIdleCount;
unsigned int YKCtxSwCount;
unsigned int nestingLevel;
unsigned int YKTickNum;
int YKQAvailCount; 
YKQ YKQs[1]; 

YKSEM YKSems[4]; 
int YKAvaiSems; 

YKEVENT YKEvents[2]; 
int YKAvaiEvents; 

void YKInitialize(){
    int i;
    YKEnterMutex();
    YKIMRInit(0x00);
    running = 0;
    YKIdleCount = 0;
    YKCtxSwCount = 0;
    YKCurTask = 0x0; 
    YKRdyList = 0x0;
    YKSuspList = 0x0;
    nestingLevel = 0;
    YKTickNum = 0;
    YKAvaiSems = 4;
    YKQAvailCount = 1;
    YKAvaiEvents = 2;
    
    
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < 4; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[4].prev = 0x0; 
    }
    YKTCBArray[4].next = 0x0;
    YKTCBArray[4].prev = 0x0;

    YKNewTask(YKIdleTask,(void *) &(idleStk[2048]),100);  
}

void YKIdleTask(){
    while(1){
        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }

}

void YKNewTask(void (* task)(void), void *stackptr, unsigned char priority){
    int i;
    unsigned *stackIter;
    TCBptr insertion, iter2;
    
    YKEnterMutex();

    insertion = YKAvailTCBList;  
    
    if(insertion == 0x0){
        return;
    } 
    
    YKAvailTCBList =  insertion->next;   
     
    insertion->state = 0;
    insertion->priority = priority;
    insertion->delay = 0;
    insertion->flags = 0;
    insertion->waitMode = 0;
 
    if (YKRdyList == 0x0)  
    {
        YKRdyList = insertion;
        insertion->next = 0x0;
        insertion->prev = 0x0;
    }
    else            
    {
        iter2 = YKRdyList;   
        while (iter2->priority < insertion->priority)
            iter2 = iter2->next;  
        if (iter2->prev == 0x0) 
            YKRdyList = insertion;
        else
            iter2->prev->next = insertion;
        insertion->prev = iter2->prev;
        insertion->next = iter2;
        iter2->prev = insertion;
    }
    stackIter = (unsigned *)stackptr;
    stackIter -=13;

    for(i=0; i<13; i++) {
        if (i == 10) {
            stackIter[i] = (unsigned)task;
        } else if (i == 12) {
            stackIter[i] = 0x0200;   
        } else {
            stackIter[i] = 0;
        }
    }   
    insertion->stackptr = (void *)stackIter;
    if(running == 1) {
        YKScheduler(1);
    } 
    YKExitMutex(); 
}

void YKRun(){
    
    running = 1;
    YKScheduler(1);
}

void YKScheduler(int saveContext){
YKEnterMutex();
    if(YKRdyList != YKCurTask){  
        YKCtxSwCount++; 
        YKDispatcher(saveContext);
    }
YKExitMutex();
}

void YKDelayTask(unsigned count){
    TCBptr temp;
    YKEnterMutex();
    temp = YKRdyList; 
    
    YKRdyList = temp->next; 
    if (YKRdyList != 0x0)
       YKRdyList->prev = 0x0;
    temp->state = 2;
    temp->delay = count;

    
    temp->next = YKSuspList;
    YKSuspList = temp;
    temp->prev = 0x0;
    if (temp->next != 0x0)
        temp->next->prev = temp;
    YKScheduler(1);
    YKExitMutex();
}

void YKTickHandler(void){
    TCBptr temp, temp2, next;
    YKEnterMutex();
    YKTickNum++;
    temp = YKSuspList;
    while (temp != 0x0){
        temp->delay--;
        if (temp->delay == 0){ 
            temp->state = 0; 
            next = temp->next; 
            
            if (temp->prev == 0x0){
                YKSuspList = temp->next;
            }
            else{
                temp->prev->next = temp->next;
            }
            if (temp->next != 0x0){
                temp->next->prev = temp->prev;
            }
            
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == 0x0){
                YKRdyList = temp;
            }
            else{
                temp2->prev->next = temp;
            }
            temp->prev = temp2->prev;
            temp->next = temp2;
            temp2->prev = temp;
            
            temp = next;
        }
        else{
            temp = temp->next;
        }
    }
    YKExitMutex();
}

void YKEnterISR() {
    nestingLevel++;
}

void YKExitISR() {

    nestingLevel--;
    if (nestingLevel == 0 && running) {
        YKScheduler(0);
    }
}

YKSEM* YKSemCreate(int initialValue){
    YKEnterMutex();
    if (YKAvaiSems <= 0){
        YKExitMutex();
        printString("Not enough sems");
        exit(0xff);
    }
    else {
        YKAvaiSems--;
        YKSems[YKAvaiSems].value = initialValue;
        YKSems[YKAvaiSems].blockedOn = 0x0;
    }
    YKExitMutex();

    
    return (&(YKSems[YKAvaiSems]));

}

void YKSemPend(YKSEM *semaphore){
    TCBptr temp, temp2, iter;
    int index;
    
    YKEnterMutex();
    if (semaphore->value-- > 0){
        
        YKExitMutex();
        return;
    }
    
    temp = YKRdyList; 
    
    YKRdyList = temp->next; 
    if (YKRdyList != 0x0)
       YKRdyList->prev = 0x0;
    
    temp->state = 2;
    
    if (semaphore->blockedOn == 0x0){
        semaphore->blockedOn = temp;
        temp->next = 0x0;
        temp->prev = 0x0;
    }
    else{
        iter = semaphore->blockedOn;
        temp2 = 0x0;
        while (iter != 0x0 && iter->priority < temp->priority){
            temp2 = iter;
            iter = iter->next;
        }
        if (iter == 0x0){
            temp2->next = temp;
            temp->prev = temp;
            temp->next = 0x0;
        }
        else{ 
            temp->next = iter;
            temp->prev = temp2;
            iter->prev = temp;
            if (temp2 == 0x0)
                semaphore->blockedOn = temp;
            else
                temp2->next = temp;
        }
    }
    
    YKScheduler(1);
    
    YKExitMutex();
}

void YKSemPost(YKSEM *semaphore){
    TCBptr temp, temp2;
    
    YKEnterMutex();
    if (semaphore->value++ >= 0){
        
        YKExitMutex();
        return;
    }
    
    temp = semaphore->blockedOn;
    semaphore->blockedOn = temp->next;
    if (semaphore->blockedOn != 0x0)
        semaphore->blockedOn->prev = 0x0;
    
    temp->state = 0;
    
    temp2 = YKRdyList;
    while (temp2->priority < temp->priority){
        temp2 = temp2->next;
    }
    if (temp2->prev == 0x0){
        YKRdyList = temp;
    }
    else{
        temp2->prev->next = temp;
    }
    temp->prev = temp2->prev;
    temp->next = temp2;
    temp2->prev = temp;
    
    if (nestingLevel == 0)
        YKScheduler(1);
    
    YKExitMutex();
}

YKQ *YKQCreate(void **start, unsigned size){
    YKEnterMutex();
    if (YKQAvailCount <= 0){
        YKExitMutex();
        exit (0xff);
    }
    YKQAvailCount--;
    YKQs[YKQAvailCount].baseAddress = (void **)start;
    YKQs[YKQAvailCount].numOfEntries = size;
    YKQs[YKQAvailCount].addLoc = 0;
    YKQs[YKQAvailCount].removeLoc = 0;
    YKQs[YKQAvailCount].blockedOn = 0x0;
    YKQs[YKQAvailCount].numOfMsgs = 0;
    YKExitMutex();
    return &(YKQs[YKQAvailCount]);
}

void *YKQPend(YKQ *queue){
    void * tempMsg;
    TCBptr temp, temp2, iter;
    TOP:
    YKEnterMutex();
    if (queue->numOfMsgs > 0){ 
        
        tempMsg = queue->baseAddress[queue->removeLoc];
        queue->removeLoc++;
        
        if (queue->removeLoc >= queue->numOfEntries){
            queue->removeLoc = 0;
        }
        queue->numOfMsgs--;
    }
    else {
        
        temp = YKRdyList; 
        
        YKRdyList = temp->next; 
        if (YKRdyList != 0x0)
            YKRdyList->prev = 0x0;
        
            temp->state = 2;
        
        if (queue->blockedOn == 0x0){
            queue->blockedOn = temp;
            temp->next = 0x0;
            temp->prev = 0x0;
        }
        else{
            iter = queue->blockedOn;
            temp2 = 0x0;
            while (iter != 0x0 && iter->priority < temp->priority){
                temp2 = iter;
                iter = iter->next;
            }
            if (iter == 0x0){
                temp2->next = temp;
                temp->prev = temp;
                temp->next = 0x0;
            }
            else{ 
                temp->next = iter;
                temp->prev = temp2;
                iter->prev = temp;
                if (temp2 == 0x0)
                    queue->blockedOn = temp;
                else
                temp2->next = temp;
            }
        }
        YKScheduler(1);
        goto TOP;
    }
    YKExitMutex();
    return tempMsg;

}

int YKQPost(YKQ *queue, void *msg){
    TCBptr temp, temp2;
    YKEnterMutex();
    if (queue->numOfMsgs < queue->numOfEntries){
        queue->baseAddress[queue->addLoc] = msg;
        
        queue->addLoc++;
        
        if (queue->addLoc >= queue->numOfEntries)
            queue->addLoc = 0;
        queue->numOfMsgs++;
        
        if (queue->blockedOn != 0x0){
            temp = queue->blockedOn;
            queue->blockedOn = temp->next;
            if (queue->blockedOn != 0x0)
                queue->blockedOn->prev = 0x0; 
            
            temp->state = 0;
            
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == 0x0){
                YKRdyList = temp;
            }
            else{
                temp2->prev->next = temp;
            }
            temp->prev = temp2->prev;
            temp->next = temp2;
            temp2->prev = temp;
            
            if (nestingLevel == 0)
                YKScheduler(1);
            }
        
        YKExitMutex();
        return 1;
    }
    else{
        YKExitMutex();
        return 0;
    }

}

YKEVENT *YKEventCreate(unsigned initialValue){
    YKEnterMutex();
    if (YKAvaiEvents <= 0){
        YKExitMutex();
        printString("not enough events\n");
        exit (0xff);
    }
    YKAvaiEvents--;
    YKEvents[YKAvaiEvents].flags = initialValue;
    YKEvents[YKAvaiEvents].waitingOn = 0x0;
    YKExitMutex();
    return &(YKEvents[YKAvaiEvents]);
}

int checkConditions(unsigned eventFlags, unsigned eventMask, int waitMode){
    int conditionMet = 0;
    int i;
    if (waitMode == 1){
        conditionMet = 1;
        
        for (i = 0; i < 16; i++){
            if ((eventMask & (1 << i))){
                if (!(eventFlags & (1 << i))){
                    conditionMet = 0;
                }
            }
        }
    }
    else if (waitMode == 0){
        for (i = 0; i < 16; i++){
            if (eventMask & (1 << i)){
                if (eventFlags & (1 << i)){
                    conditionMet = 1;
                    break;
                }
            }
        }
    }
    else{
        exit(0xff);
    }
    return conditionMet;
}

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode){
    int conditionMet = 0;
    int i;
    unsigned flags;
    TCBptr temp, temp2, iter;
    YKEnterMutex();
    
    conditionMet = checkConditions(event->flags, eventMask, waitMode);

    
    if (conditionMet){
        flags = event->flags;
        YKExitMutex();
        return flags;
    }
    else{
        
        temp = YKRdyList; 
        
        YKRdyList = temp->next; 
        if (YKRdyList != 0x0)
            YKRdyList->prev = 0x0;
        
        temp->state = 2;
        temp->flags = eventMask;
        temp->waitMode = waitMode;
        
        if (event->waitingOn == 0x0){
            event->waitingOn = temp;
            temp->next = 0x0;
            temp->prev = 0x0;
        }
        else{
            iter = event->waitingOn;
            temp2 = 0x0;
            while (iter != 0x0 && iter->priority < temp->priority){
                temp2 = iter;
                iter = iter->next;
            }
            if (iter == 0x0){
                temp2->next = temp;
                temp->prev = temp;
                temp->next = 0x0;
            }
            else{ 
                temp->next = iter;
                temp->prev = temp2;
                iter->prev = temp;
                if (temp2 == 0x0)
                    event->waitingOn = temp;
                else
                temp2->next = temp;
            }
        }
        YKScheduler(1);
        flags = event->flags;
        YKExitMutex();
    }
    return flags;
}

void YKEventSet(YKEVENT *event, unsigned eventMask){
    int i;
    int taskMadeReady = 0;
    TCBptr iter, temp, temp2, next;
    unsigned flags;
    YKEnterMutex();
    
    for (i = 0; i < 16; i++){
        if (eventMask & (1 << i)){
            event->flags |= (1 << i);
        }
    }
    flags = event->flags;
    
    iter = event->waitingOn;
    while (iter != 0x0){
        
        if (checkConditions(flags, iter->flags, iter->waitMode)){
            
            next = iter->next;
            
            if (iter == event->waitingOn){
                event->waitingOn = iter->next;
            }
            if (iter->prev != 0x0)
                iter->prev->next = iter->next;
            if (iter->next != 0x0)
                iter->next->prev = iter->prev;
            
            iter->state = 0;
            
            temp2 = YKRdyList;
            while (temp2->priority < iter->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == 0x0){
                YKRdyList = iter;
            }
            else{
                temp2->prev->next = iter;
            }
            iter->prev = temp2->prev;
            iter->next = temp2;
            temp2->prev = iter;
            taskMadeReady = 1;
            iter = next;
        } else {
            iter = iter->next;
        }
    }
    
    if (taskMadeReady && nestingLevel == 0)
        YKScheduler(1);
    YKExitMutex();
}

void YKEventReset(YKEVENT *event, unsigned eventMask){
    int i;
    YKEnterMutex();
    for (i = 0; i < 16; i++){
        
        if (eventMask & (1 << i)){
            event->flags &= ~((1 << i));
        }
    }
    YKExitMutex();
}
