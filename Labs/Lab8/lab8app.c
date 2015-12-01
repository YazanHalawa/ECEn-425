/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 7 (Event flags)
*/

#include "clib.h"
#include "yakk.h"                     /* contains kernel definitions */
#include "lab7defs.h"

#define TASK_STACK_SIZE   512         /* stack size in words */


YKSEM* nextCommandPtr;

YKQ* pieceQPtr;
YKQ* moveQPtr;

int placement[TASK_STACK_SIZE];     /* a stack for each task */
int communication[TASK_STACK_SIZE];
int statistics[TASK_STACK_SIZE];

void placementTask(void){ /* Determines sequence of slide and rotate commands */

}

void communicationTask(void){ /* Handles communication with Simptris */

}

void statisticsTask(void){ /* tracks statistics */
    unsigned idleCount, max;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    // Create the tasks here
    YKNewTask(placement, (void*) &placement[TASK_STACK_SIZE], 1);
    YKNewTask(communication, (void*) &communication[TASK_STACK_SIZE], 2);

    while(1){

        YKDelayTask(20);
        
        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<<<<< Context switches: ");
        printInt((int)switchCount);
        printString(", CPU usage: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >>>>>\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
    

}


void main(void)
{
    YKInitialize();

    YKNewTask(statisticsTask, (void *) &statistics[TASK_STACK_SIZE], 0);
    
    YKRun();
}