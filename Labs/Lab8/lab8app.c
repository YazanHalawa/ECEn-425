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

void placementTask(void){

}

void communicationTask(void){

}

void statisticsTask(void){
    
}


void main(void)
{
    YKInitialize();

    charEvent = YKEventCreate(0);
    numEvent = YKEventCreate(0);
    YKNewTask(STask, (void *) &STaskStk[TASK_STACK_SIZE], 0);
    
    YKRun();
}