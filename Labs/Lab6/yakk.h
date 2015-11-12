#ifndef YAKK_H_
#define YAKK_H_

#include "clib.h" 
#include "yaku.h"

#define IDLE_STACK_SIZE 2048
#define MAXTASKS 3	
#define READY 0
#define RUNNING 1
#define BLOCKED 2
#define FLAGB 0x0200
#define ContextSaved 0
#define ContextNotSaved 1
#define MAXSEMS 4
#define MAXQUEUES 1

typedef struct taskblock *TCBptr;
typedef struct taskblock
{
                /* the TCB struct definition */
    void *stackptr;     /* pointer to current top of stack */
    int state;          /* current state */
    int priority;       /* current priority */
    unsigned delay;          /* #ticks yet to wait */
    TCBptr next;        /* forward ptr for dbl linked list */
    TCBptr prev;        /* backward ptr for dbl linked list */
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


#endif /* YAKK_H_ */