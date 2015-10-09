#include <stdint.h>
extern unsigned int YKCtxSwCount;
extern unsigned int YKIdleCount;
extern unsigned int YKTickNum;

void YKInitialize(void);

void YKEnterMutex(void);

void YKExitMutex(void);

void YKIdleTask(void);

void YKNewTask(void (* task)(void), unsigned int *taskStack, unsigned char priority);

void YKRun(void);

void YKScheduler();

void YKDispatcher(void);
