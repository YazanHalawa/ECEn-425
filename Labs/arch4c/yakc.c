yakc

/* YAK kernel functions that are written in C
 (c) James Archibald, Brigham Young University, September 2002
 */

#define MAINSEG 1
#include "yakk.h"
#include "yaku.h"
#include "clib.h"

#define CTXSAVED    0
#define CTXNOTSAVED 1
#define POSTQSUCCESS 1
#define POSTQFAILURE 0
#define NULL 0x0

/* #define DEBUG 1 */

/* global declarations */

unsigned YKIntNestLevel;    /* tracks ISR nesting */
unsigned YKRunFlag;        /* marks task execution phase */
unsigned YKIdleCount;        /* the idle task's counter */
unsigned YKCtxSwCount;        /* context switch counter */
unsigned YKTickNum;        /* counts number of ticks */
TCBptr YKCurrTask;        /* a pointer to TCB of current task */
TCBptr YKRdyList;        /* a list of TCBs of all ready tasks
                          in order of decreasing priority */
TCBptr YKSuspList;        /* tasks delayed or suspended */
TCBptr YKAvailTCBList;        /* a list of available TCBs */
TCB YKTCBArray[MAXTASKS+1];    /* array to allocate all needed TCBs */
char IdleStk[IDLESTKSIZE];    /* stack for the idle task */
YKSEM YKSemArray[MAXSEMS];    /* array to hold all semaphores */
int YKSAvailCount;        /* count of unused semaphores */
YKQ YKQArray[MAXQUEUES];    /* array to hold all q mgt structs */
int YKQAvailCount;        /* count of unused q mgt structs */

void YKInitIMR(unsigned mask);

#ifdef DEBUG
void YKDumpLists(void)        /* used only for debugging */
{
    TCBptr tmp, tmp2;
    int i;
    
    printString("\n  YKCurrTask: [");
    printInt(YKCurrTask->priority);
    printString(", ");
    printInt(YKCurrTask->state);
    printString(", ");
    printInt(YKCurrTask->delay);
    printString("]\n");
    
    tmp = YKRdyList;
    tmp2 = NULL;
    printString("  Rdy: ");
    while (tmp != NULL)
    {
        printString("[");
        printInt(tmp->priority);
        printString(", ");
        printInt(tmp->state);
        printString(", ");
        printInt(tmp->delay);
        if (tmp->prev != tmp2)
            printString("X] ");
        else
            printString("] ");
        tmp2 = tmp;
        tmp = tmp->next;
    }
    printString("\n  Susp: ");
    tmp = YKSuspList;
    tmp2 = NULL;
    while (tmp != NULL)
    {
        printString("[");
        printInt(tmp->priority);
        printString(", ");
        printInt(tmp->state);
        printString(", ");
        printInt(tmp->delay);
        if (tmp->prev != tmp2)
            printString("X] ");
        else
            printString("] ");
        tmp2 = tmp;
        tmp = tmp->next;
    }
    printNewLine();
    for (i = YKAvailCount; i < MAXSEMS; i++)
    {
        tmp = YKSemArray[i].pend;
        tmp2 = NULL;
        printString("  Sem");
        printInt(i);
        printString(": ");
        while (tmp != NULL)
        {
            printString("[");
            printInt(tmp->priority);
            printString(", ");
            printInt(tmp->state);
            printString(", ");
            printInt(tmp->delay);
            tmp2 = tmp;
            tmp = tmp->next;
        }
        printNewLine();
    }
}

void YKDumpPtrs(void)
{
    printString("YKRdyList: ");
    printInt(YKRdyList->priority);
    printString(" [0x");
    printWord((int) YKRdyList);
    printString("]   YKCurrTask: ");
    printInt(YKCurrTask->priority);
    printString(" [0x");
    printWord((int ) YKCurrTask);
    printString("] \n");
}
#endif

/* YKScheduler calls the dispatcher if the highest priority ready task
 is different from the task currently executing.  Because the ready
 list is sorted by decreasing priority, the next task to run is
 always at the head of the list; this makes the scheduler very
 simple.  It is assumed that the scheduler is never called until
 YKRunFlag is set -- by tests at point of call -- so I don't have to
 test within the function itself.  The parameter to the scheduler
 indicates whether the context of the current task needs to be saved
 or not.  0 (CTXSAVED) ==> already saved, 1 (CTXNOTSAVED) ==> must
 still save context.  Note that the scheduler simply returns if no
 context switch is required.  It is assumed that interrupts are
 disabled when the scheduler is called. */

void YKScheduler(int i)
{
#ifdef DEBUG
    YKDumpLists();        /* debug use only */
    YKDumpPtrs();        /* debug use only */
#endif
    if (YKRdyList != YKCurrTask)
    {
        YKCtxSwCount++;
        YKDispatcher(i);
    }
}

/* YKEnterISR must be called near the entry point of each ISR, while
 still in a critical section.  If it is called after interrupts are
 enabled, a higher priority interrupt may occur before the nesting
 level count is incremented, and the scheduler will run when that
 ISR finishes, since it has no way of knowing that this ISR was
 running.  As can be seen, this routine simply increments a global
 counter to indicate that an ISR is currently executing.  The access
 to the global variable does not have to be in critical sections
 because interrupts must be disabled at the point of call.
 */

void YKEnterISR(void)
{
    YKIntNestLevel++;
}

/* YKExitISR must be called near the exit point of each ISR, after
 interrupts are disabled in the final critical section.  It
 decrements the counter that was incremented when the ISR was
 entered, and if it is the "last" ISR currently active, it calls the
 scheduler to make sure the task returned to is the highest priority
 task ready.  This is important because the interrupt handler may
 have taken actions that made one or more tasks ready to run.  */

void YKExitISR(void)
{
    if (--YKIntNestLevel == 0)
    {
        YKScheduler(CTXSAVED);
    }
}

/* YKIdleTask is the lowest priority task in the system, created
 transparently to the user code, and it is always ready to run.
 (Thus, it can never delay itself, or pend on a semaphore, or
 anything that would remove it from the ready list.)  This task
 guarantees that the ready list is non-empty, and it will be used in
 the future to determine CPU utilization. */

void YKIdleTask(void)
{
    while (1)
    {
        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }
}

/* YKNewTask creates a new task, initializes its TCB, and then calls
 the scheduler in case the task just created is the highest
 priority ready task.  In this version of the kernel, contexts are
 saved on the stack.  To simplify the dispatcher, it always assumes
 the context for the task to be dispatched is stored in the same
 way.  To make this work for a new task on first execution, the
 initial context must be stored on the stack.  This is done by
 YKNewTask.
 */

void YKNewTask(void (* task) (void),  void *stackptr, unsigned char priority)
{
    TCBptr tmp, tmp2;
    int i;
    unsigned *stktmp;
#ifdef DEBUG
    printString("In YKNewTask: stackptr is ");
    printWord((int) stackptr);
    printString(", taskptr is ");
    printWord((int) task);
    printString(", priority is ");
    printInt((int) priority);
    printNewLine();
#endif DEBUG
    YKEnterMutex();
    tmp = YKAvailTCBList;    /* get a TCB from avail list */
    if (tmp == NULL)
    {
        printString("Ran out of TCB's\n");
        exit(0xff);
    }
    YKAvailTCBList = tmp->next;
    tmp->state = READY;        /* initialize it */
    tmp->priority = priority;
    tmp->delay = 0;
    if (YKRdyList == NULL)    /* first insertion finds empty list */
    {
        YKRdyList = tmp;
        tmp->next = NULL;
        tmp->prev = NULL;
    }
    else            /* at least idle task is present */
    {
        tmp2 = YKRdyList;    /* insert in sorted ready list */
        while (tmp2->priority < tmp->priority)
            tmp2 = tmp2->next;    /* assumes idle task is at end */
        if (tmp2->prev == NULL)
            YKRdyList = tmp;
        else
            tmp2->prev->next = tmp;
        tmp->prev = tmp2->prev;
        tmp->next = tmp2;
        tmp2->prev = tmp;
    }
    
    /* store an initial context on the stack so dispatchers can always
     use the same technique in restoring a context.  THIS CODE IS
     PLATFORM SPECIFIC AND NEEDS TO BE MODIFIED FOR EACH NEW
     IMPLEMENTATION! */
    stktmp = (unsigned *) stackptr;
    stktmp -= 13;        /* create space for iret and context frames */
    for (i = 0; i < 13; i++)    /* default: all regs are set to zero */
        stktmp[i] = 0;
    /* now initialize non-zero values: IMR, IP, and flags */
    stktmp[9]  = (unsigned) INITIMRMASK;/* initial IMR value */
    stktmp[10] = (unsigned) task; /* IP in iret frame */
    stktmp[12] = (unsigned) FLAGBITS;/* init flag register, with IF set */
    tmp->stackptr = (void *) stktmp; /* save new stack ptr in TCB */
    
    if (YKRunFlag)
        YKScheduler(CTXNOTSAVED);
    
    YKExitMutex();
}

/* YKInitialize needs to take care of any and all initialization of
 global variables before the first call to any other kernel
 functions.  The routine creates a list of unused TCBs that will be
 used as tasks are created.  Interrupts are disabled until execution
 actually begins after YKRun is called.  YKInitialize also creates
 the idle task.  */

void YKInitialize(void)
{
    int i;
    YKEnterMutex();        /* interrupts off until YKRun executes */
    YKInitIMR(INITIMRMASK);    /* sets IMR to specified mask value */
    YKIntNestLevel = 0;
    YKRunFlag = 0;
    YKIdleCount = 0;
    YKTickNum = 0;
    YKCtxSwCount = 0;
    YKCurrTask = NULL;
    YKRdyList = NULL;
    YKSuspList = NULL;
    YKSAvailCount = MAXSEMS;
    YKQAvailCount = MAXQUEUES;
    
    /* create linked list of available TCBs */
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < MAXTASKS; i++)
    {
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[i].prev = NULL;
    }
    YKTCBArray[MAXTASKS].next = NULL;
    YKTCBArray[MAXTASKS].prev = NULL;
    
    /* create idle task */
    YKNewTask(YKIdleTask, (void *) &(IdleStk[IDLESTKSIZE]), 63);
}

/* YKRun marks the end of the first phase of execution and the
 beginning of the second when tasks and ISRs begin to execute.
 Control is never returned to the main function in the C code.  From
 this point on, only task code runs, always the highest priority
 ready task at any point.  Prior to this point, interrupts should be
 ignored (since the routines to handle them may be a part of tasks
 that do not yet exist).  This routine ends by transferring control
 to the highest priority ready task.  It is assumed that the
 dispatcher will enable interrupts at the right point in time. */

void YKRun(void)
{
    YKRunFlag = 1;
    YKScheduler(CTXSAVED);
}

/* YKDelayTask delays a task for specified number of clock ticks.
 After the bookkeeping is completed, it calls the scheduler.  */

void YKDelayTask(int ticks)
{
    TCBptr tmp;
    YKEnterMutex();
    tmp = YKRdyList;        /* get ptr to TCB to change */
    YKRdyList = tmp->next;    /* remove from ready list */
    tmp->next->prev = NULL;
    tmp->state = DELAYED;    /* change state */
    tmp->delay = ticks;        /* initialize delay counter */
    tmp->next = YKSuspList;    /* put at head of delayed list */
    YKSuspList = tmp;
    tmp->prev = NULL;
    if (tmp->next != NULL)
        tmp->next->prev = tmp;
    YKScheduler(CTXNOTSAVED);
    YKExitMutex();
}

/* YKTickHandler scans the list of delayed tasks, decrementing the
 number of ticks each must still wait before it is awakened.  If the
 counter reaches zero, the state is changed to ready and the task is
 put in the ready list.
 */

void YKTickHandler(void)
{
    TCBptr tmp, tmp2, nxt;
    YKTickNum++;
    tmp = YKSuspList;
    while (tmp != NULL)
    {
        tmp->delay--;
        if (tmp->delay == 0)
        {
            tmp->state = READY;    /* update state */
            nxt = tmp->next;    /* save next link */
            
            /* remove from SuspList */
            if (tmp->prev == NULL)
                YKSuspList = tmp->next;
            else
                tmp->prev->next = tmp->next;
            if (tmp->next != NULL)
                tmp->next->prev = tmp->prev;
            
            /* put in RdyList (idle task always at end) */
            tmp2 = YKRdyList;
            while (tmp2->priority < tmp->priority)
                tmp2 = tmp2->next;
            if (tmp2->prev == NULL)
                YKRdyList = tmp;
            else
                tmp2->prev->next = tmp;
            tmp->prev = tmp2->prev;
            tmp->next = tmp2;
            tmp2->prev = tmp;
            
            /* update pointer to next link on old list */
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
        /* remove from ready list */
        tmp = YKRdyList;
        YKRdyList = tmp->next;
        tmp->next->prev = NULL;
        
        /* update state */
        tmp->state = PENDING;
        
        /* put in sorted waiting list for this semaphore */
        if (sem->pend == NULL)    /* is this the first entry? */
        {
            sem->pend = tmp;
            tmp->next = NULL;
            tmp->prev = NULL;
        }
        else            /* list is non-empty */
        {            /* find place in sorted list */
            tmp2 = sem->pend;
            tmp3 = NULL;
            while (tmp2 != NULL && tmp2->priority < tmp->priority)
            {
                tmp3 = tmp2;
                tmp2 = tmp2->next;
            }
            if (tmp2 == NULL)
            {            /* insert at end of list */
                tmp3->next = tmp;
                tmp->prev = tmp3;
                tmp->next = NULL;
            }
            else
            {            /* insert before tmp2 */
                tmp->next = tmp2;
                tmp->prev = tmp3;
                tmp2->prev = tmp;
                if (tmp3 == NULL)
                    sem->pend = tmp;
                else
                    tmp3->next = tmp;
            }
        }
        YKScheduler(CTXNOTSAVED);
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
        /* remove highest priority task from pending list */
        TCBptr tmp, tmp2;
        tmp = sem->pend;
        sem->pend = tmp->next;
        if (sem->pend != NULL)
            sem->pend->prev = NULL;
        
        /* update state */
        tmp->state = READY;
        
        /* and put in ready list */
        tmp2 = YKRdyList;
        while (tmp2->priority < tmp->priority)
            tmp2 = tmp2->next;
        if (tmp2->prev == NULL)
            YKRdyList = tmp;
        else
            tmp2->prev->next = tmp;
        tmp->prev = tmp2->prev;
        tmp->next = tmp2;
        tmp2->prev = tmp;
        
        /* call scheduler only if this not called from ISR */
        if (YKIntNestLevel == 0)
            YKScheduler(CTXNOTSAVED);
        YKExitMutex();
    }
    
}

YKSEM * YKSemCreate(int value)
{
    YKEnterMutex();
    /* get next free semaphore struct */
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
        YKSemArray[YKSAvailCount].pend = NULL;
    }
    YKExitMutex();
    return (&(YKSemArray[YKSAvailCount]));
}

void *YKQPend(YKQ *queue)
{
    void *msgtmp;
TOP:
    YKEnterMutex();
    /* is there a message in the queue? */
    if (queue->msgcount > 0)
    {                /* return oldest msg */
        msgtmp = queue->start[queue->next_out];
        queue->next_out++;
        if (queue->next_out >= queue->qsize)
            queue->next_out = 0;
        queue->msgcount--;
    }
    else
    {                /* suspend this task */
        TCBptr tmp, tmp2, tmp3;
        /* remove from ready list */
        tmp = YKRdyList;
        YKRdyList = tmp->next;
        tmp->next->prev = NULL;
        
        /* update state */
        tmp->state = PENDING;
        
        /* put in sorted waiting list for this queue */
        if (queue->pend == NULL) /* is this the first entry? */
        {
            queue->pend = tmp;
            tmp->next = NULL;
            tmp->prev = NULL;
        }
        else            /* list is non-empty */
        {            /* find place in sorted list */
            tmp2 = queue->pend;
            tmp3 = NULL;
            while (tmp2 != NULL && tmp2->priority < tmp->priority)
            {
                
                tmp3 = tmp2;
                tmp2 = tmp2->next;
            }
            if (tmp2 == NULL)
            {            /* insert at end of list */
                tmp3->next = tmp;
                tmp->prev = tmp3;
                tmp->next = NULL;
            }
            else
            {            /* insert before tmp2 */
                tmp->next = tmp2;
                tmp->prev = tmp3;
                tmp2->prev = tmp;
                if (tmp3 == NULL)
                    queue->pend = tmp;
                else
                    tmp3->next = tmp;
            }
        }
        YKScheduler(CTXNOTSAVED);
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
        return POSTQFAILURE;    /* queue is full */
    }
    else
    {                /* post message */
        queue->start[queue->next_in] = msg;
        queue->next_in++;
        if (queue->next_in >= queue->qsize)
            queue->next_in = 0;
        queue->msgcount++;
        if (queue->pend != NULL)
        {            /* make top task ready */
            TCBptr tmp, tmp2;
            tmp = queue->pend;
            queue->pend = tmp->next;
            if (queue->pend != NULL)
                queue->pend->prev = NULL;
            /* update state */
            tmp->state = READY;
            
            /* and put in ready list */
            tmp2 = YKRdyList;
            while (tmp2->priority < tmp->priority)
                tmp2 = tmp2->next;
            if (tmp2->prev == NULL)
                YKRdyList = tmp;
            else
                tmp2->prev->next = tmp;
            tmp->prev = tmp2->prev;
            tmp->next = tmp2;
            tmp2->prev = tmp;
            
            /* call scheduler only if this not called from ISR */
            if (YKIntNestLevel == 0)
                YKScheduler(CTXNOTSAVED);
        }
        YKExitMutex();
        return POSTQSUCCESS;
    }
}

YKQ * YKQCreate(void *start, int size)
{
    YKEnterMutex();
    /* get next free queue management struct */
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
        YKQArray[YKQAvailCount].pend = NULL;
    }
    YKExitMutex();
    return &(YKQArray[YKQAvailCount]);
}
