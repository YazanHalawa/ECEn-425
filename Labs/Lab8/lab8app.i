# 1 "lab8app.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 331 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "lab8app.c" 2







# 1 "./clib.h" 1





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


# 8 "lab8app.c" 2
# 1 "./yakk.h" 1





# 1 "./yaku.h" 1






# 6 "./yakk.h" 2


# 20 "./yakk.h"




typedef struct taskblock *TCBptr;
typedef struct taskblock
{
                
    void *stackptr;     
    int state;          
    int priority;       
    unsigned delay;          
    TCBptr next;        
    TCBptr prev;        
    unsigned flags;
    int waitMode;
}  TCB;

typedef struct sem
{
	int value;
	TCBptr blockedOn;
} YKSEM;

typedef struct ykq 
{
	void ** baseAddress;
	int numOfEntries;
	int addLoc;
	int removeLoc;
	TCBptr blockedOn;
	int numOfMsgs;
} YKQ;

typedef struct eventGroup
{
	unsigned flags; 
	TCBptr waitingOn;
} YKEVENT;

extern unsigned int YKTickNum;
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

YKSEM* YKSemCreate(int initialValue);

void YKSemPend(YKSEM *semaphore);

void YKSemPost(YKSEM *semaphore);

YKQ *YKQCreate(void **start, unsigned size);

void *YKQPend(YKQ *queue);

int YKQPost(YKQ *queue, void *msg);

int checkConditions(unsigned eventFlags, unsigned eventMask, int waitMode);

YKEVENT *YKEventCreate(unsigned initialValue);

unsigned YKEventPend(YKEVENT *event, unsigned eventMask, int waitMode);

void YKEventSet(YKEVENT *event, unsigned eventMask);

void YKEventReset(YKEVENT *event, unsigned eventMask);


# 9 "lab8app.c" 2
# 1 "./simptris.h" 1



void SlidePiece(int ID, int direction);
void RotatePiece(int ID, int direction);
void SeedSimptris(long seed);
void StartSimptris(void);

# 10 "lab8app.c" 2
# 1 "./lab8defs.h" 1

















# 11 "lab8app.c" 2






















extern unsigned NewPieceID;
extern unsigned NewPieceType;
extern unsigned NewPieceOrientation;
extern unsigned NewPieceColumn;
extern unsigned TouchdownID;

YKSEM* nextCommandPtr;

void *pieceQ[10];           
YKQ* pieceQPtr;

void *moveQ[10];             
YKQ* moveQPtr;

int placement[512];     
int communication[512];
int statistics[512];

typedef struct pieceInfo {
    unsigned id;
    unsigned type;
    unsigned orientation;
    unsigned column;
} PIECE;

typedef struct moveInfo {
    int action;
    unsigned idOfPiece;
} MOVE;

PIECE pieces[10];
int availablePieces;

MOVE moves[10];
int availableMoves;




void setReceivedCommand_handler(void){
    YKSemPost(nextCommandPtr);
}

void gotNewPiece_handler(void){
    if (availablePieces <= 0){
        printString("not enough pieces\r\n");
        exit (0xff);
    }
    availablePieces--;
    pieces[availablePieces].id = NewPieceID;
    pieces[availablePieces].type = NewPieceType;
    pieces[availablePieces].orientation = NewPieceOrientation;
    pieces[availablePieces].column = NewPieceColumn;

    YKQPost(pieceQPtr, (void*) &(pieces[availablePieces]));
}

void setGameOver(void){
    printString("GAME OVER!");
    exit(0xff);
}



void createMove(unsigned idOfPiece, int action){
    if (availableMoves <= 0){
        printString("not enough moves\r\n");
        exit(0xff);
    }
    availableMoves--;
    moves[availableMoves].idOfPiece = idOfPiece;
    moves[availableMoves].action = action;

    YKQPost(moveQPtr, (void*) &(moves[availableMoves]));
}



void placementTask(void){ 
    PIECE* temp;
    int id, col, orient, type;
    while(1){
        temp = (PIECE*)YKQPend(pieceQPtr); 
        availablePieces++;

        
        id = temp->id;
        type = temp->type;
        orient = temp->orientation;
        col = temp->column;

        
        if (type == 0){
            createMove(id, 0);
        }
        else {
            createMove(id, 1);
        }
    }
}

void communicationTask(void){ 
    MOVE* temp;
    while(1){
        YKSemPend(nextCommandPtr);
        temp = (MOVE*)YKQPend(moveQPtr); 
        availableMoves++;

        
        if (temp->action == 0){
            SlidePiece(temp->idOfPiece, 0);
        } else if (temp->action == 1){
            SlidePiece(temp->idOfPiece, 1);
        } else if (temp->action == 2){
            RotatePiece(temp->idOfPiece, 1);
        } else {
            RotatePiece(temp->idOfPiece, 0);
        } 
    }
}

void statisticsTask(void){ 
    unsigned idleCount, max;
    int switchCount, tmp;

    YKDelayTask(1);
    printString("Welcome to the YAK kernel\r\n");
    printString("Determining CPU capacity\r\n");
    YKDelayTask(1);
    YKIdleCount = 0;
    YKDelayTask(5);
    max = YKIdleCount / 25;
    YKIdleCount = 0;

    
    SeedSimptris(37428L);
    StartSimptris();

    
    YKNewTask(placement, (void*) &placement[512], 1);
    YKNewTask(communication, (void*) &communication[512], 2);

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

    
    YKNewTask(statisticsTask, (void *) &statistics[512], 0);
    nextCommandPtr = YKSemCreate(0);
    pieceQPtr = YKQCreate(pieceQ, 10);
    moveQPtr = YKQCreate(moveQ, 10);
    availablePieces = 10;
    availableMoves = 10;
    
    YKRun();
}

