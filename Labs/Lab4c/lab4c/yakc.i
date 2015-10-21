# 1 "yakc.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "yakc.c" 2
# 1 "./yaku.h" 1
# 2 "yakc.c" 2
# 1 "./yakk.h" 1







extern unsigned int YKIdleCount;
extern unsigned int YKCtxSwCount;

void YKInitialize();

void YKEnterMutex();

void YKExitMutex();

void YKIdleTask();

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority);

void YKRun();

void YKScheduler(int saveContext);

void YKDispatcher(int saveContext);

void YKIMRInit(unsigned a);

void YKEnterISR();

void YKExitISR();

void YKTickHandler(void);

void YKDelayTask(unsigned count);
# 3 "yakc.c" 2
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


# 4 "yakc.c" 2

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

TCBptr YKRdyList;       
TCBptr YKCurTask;       
                
TCBptr YKSuspList;      
TCBptr YKAvailTCBList;      
TCB    YKTCBArray[3 +1];  

unsigned int running;
int idleStk[1024];
int saveContext;
unsigned int YKIdleCount;
unsigned int YKCtxSwCount;
unsigned int nestingLevel;
unsigned int YKTickNum;


void YKInitialize (){
    int i;
    YKEnterMutex();
    YKIMRInit(0x00);
    running = 0;
    saveContext = 0;
    YKIdleCount = 0;
    YKCtxSwCount = 0;
    nestingLevel = 0;
    YKCurTask = 0;
    YKRdyList = 0;
    YKSuspList = 0;
    YKTickNum = 0;

	
   	
# 57 "yakc.c"

	
	
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < 3; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[3].prev = 0; 
    }
    YKTCBArray[3].next = 0;
    YKTCBArray[3].prev = 0;

    YKNewTask(YKIdleTask,(void *) &(idleStk[1024]),100);  
}

void YKIdleTask(){
	printString("in IdleTask\n\r");
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
    
    if(insertion == 0){
        return;
    } 
    
    YKAvailTCBList =  insertion->next;   
     
    insertion->state = 0;
    insertion->priority = priority;
    insertion->delay = 0;
 
    if (YKRdyList == 0)  
    {
        YKRdyList = insertion;
        insertion->next = 0;
        insertion->prev = 0;
    }
    else            
    {
        iter2 = YKRdyList;   
        while (iter2->priority < insertion->priority)
            iter2 = iter2->next;  
        if (iter2->prev == 0) 
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
 		YKScheduler(saveContext);
	} else {
		
	}    
    YKExitMutex();
}

void YKRun(){
	
    running = 1;
    saveContext = 1;
    YKScheduler(saveContext);
}

void YKScheduler(int saveContext){
    if(YKRdyList != YKCurTask){  
        YKCtxSwCount++; 
        YKDispatcher(saveContext);
    }
}

void YKDelayTask(unsigned count){
    TCBptr temp;
	
	

	if (count == 0) {
		return;
	}
	YKEnterMutex();
    temp = YKRdyList; 

    
    YKRdyList = temp->next; 
	temp->next->prev = 0;
    temp->state = 2;
    temp->delay = count;

    
    temp->next = YKSuspList;
    YKSuspList = temp;
    temp->prev = 0;
    if (temp->next != 0)
        temp->next->prev = temp;
	YKScheduler(1);
	YKExitMutex();
}

void YKTickHandler(void){
    TCBptr temp, temp2, next;
    YKTickNum++;
    temp = YKSuspList;
    while (temp != 0){
        printString("in while\n");
        temp->delay--;
        if (temp->delay == 0){ 
            temp->state = 0; 
            next = temp->next; 
            printString("about to remove\n");
            
            if (temp->prev == 0){
                YKSuspList = temp->next;
            }
            else{
                if (temp->next != 0){
                    temp->next->prev = temp->prev;
                }
                temp->prev->next = temp->next;
            }

            printString("about to put\n");
            
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
                printString("in While prio\n");
            }
            if (temp2->prev = 0){
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
}

void YKEnterISR() {
	nestingLevel++;
}

void YKExitISR() {
	nestingLevel--;
	if (nestingLevel == 0) {
		YKScheduler(0);	
	}
}

