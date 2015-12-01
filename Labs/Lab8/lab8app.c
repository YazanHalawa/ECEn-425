/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 8 (Simptris)
*/

#include "clib.h"
#include "yakk.h"                     /* contains kernel definitions */
#include "lab7defs.h"

#define TASK_STACK_SIZE   512         /* stack size in words */
#define pieceQSize 10
#define moveQSize 10

YKSEM* nextCommandPtr;

void *pieceQ[pieceQSize];           /* space for piece queue */
YKQ* pieceQPtr;

void *moveQ[moveQSize];             /* space for move queue */
YKQ* moveQPtr;

int placement[TASK_STACK_SIZE];     /* a stack for each task */
int communication[TASK_STACK_SIZE];
int statistics[TASK_STACK_SIZE];

// variables
extern int NewPieceID;
extern int NewPieceType;
extern int NewPieceOrientation;
extern int NewPieceColumn;
extern int TouchdownID;

static int linesCleared = 0;
static int receivedCommand = CommandReceived;

// Interrupt Handlers
void incrLinesCleared_handler(void){
    linesCleared++;
}

void setReceivedCommand_handler(void){
    receivedCommand = CommandReceived;
}

void gotNewPiece_handler(void){
    
}

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
    
    // Run Simptris
    StartSimptris();

    while(1){

        YKDelayTask(20);
        
        YKEnterMutex();
        switchCount = YKCtxSwCount;
        idleCount = YKIdleCount;
        YKExitMutex();
        
        printString("<CS: ");
        printInt((int)switchCount);
        printString(", CPU: ");
        tmp = (int) (idleCount/max);
        printInt(100-tmp);
        printString("% >\r\n");
        
        YKEnterMutex();
        YKCtxSwCount = 0;
        YKIdleCount = 0;
        YKExitMutex();
    }
    

}


void main(void)
{
    YKInitialize();

    /* create all semaphores, queues, tasks, etc. */
    YKNewTask(statisticsTask, (void *) &statistics[TASK_STACK_SIZE], 0);
    nextCommandPtr = YKSemCreate(0);
    pieceQPtr = YKQCreate(pieceQ, pieceQSize);
    moveQPtr = YKQCreate(moveQ, moveQSize);
    SeedSimptris(100);//What kind of seed should i choose?
    
    YKRun();
}