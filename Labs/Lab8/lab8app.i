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

int placementTaskStk[512];     
int communicationTaskStk[512];
int statisticsTaskStk[512];

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
static int availablePieces;

MOVE moves[10];
static int availableMoves;




void setReceivedCommand_handler(void){
    printString("got next command\r\n");
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



void placementTask(){ 
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
            printString("got Corner\r\n");
            createMove(id, 0);
        }
        else {
            printString("got flat\r\n");
            createMove(id, 1);
        }
    }
}

void communicationTask(){ 
    MOVE* temp;
    while(1){
        temp = (MOVE*)YKQPend(moveQPtr); 
        availableMoves++;
        
        if (temp->action == 0){
            printString("go left\r\n");
            SlidePiece(temp->idOfPiece, 0);
        } else if (temp->action == 1){
            printString("go right\r\n");
            SlidePiece(temp->idOfPiece, 1);
        } else if (temp->action == 2){
            printString("rotate left\r\n");
            RotatePiece(temp->idOfPiece, 1);
        } else {
            printString("rotate right\r\n");
            RotatePiece(temp->idOfPiece, 0);
        } 
        YKSemPend(nextCommandPtr);
    }
}

void statisticsTask(){ 
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

    
    StartSimptris();

    
    YKNewTask(placementTask, (void*) &placementTaskStk[512], 20);
    YKNewTask(communicationTask, (void*) &communicationTaskStk[512], 10);
 

    while(1){
        printString("before delay\r\n");
        YKDelayTask(20);
        printString("after delay\r\n");

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

    
    YKNewTask(statisticsTask, (void *) &statisticsTaskStk[512], 30);
    nextCommandPtr = YKSemCreate(0);
    pieceQPtr = YKQCreate(pieceQ, 10);
    moveQPtr = YKQCreate(moveQ, 10);
    availablePieces = 10;
    availableMoves = 10;
    SeedSimptris(37428L);


    YKRun();
}

