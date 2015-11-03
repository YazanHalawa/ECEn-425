#include "yakk.h"

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
        YKScheduler(ContextSaved);
        YKExitMutex();
    }  
}

void YKRun(){
    // Run the tasks
    running = 1;
    YKScheduler(ContextNotSaved);
}

void YKScheduler(int saveContext){
//YKEnterMutex();
    if(YKRdyList != YKCurTask){  
        YKCtxSwCount++; 
        YKDispatcher(saveContext);
    } 
//YKExitMutex();
}

void YKDelayTask(unsigned count){
    TCBptr temp;
    // Bookkeeping for change of state
    // Call the scheduler after specified number of ticks
    // if (count == 0) {
    //     return;
    // }
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
    // while (temp != NULL){
    //     printInt(temp->priority);
    //     printNewLine();
    //     temp = temp->next;
    // }
    YKTickNum++;
    print("\nTick ", 6);
    printInt(YKTickNum);
    printNewLine();
    //YKEnterMutex();
    temp = YKSuspList;
    while (temp != NULL){
        //printString("loop tick\n");
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
                //printString("loop prio tick\n");
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
            //printString("end of loop tick\n");
        }
        else{
            temp = temp->next;
        }
    }
    //YKExitMutex();
}

void YKEnterISR() {
    nestingLevel++;
}

void YKExitISR() {
//YKEnterMutex();
    nestingLevel--;
    if (nestingLevel == 0 && running) {
        //YKExitMutex();
        YKScheduler(ContextSaved);
    }
//YKExitMutex();
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
    if (semaphore->blockedOn!=NULL)
        semaphore->blockedOn->prev = NULL;
    // modify TCB of that task, place in ready list
    temp->state = READY;
    // Put in Rdy List
    temp2 = YKRdyList;
    while (temp2->priority < temp->priority){
        //printString("loop prio tick\n");
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