#include "yakk.h"
#include "yaku.h"
#include "clib.h"
#include <stdbool.h>
#include <stdint.h>


typedef struct taskblock* TCBptr;
typedef struct taskblock
{				/* the TCB struct definition */
	void* startingAddress;
    void* stackptr;		/* pointer to current top of stack */
    int state;			/* current state */
    unsigned char priority;		/* current priority */
    int delay;			/* #ticks yet to wait */
    TCBptr next;		/* forward ptr for dbl linked list */
    TCBptr prev;		/* backward ptr for dbl linked list */
}  TCB;

TCBptr YKCurTask;
TCBptr YKRdyList;				/* a list of TCBs of all ready tasks in order of decreasing priority */ 
TCBptr YKSuspList;				/* tasks delayed or suspended */
TCBptr YKAvailTCBList;			/* a list of available TCBs */
TCB    YKTCBArray[MAX_TASKS+1];	/* array to allocate all needed TCBs (extra one is for the idle task) */

int running;
int idleTaskStkp[IDLE_TASK_STACK_SIZE];
int nestingLevel;
unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
unsigned int YKTickNum;

void YKInitialize(void) {
	// Code to initialize global variables
	int i;
	YKCtxSwCount = 0;
	YKIdleCount = 0;
	YKTickNum = 0;
	running = 0;
	nestingLevel = 0;
	YKRdyList = NULL;
	YKCurTask = NULL;
	YKSuspList = NULL;
	YKAvailTCBList = NULL;
	// Code to create doubly linked list
	//YKRdyList = &(YKTCBArray[0]);
   	for (i = 0; i <= MAX_TASKS; i++) {
		if (i == 0) 	// first node in list
			YKTCBArray[i].prev = NULL;
		else
			YKTCBArray[i].prev = &(YKTCBArray[i-1]);
		if (i == MAX_TASKS)	// last node in list
			YKTCBArray[i].next = NULL;
		else
			YKTCBArray[i].next = &(YKTCBArray[i+1]);
	}


	YKNewTask(YKIdleTask,  (void *)&YKIdleTask[IDLE_TASK_STACK_SIZE], MAX_TASKS+1);
	//YKCurTask = &YKTCBArray[101];	// this needs to be fixed
	//YKCurTask->priority = 101; // this is a hack, fix later
	printString("initialization finished\n\r");
}

void YKIdleTask(void) {
	printString("-in Idle Task\n\r");	// remove this later	
	while(1) {
		YKEnterMutex();
		YKIdleCount = YKIdleCount+1;
		YKExitMutex();
	}
}

void YKNewTask(void (* task)(void), void *taskStack, unsigned char priority) {

	/* Create the Task’s TCB
	   Call the Scheduler to see if a higher priority interrupt should run */
	TCBptr insertion, iter;
	//tmp = YKAvailTCBList;
    	//YKAvailTCBList = tmp->next;

	insertion->startingAddress = task;
	insertion->stackptr = taskStack;
	insertion->priority = priority;
	
	//printString("task: ");
	//printInt((int)task);
	//printString("\n\r");
	
	// initialize the stack to all 0
	/*
	*(taskStack-1) = 0x0200;
	*(taskStack-2) = 0;
	*(taskStack-3) = (char)task;
	*(taskStack-4) = (char)&taskStack[0];
	*(taskStack-5) = 0;
	*(taskStack-6) = 0;
	*(taskStack-7) = 0;
	*(taskStack-8) = 0;
	*(taskStack-9) = 0;
	*(taskStack-10) = 0;
	*(taskStack-11) = 0;
	*(taskStack-12) = 0;
	*/

    /* code to insert an entry in doubly linked ready list sorted by
       priority numbers (lowest number first).  tmp points to TCB
       to be inserted */ 
	if (YKRdyList == NULL) { /* is this first insertion? */
		YKRdyList = insertion;
		insertion->next = NULL;
		insertion->prev = NULL;
		
  	}
  	else {				/* not first insertion */
		iter = YKRdyList;	/* insert in sorted ready list */
		while (iter->next != NULL && iter->next->priority < insertion->priority) {
			iter = iter->next;	/* assumes idle task is at end */
		}
		if (iter->next != NULL) {
			iter->next->prev = insertion;
		}
		insertion->next = iter->next;
		iter->next = insertion;
		insertion->prev = iter;
		
    }
	



	printString("  priority: ");
	printChar(priority);
	printString("\n\r");
	printString("  YKCurTask->priority: ");
	printChar(YKCurTask->priority);
	printString("\n\r");
	if (YKCurTask != NULL && priority < YKCurTask->priority) {
		// YKCurTask = tmp; // do not uncomment
		YKScheduler();
	} else {
		printString("new task created, but scheduler not called\n\r");
	}
	printString("  YKCurTask->priority is now: ");
	printChar(YKCurTask->priority);
	printString("\n\r");
}

void YKRun(void) {
	/* Set global flag to indicate kernel started */
	running = 1;
	YKScheduler();
}

void YKScheduler() {
	//YKEnterMutex();
	/* If (current task.priority != highestPriorityReadyTask.priority)
	Call Dispatcher to run highest priority ready task. */
	printString("--Starting Dispatcher--\n\r");
	printString("  YKCurTask->priority: ");
	printInt(YKCurTask->priority);
	printString("\n\r");
	printString("  YKRdyList->priority: ");
	printInt(YKRdyList->priority);
	printString("\n\r");
	if (YKCurTask != YKRdyList) { 
		if (running) {
			printString("dispatcher called\n\r");
			YKCtxSwCount++; // Context switch happens here right?
			YKDispatcher();
		} else {
			printString("dispatcher NOT called\n\r");
		}
	} else {
		printString("pointers equal...\n\r");
	}
	//YKExitMutex();
}
