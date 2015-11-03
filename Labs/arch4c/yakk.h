/* YAK kernel definitions and #defines that are used in kernel
 and user routines.  The application programmer should not need to
 modify this file.
 
 (c) James Archibald, Brigham Young University, November 1998  */

#define READY    1
#define PENDING  3
#define DELAYED  5

typedef struct taskblock *TCBptr;
typedef struct taskblock
{                /* the TCB struct definition */
    void *stackptr;        /* pointer to current top of stack */
    int state;            /* current state */
    int priority;        /* current priority */
    int delay;            /* #ticks yet to wait */
    TCBptr next;        /* forward ptr for dbl linked list */
    TCBptr prev;        /* backward ptr for dbl linked list */
}  TCB;

typedef struct semaphore
{
    int value;            /* the numerical value */
    TCBptr pend;        /* a list of pending TCBs */
}  YKSEM;

typedef struct msgqueue
{
    void **start;        /* starting address of queue */
    int next_in;        /* next slot to insert into */
    int next_out;        /* next slot to remove from */
    int qsize;            /* total size of queue */
    int msgcount;        /* #slots empty */
    TCBptr pend;        /* a list of pending TCBs */
}  YKQ;

/* kernel function prototypes */
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

#ifndef MAINSEG
extern unsigned YKIdleCount;
extern unsigned YKCtxSwCount;
extern unsigned YKTickNum;
#endif
