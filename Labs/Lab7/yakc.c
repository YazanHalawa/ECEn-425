#include "yakk.h"

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
int YKQAvailCount; // number of available queues
YKQ YKQs[MAXQUEUES]; // array of queues

YKSEM YKSems[MAXSEMS]; // array of semaphores
int YKAvaiSems; // unused semaphores

YKEVENT YKEvents[MAXEVENTS]; // array of event groups
int YKAvaiEvents; // unused event groups

void YKInitialize(){
    int i;
    YKEnterMutex();
    YKIMRInit(0x00);
    running = 0;
    YKIdleCount = 0;
    YKCtxSwCount = 0;
    YKCurTask = NULL; 
    YKRdyList = NULL;
    YKSuspList = NULL;
    nestingLevel = 0;
    YKTickNum = 0;
    YKAvaiSems = MAXSEMS;
    YKQAvailCount = MAXQUEUES;
    YKAvaiEvents = MAXEVENTS;
    
    // Initialize locations for TCB
    YKAvailTCBList = &(YKTCBArray[0]);
    for (i = 0; i < MAXTASKS; i++){
        YKTCBArray[i].next = &(YKTCBArray[i+1]);
        YKTCBArray[MAXTASKS].prev = NULL; 
    }
    YKTCBArray[MAXTASKS].next = NULL;
    YKTCBArray[MAXTASKS].prev = NULL;

    YKNewTask(YKIdleTask,(void *) &(idleStk[IDLE_STACK_SIZE]),100);  
}

void YKIdleTask(){
    while(1){
        YKEnterMutex();
        YKIdleCount++;
        YKExitMutex();
    }

}

void YKNewTask(void (* task)(void), void *stackptr, unsigned char priority){
    int i;
    unsigned *stackIter;
    TCBptr insertion, iter2;
    
    YKEnterMutex();

    insertion = YKAvailTCBList;  
    
    if(insertion == NULL){
        return;
    } 
    
    YKAvailTCBList =  insertion->next;   
     
    insertion->state = READY;
    insertion->priority = priority;
    insertion->delay = 0;
    insertion->flags = 0;
    insertion->waitMode = 0;
 
    if (YKRdyList == NULL)  /* is this first insertion? */
    {
        YKRdyList = insertion;
        insertion->next = NULL;
        insertion->prev = NULL;
    }
    else            /* not first insertion */
    {
        iter2 = YKRdyList;   /* insert in sorted ready list */
        while (iter2->priority < insertion->priority)
            iter2 = iter2->next;  /* assumes idle task is at end */
        if (iter2->prev == NULL) /* insert in list before tmp2 */
            YKRdyList = insertion;
        else
            iter2->prev->next = insertion;
        insertion->prev = iter2->prev;
        insertion->next = iter2;
        iter2->prev = insertion;
    }
    stackIter = (unsigned *)stackptr;
    stackIter -=13;

    for(i=0; i<13; i++) {
        if (i == 10) {
            stackIter[i] = (unsigned)task;
        } else if (i == 12) {
            stackIter[i] = FLAGB;   // Set the interrupt flag
        } else {
            stackIter[i] = 0;
        }
    }   
    insertion->stackptr = (void *)stackIter;
    if(running == 1) {
        YKScheduler(ContextNotSaved);
    } 
    YKExitMutex(); 
}

void YKRun(){
    // Run the tasks
    running = 1;
    YKScheduler(ContextNotSaved);
}

void YKScheduler(int saveContext){
YKEnterMutex();
    if(YKRdyList != YKCurTask){  
        YKCtxSwCount++; 
        YKDispatcher(saveContext);
    }
YKExitMutex();
}

void YKDelayTask(unsigned count){
    TCBptr temp;
    YKEnterMutex();
    temp = YKRdyList; // Hold the first ready task
    // Remove it from Ready list
    YKRdyList = temp->next; 
    if (YKRdyList != NULL)
       YKRdyList->prev = NULL;
    temp->state = BLOCKED;
    temp->delay = count;

    // Put at head of Susp List
    temp->next = YKSuspList;
    YKSuspList = temp;
    temp->prev = NULL;
    if (temp->next != NULL)
        temp->next->prev = temp;
    YKScheduler(ContextNotSaved);
    YKExitMutex();
}

void YKTickHandler(void){
    TCBptr temp, temp2, next;
    YKEnterMutex();
    YKTickNum++;
    temp = YKSuspList;
    while (temp != NULL){
        temp->delay--;
        if (temp->delay == 0){ // If the task has delayed the appropriate amount of ticks
            temp->state = READY; // Make the task ready
            next = temp->next; // Store the temp's next so you don't lose it
            // Remove from Susp List
            if (temp->prev == NULL){
                YKSuspList = temp->next;
            }
            else{
                temp->prev->next = temp->next;
            }
            if (temp->next != NULL){
                temp->next->prev = temp->prev;
            }
            // Put in Rdy List
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == NULL){
                YKRdyList = temp;
            }
            else{
                temp2->prev->next = temp;
            }
            temp->prev = temp2->prev;
            temp->next = temp2;
            temp2->prev = temp;
            // Update the next pointer 
            temp = next;
        }
        else{
            temp = temp->next;
        }
    }
    YKExitMutex();
}

void YKEnterISR() {
    nestingLevel++;
}

void YKExitISR() {

    nestingLevel--;
    if (nestingLevel == 0 && running) {
        YKScheduler(ContextSaved);
    }
}

YKSEM* YKSemCreate(int initialValue){
    YKEnterMutex();
    if (YKAvaiSems <= 0){
        YKExitMutex();
        printString("Not enough sems");
        exit(0xff);
    }
    else {
        YKAvaiSems--;
        YKSems[YKAvaiSems].value = initialValue;
        YKSems[YKAvaiSems].blockedOn = NULL;
    }
    YKExitMutex();

    // Return the address of the newely created semaphore
    return (&(YKSems[YKAvaiSems]));

}

void YKSemPend(YKSEM *semaphore){
    TCBptr temp, temp2, iter;
    int index;
    // disable interrupts
    YKEnterMutex();
    if (semaphore->value-- > 0){
        // enable interrupts
        YKExitMutex();
        return;
    }
    // Remove calling task's TCB from ready list
    temp = YKRdyList; // Hold the first ready task
    // Remove it from Ready list
    YKRdyList = temp->next; 
    if (YKRdyList != NULL)
       YKRdyList->prev = NULL;
    // modify TCB, put in suspended list
    temp->state = BLOCKED;
    // Put task at semaphore's blocked list
    if (semaphore->blockedOn == NULL){
        semaphore->blockedOn = temp;
        temp->next = NULL;
        temp->prev = NULL;
    }
    else{
        iter = semaphore->blockedOn;
        temp2 = NULL;
        while (iter != NULL && iter->priority < temp->priority){
            temp2 = iter;
            iter = iter->next;
        }
        if (iter == NULL){//At end
            temp2->next = temp;
            temp->prev = temp;
            temp->next = NULL;
        }
        else{ // insert before iterator
            temp->next = iter;
            temp->prev = temp2;
            iter->prev = temp;
            if (temp2 == NULL)//inserted at beginning of list
                semaphore->blockedOn = temp;
            else
                temp2->next = temp;
        }
    }
    // call scheduler
    YKScheduler(ContextNotSaved);
    // enable interrupts
    YKExitMutex();
}

void YKSemPost(YKSEM *semaphore){
    TCBptr temp, temp2;
    // disable interrupts
    YKEnterMutex();
    if (semaphore->value++ >= 0){
        // enable interrupts
        YKExitMutex();
        return;
    }
    // remove from pending list
    temp = semaphore->blockedOn;
    semaphore->blockedOn = temp->next;
    if (semaphore->blockedOn != NULL)
        semaphore->blockedOn->prev = NULL;
    // modify TCB of that task, place in ready list
    temp->state = READY;
    // Put in Rdy List
    temp2 = YKRdyList;
    while (temp2->priority < temp->priority){
        temp2 = temp2->next;
    }
    if (temp2->prev == NULL){
        YKRdyList = temp;
    }
    else{
        temp2->prev->next = temp;
    }
    temp->prev = temp2->prev;
    temp->next = temp2;
    temp2->prev = temp;
    // call scheduler if not called from ISR
    if (nestingLevel == 0)
        YKScheduler(ContextNotSaved);
    // enable interrupts
    YKExitMutex();
}

YKQ *YKQCreate(void **start, unsigned size){
    YKEnterMutex();
    if (YKQAvailCount <= 0){
        YKExitMutex();
        exit (0xff);
    }
    YKQAvailCount--;
    YKQs[YKQAvailCount].baseAddress = (void **)start;
    YKQs[YKQAvailCount].numOfEntries = size;
    YKQs[YKQAvailCount].addLoc = 0;
    YKQs[YKQAvailCount].removeLoc = 0;
    YKQs[YKQAvailCount].blockedOn = NULL;
    YKQs[YKQAvailCount].numOfMsgs = 0;
    YKExitMutex();
    return &(YKQs[YKQAvailCount]);
}

void *YKQPend(YKQ *queue){
    void * tempMsg;
    TCBptr temp, temp2, iter;
    TOP:
    YKEnterMutex();
    if (queue->numOfMsgs > 0){ // not empty
        // remove oldest message
        tempMsg = queue->baseAddress[queue->removeLoc];
        queue->removeLoc++;
        // handle roll over
        if (queue->removeLoc >= queue->numOfEntries){
            queue->removeLoc = 0;
        }
        queue->numOfMsgs--;
    }
    else {
        // Remove calling task's TCB from ready list
        temp = YKRdyList; // Hold the first ready task
        // Remove it from Ready list
        YKRdyList = temp->next; 
        if (YKRdyList != NULL)
            YKRdyList->prev = NULL;
        // modify TCB, put in suspended list
            temp->state = BLOCKED;
        // Put task at queue's blocked list
        if (queue->blockedOn == NULL){
            queue->blockedOn = temp;
            temp->next = NULL;
            temp->prev = NULL;
        }
        else{
            iter = queue->blockedOn;
            temp2 = NULL;
            while (iter != NULL && iter->priority < temp->priority){
                temp2 = iter;
                iter = iter->next;
            }
            if (iter == NULL){//At end
                temp2->next = temp;
                temp->prev = temp;
                temp->next = NULL;
            }
            else{ // insert before iterator
                temp->next = iter;
                temp->prev = temp2;
                iter->prev = temp;
                if (temp2 == NULL)//inserted at beginning of list
                    queue->blockedOn = temp;
                else
                temp2->next = temp;
            }
        }
        YKScheduler(ContextNotSaved);
        goto TOP;
    }
    YKExitMutex();
    return tempMsg;

}

int YKQPost(YKQ *queue, void *msg){
    TCBptr temp, temp2;
    YKEnterMutex();
    if (queue->numOfMsgs < queue->numOfEntries){
        queue->baseAddress[queue->addLoc] = msg;
        // increment the add location
        queue->addLoc++;
        // handle roll-over
        if (queue->addLoc >= queue->numOfEntries)
            queue->addLoc = 0;
        queue->numOfMsgs++;
        // remove from pending list
        if (queue->blockedOn != NULL){
            temp = queue->blockedOn;
            queue->blockedOn = temp->next;
            if (queue->blockedOn != NULL)
                queue->blockedOn->prev = NULL; 
            // modify TCB of that task, place in ready list
            temp->state = READY;
            // Put in Rdy List
            temp2 = YKRdyList;
            while (temp2->priority < temp->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == NULL){
                YKRdyList = temp;
            }
            else{
                temp2->prev->next = temp;
            }
            temp->prev = temp2->prev;
            temp->next = temp2;
            temp2->prev = temp;
            // call scheduler if not called from ISR
            if (nestingLevel == 0)
                YKScheduler(ContextNotSaved);
            }
        // enable interrupts
        YKExitMutex();
        return 1;
    }
    else{
        YKExitMutex();
        return 0;
    }

}

YKEVENT *YKEventCreate(unsigned initialValue){
    YKEnterMutex();
    if (YKAvaiEvents <= 0){
        YKExitMutex();
        printString("not enough events\n");
        exit (0xff);
    }
    YKAvaiEvents--;
    YKEvents[YKAvaiEvents].flags = initialValue;
    YKEvents[YKAvaiEvents].waitingOn = NULL;
    YKExitMutex();
    return &(YKEvents[YKAvaiEvents]);
}

int checkConditions(YKEVENT *event, unsigned eventMask, int waitMode){
    int conditionMet = 0;
    int i;
    YKEnterMutex();
    if (waitMode == EVENT_WAIT_ALL){
        conditionMet = 1;
        // check all bits are asserted
        for (i = 0; i < 16; i++){
            if ((eventMask & BIT(i))){
                if (!(event->flags & BIT(i))){
                    conditionMet = 0;
                }
            }
        }
    }
    else if (waitMode == EVENT_WAIT_ANY){
        for (i = 0; i < 16; i++){
            if (eventMask & BIT(i)){
                if (event->flags & BIT(i)){
                    conditionMet = 1;
                }
            }
        }
    }
    else{
         YKExitMutex();
        exit(0xff);
    }
    YKExitMutex();
    return conditionMet;
}

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode){
    int conditionMet = 0;
    int i;
    TCBptr temp, temp2, iter;

    // ------- Test if Conditions are met --------//
    conditionMet = checkConditions(event, eventMask, waitMode);

    while(1){
    // -------- If condition met, return. Else, block --------//
    if (conditionMet){
        return event->flags;
    }
    else{
        YKEnterMutex();
        // Remove calling task's TCB from ready list
        temp = YKRdyList; // Hold the first ready task
        // Remove it from Ready list
        YKRdyList = temp->next; 
        if (YKRdyList != NULL)
            YKRdyList->prev = NULL;
        // modify TCB, put in suspended list
            temp->state = BLOCKED;
            temp->flags = event->flags;
            temp->waitMode = waitMode;
        // Put task at queue's blocked list
        if (event->waitingOn == NULL){
            event->waitingOn = temp;
            temp->next = NULL;
            temp->prev = NULL;
        }
        else{
            iter = event->waitingOn;
            temp2 = NULL;
            while (iter != NULL && iter->priority < temp->priority){
                temp2 = iter;
                iter = iter->next;
            }
            if (iter == NULL){//At end
                temp2->next = temp;
                temp->prev = temp;
                temp->next = NULL;
            }
            else{ // insert before iterator
                temp->next = iter;
                temp->prev = temp2;
                iter->prev = temp;
                if (temp2 == NULL)//inserted at beginning of list
                    event->waitingOn = temp;
                else
                temp2->next = temp;
            }
        }
        YKScheduler(ContextNotSaved);
        YKExitMutex();
    }
}
    return event->flags;
}

void YKEventSet(YKEVENT *event, unsigned eventMask){
    int i;
    int taskMadeReady = 0;
    TCBptr iter, temp, temp2, next;
    YKEnterMutex();
    // ----- Set Flag Group ---- //
    for (i = 0; i < 16; i++){
        if (eventMask & BIT(i)){
            event->flags |= BIT(i);
        }
    }

    // ----- check Conditions ---- //
    iter = event->waitingOn;
    while (iter != NULL){
        // if conditions are met for that task, put in ready list
        if (checkConditions(event, iter->flags, iter->waitMode)){
            // remove from pending list
            next = iter->next;
            if (iter->prev != NULL)
                iter->prev->next = iter->next;
            if (iter->next != NULL)
                iter->next->prev = iter->prev;
            // modify TCB of that task, place in ready list
            iter->state = READY;
            // Put in Rdy List
            temp2 = YKRdyList;
            while (temp2->priority < iter->priority){
                temp2 = temp2->next;
            }
            if (temp2->prev == NULL){
                YKRdyList = iter;
            }
            else{
                temp2->prev->next = iter;
            }
            iter->prev = temp2->prev;
            iter->next = temp2;
            temp2->prev = iter;
            taskMadeReady = 1;
            iter = next;
        } else {
            iter = iter->next;
        }
    }
    // call scheduler if not called from ISR and a task was made ready
    if (taskMadeReady && nestingLevel == 0)
        YKScheduler(ContextNotSaved);
    YKExitMutex();
}

void YKEventReset(YKEVENT *event, unsigned eventMask){
    int i;
    for (i = 0; i < 16; i++){
        // If the specified bit is set in the mask, clear it in the event flags
        if (eventMask & BIT(i)){
            event->flags &= ~(BIT(i));
        }
    }
}