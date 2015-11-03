#pragma once

#include "clib.h" 
#include "yaku.h"

#define IDLE_STACK_SIZE 2048
#define MAXTASKS 6	// What should this value be...?
#define READY 0
#define RUNNING 1
#define BLOCKED 2
#define FLAGB 0x0200
#define ContextSaved 0
#define ContextNotSaved 1
#define MAXSEMS 


//extern unsigned int YKIdleCount;
//extern unsigned int YKCtxSwCount;

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

TCBptr YKRdyList;       /* a list of TCBs of all ready tasks*/
TCBptr YKCurTask;       //points to current task
                //   in order of decreasing priority 
TCBptr YKSuspList;      /* tasks delayed or suspended */
TCBptr YKAvailTCBList;      /* a list of available TCBs */
TCB    YKTCBArray[MAXTASKS+1];  /* array to allocate all needed TCBs (extra one is for the idle task) */

unsigned int running;
int idleStk[IDLE_STACK_SIZE];
unsigned int YKIdleCount;
unsigned int YKCtxSwCount;
unsigned int nestingLevel;
unsigned int YKTickNum;

YKSEM YKSems[MAXSEMS]; // array of semaphores
int YKAvaiSems; // unused semaphores

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

