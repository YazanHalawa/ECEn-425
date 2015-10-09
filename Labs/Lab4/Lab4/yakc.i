# 1 "yakc.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "yakc.c"
# 1 "yakk.h" 1
# 1 "/usr/include/stdint.h" 1 3 4
# 26 "/usr/include/stdint.h" 3 4
# 1 "/usr/include/features.h" 1 3 4
# 361 "/usr/include/features.h" 3 4
# 1 "/usr/include/sys/cdefs.h" 1 3 4
# 373 "/usr/include/sys/cdefs.h" 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 374 "/usr/include/sys/cdefs.h" 2 3 4
# 362 "/usr/include/features.h" 2 3 4
# 385 "/usr/include/features.h" 3 4
# 1 "/usr/include/gnu/stubs.h" 1 3 4



# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 5 "/usr/include/gnu/stubs.h" 2 3 4




# 1 "/usr/include/gnu/stubs-64.h" 1 3 4
# 10 "/usr/include/gnu/stubs.h" 2 3 4
# 386 "/usr/include/features.h" 2 3 4
# 27 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/bits/wchar.h" 1 3 4
# 28 "/usr/include/stdint.h" 2 3 4
# 1 "/usr/include/bits/wordsize.h" 1 3 4
# 29 "/usr/include/stdint.h" 2 3 4
# 37 "/usr/include/stdint.h" 3 4
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;

typedef long int int64_t;







typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;

typedef unsigned int uint32_t;



typedef unsigned long int uint64_t;
# 66 "/usr/include/stdint.h" 3 4
typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef int int_least32_t;

typedef long int int_least64_t;






typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;

typedef unsigned long int uint_least64_t;
# 91 "/usr/include/stdint.h" 3 4
typedef signed char int_fast8_t;

typedef long int int_fast16_t;
typedef long int int_fast32_t;
typedef long int int_fast64_t;
# 104 "/usr/include/stdint.h" 3 4
typedef unsigned char uint_fast8_t;

typedef unsigned long int uint_fast16_t;
typedef unsigned long int uint_fast32_t;
typedef unsigned long int uint_fast64_t;
# 120 "/usr/include/stdint.h" 3 4
typedef long int intptr_t;


typedef unsigned long int uintptr_t;
# 135 "/usr/include/stdint.h" 3 4
typedef long int intmax_t;
typedef unsigned long int uintmax_t;
# 2 "yakk.h" 2
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
# 2 "yakc.c" 2
# 1 "yaku.h" 1
# 3 "yakc.c" 2
# 1 "clib.h" 1



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
# 1 "/usr/lib/gcc/x86_64-redhat-linux/4.4.7/include/stdbool.h" 1 3 4
# 5 "yakc.c" 2



typedef struct taskblock* TCBptr;
typedef struct taskblock
{
 void* startingAddress;
    void* stackptr;
    int state;
    int priority;
    int delay;
    TCBptr next;
    TCBptr prev;
} TCB;

TCBptr YKCurTask;
TCBptr YKRdyList;
TCBptr YKSuspList;
TCBptr YKAvailTCBList;
TCB YKTCBArray[100 +1];

int running;
int idleTaskStkp[128];
int nestingLevel;
unsigned int YKCtxSwCount;
unsigned int YKIdleCount;
unsigned int YKTickNum;

void YKInitialize(void) {

 int i;
 YKCtxSwCount = 0;
 YKIdleCount = 0;
 YKTickNum = 0;
 running = 0;
 nestingLevel = 0;
 YKRdyList = 0;
 YKCurTask = 0;
 YKSuspList = 0;
 YKAvailTCBList = 0;

 YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i <= 100; i++) {
  if (i == 0)
   YKTCBArray[i].prev = 0;
  else
   YKTCBArray[i].prev = &(YKTCBArray[i-1]);
  if (i == 100)
   YKTCBArray[i].next = 0;
  else
   YKTCBArray[i].next = &(YKTCBArray[i+1]);
 }


 YKNewTask(YKIdleTask, (void *)&YKIdleTask[128], 100 +1);
 YKCurTask = &YKTCBArray[101];
 YKCurTask->priority = 101;
 printString("initialization finished\n\r");
}

void YKIdleTask(void) {
 while(1) {
  YKEnterMutex();
  YKIdleCount = YKIdleCount+1;
  YKExitMutex();
 }
}

void YKNewTask(void (* task)(void), unsigned int *taskStack, unsigned char priority) {

 TCBptr tmp, tmp2;


 YKCtxSwCount++;

 tmp = YKAvailTCBList;
    YKAvailTCBList = tmp->next;

 tmp->startingAddress = task;
 tmp->stackptr = taskStack;
 tmp->priority = priority;

 *(taskStack-1) = 0x0200;
 *(taskStack-2) = 0;
 *(taskStack-3) = (int)task;
 *(taskStack-4) = (int)&taskStack[0];
 *(taskStack-5) = 0;
 *(taskStack-6) = 0;
 *(taskStack-7) = 0;
 *(taskStack-8) = 0;
 *(taskStack-9) = 0;
 *(taskStack-10) = 0;
 *(taskStack-11) = 0;
 *(taskStack-12) = 0;




 if (YKRdyList == 0) {
  YKRdyList = tmp;
  tmp->next = 0;
  tmp->prev = 0;

   }
   else {
  tmp2 = YKRdyList;
  while (tmp2->priority < tmp->priority)
   tmp2 = tmp2->next;
  if (tmp2->prev == 0)
   YKRdyList = tmp;
  else
   tmp2->prev->next = tmp;
  tmp->prev = tmp2->prev;
  tmp->next = tmp2;
  tmp2->prev = tmp;
    }




 printString("  priority: ");
 printInt(priority);
 printString("\n\r");
 printString("  YKCurTask->priority: ");
 printInt(YKCurTask->priority);
 printString("\n\r");
 printString("  tmp->priority: ");
 printInt(tmp->priority);
 printString("\n\r");
 if (priority < YKCurTask->priority) {

  YKScheduler();
 } else {
  printString("new task created, but scheduler not called\n\r");
 }
 printString("  YKCurTask->priority is now: ");
 printInt(YKCurTask->priority);
 printString("\n\r");
}

void YKRun(void) {

 running = 1;
 YKScheduler();
}

void YKScheduler() {



 printString("--Starting Dispatcher--\n\r");
 printString("  YKCurTask->priority: ");
 printInt(YKCurTask->priority);
 printString("\n\r");
 printString("  YKRdyList->priority: ");
 printInt(YKRdyList->priority);
 printString("\n\r");
 if (YKCurTask->priority != YKRdyList->priority) {
  if (running) {
   printString("dispatcher called\n\r");
   YKDispatcher();
  } else {
   printString("dispatcher NOT called\n\r");
  }
 } else {
  printString("pointers equal...\n\r");
 }

}
