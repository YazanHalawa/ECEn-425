#include "yaku.h"
#include "yakk.h"
#include "clib.h" 

typedef struct taskblock *TCBptr;
typedef struct taskblock
{
                /* the TCB struct definition */
    void *stackptr;     /* pointer to current top of stack */
    int state;          /* current state */
    int priority;       /* current priority */
    int delay;          /* #ticks yet to wait */
    TCBptr next;        /* forward ptr for dbl linked list */
    TCBptr prev;        /* backward ptr for dbl linked list */
}  TCB;

TCBptr YKRdyList;       /* a list of TCBs of all ready tasks*/
TCBptr YKCurTask;       //points to current task
                //   in order of decreasing priority 
TCBptr YKSuspList;      /* tasks delayed or suspended */
TCBptr YKAvailTCBList;      /* a list of available TCBs */
TCB    YKTCBArray[MAXTASKS+1];  /* array to allocate all needed TCBs (extra one is for the idle task) */

unsigned int running;
int idleStk[IDLE_STACK_SIZE];
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
    YKCurTask = NULL;
    YKRdyList = NULL;
    YKSuspList = NULL;
    YKTickNum = 0;

	// Code to create doubly linked list
   	/*for (i = 0; i <= MAX_TASKS; i++) {
		if (i == 0) 	// first node in list
			YKTCBArray[i].prev = NULL;
		else
			YKTCBArray[i].prev = &(YKTCBArray[i-1]);
		if (i == MAX_TASKS)	// last node in list
			YKTCBArray[i].next = NULL;
		else
			YKTCBArray[i].next = &(YKTCBArray[i+1]);
	}*/
	
	// Initialize locations for TCB
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < MAXTASKS; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[MAXTASKS].prev = NULL; 
    }
    YKTCBArray[MAXTASKS].next = NULL;
    YKTCBArray[MAXTASKS].prev = NULL;

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100);  
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
    
    if(insertion == NULL){
        return;
    } 
    
    YKAvailTCBList =  insertion->next;   
     
    insertion->state = READY;
    insertion->priority = priority;
    insertion->delay = 0;
 
    if (YKRdyList == NULL)  /* is this first insertion? */
    {
        YKRdyList = insertion;
        insertion->next = NULL;
        insertion->prev = NULL;
    }
    else            /* not first insertion */
    {
        iter2 = YKRdyList;   /* insert in sorted ready list */
        while (iter2->priority < insertion->priority)
            iter2 = iter2->next;  /* assumes idle task is at end */
        if (iter2->prev == NULL) /* insert in list before tmp2 */
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
			stackIter[i] = FLAGB;	// Set the interrupt flag
		} else {
			stackIter[i] = 0;
		}
	}	
    insertion->stackptr = (void *)stackIter;
	/*
	printString("  priority: ");
	printInt(priority);
	printString("\n\r");
	printString("  YKCurTask->priority: ");
	printInt(YKCurTask->priority);
	printString("\n\r");
	*/

	if(running == 1) {
 		YKScheduler(saveContext);
	} else {
		//printString("new task created, but scheduler not called\n\r");
	}    
    YKExitMutex();
}

void YKRun(){
	// Run the tasks
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
	// Bookkeeping for change of state
	// Call the scheduler after specified number of ticks

	if (count == 0) {
		return;
	}
	YKEnterMutex();
    temp = YKRdyList; // Hold the first ready task

    // Remove it from Ready list
    YKRdyList = temp->next; 
	temp->next->prev = NULL;
    temp->state = BLOCKED;
    temp->delay = count;

    // Put at head of Susp List
    temp->next = YKSuspList;
    YKSuspList = temp;
    temp->prev = NULL;
    if (temp->next != NULL)
        temp->next->prev = temp;
	YKScheduler(1);
	YKExitMutex();
}

void YKTickHandler(void){
    TCBptr temp, temp2, next;
    YKTickNum++;
    temp = YKSuspList;
    while (temp != NULL){
        printString("in while\n");
        temp->delay--;
        if (temp->delay == 0){ // If the task has delayed the appropriate amount of ticks
            temp->state = READY; // Make the task ready
            next = temp->next; // Store the temp's next so you don't lose it
            printString("about to remove\n");
            // Remove from Susp List
            if (temp->prev == NULL){
                YKSuspList = temp->next;
            }
            else{
                if (temp->next != NULL){
                    temp->next->prev = temp->prev;
                }
                temp->prev->next = temp->next;
            }

            printString("about to put\n");
            // Put in Rdy List
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
                printString("in While prio\n");
            }
            if (temp2->prev = NULL){
                YKRdyList = temp;
            }
            else{
                temp2->prev->next = temp;
            }
            temp->prev = temp2->prev;
            temp->next = temp2;
            temp2->prev = temp;
            // Update the next pointer 
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
		YKScheduler(0);	// are we sure this is what we pass in?
	}
}
