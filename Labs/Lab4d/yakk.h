#define IDLE_STACK_SIZE 2048
#define MAXTASKS 4	// What should this value be...?
#define READY 0
#define RUNNING 1
#define BLOCKED 2
#define FLAGB 0x0200
#define ContextSaved 0
#define ContextNotSaved 1

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

