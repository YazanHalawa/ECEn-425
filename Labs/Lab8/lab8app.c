/* 
File: lab8app.c
Revision date: 10 November 2005
Description: Application code for EE 425 lab 8 (Simptris)
*/

#include "clib.h"
#include "yakk.h"   
#include "simptris.h"                  /* contains kernel definitions */
#include "lab8defs.h"

#define SEED 37428L

#define TASK_STACK_SIZE  4096         /* stack size in words */
#define pieceQSize 10
#define moveQSize 10

#define LeftBottomCorner 0
#define RightBottomCorner 1
#define RightTopCorner 2
#define LeftTopCorner 3

#define FlatHorz 0
#define FlatVert 1

#define StraightPiece 1
#define CornerPiece 0

#define slideLeft 0
#define slideRight 1
#define rotateLeft 2
#define rotateRight 3

#define LEFT 1
#define RIGHT 0

// ------------ Variable Declarations ------------------ //
extern unsigned NewPieceID;
extern unsigned NewPieceType;
extern unsigned NewPieceOrientation;
extern unsigned NewPieceColumn;
extern unsigned TouchdownID;

YKSEM* nextCommandPtr;

void *pieceQ[pieceQSize];           /* space for piece queue */
YKQ* pieceQPtr;

void *moveQ[moveQSize];             /* space for move queue */
YKQ* moveQPtr;

int placementTaskStk[TASK_STACK_SIZE];     /* a stack for each task */
int communicationTaskStk[TASK_STACK_SIZE];
int statisticsTaskStk[TASK_STACK_SIZE];

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

PIECE pieces[pieceQSize];
static int availablePieces;

MOVE moves[moveQSize];
static int availableMoves;

int gotBottomLeft;
int gotBottomRight;
int gotLeft;
int leftEven;
int rightEven;
int leftSideHeight; /* to track the height of the left side */
int rightSideHeight; /* to track the height of the right side */
// ------------------------------------------- //

// --------- Interrupt Handlers -------------- //

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
//-------------------------------------------- //

//------------- Helper functions ------------- //
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

int makeBarHorizontal(int id, int orient, int col){
    if (orient == FlatVert){
        if (col == 0){
            createMove(id, slideRight);
            col = 1;
        }
        else if (col == 5){
            createMove(id, slideLeft);
            col = 4;
        }
        createMove(id, rotateRight);
    }
    return col;
}

void handleCorner(int col, int orient, int id, int direction){
    if (direction == slideLeft){
        gotLeft++;
        if (col == 0 && !(!gotBottomLeft && orient == LeftBottomCorner)){
            createMove(id, slideRight);
            col = 1;
        }
        if (col == 5){
            createMove(id, slideLeft);
            col = 4;
        }
        if (gotBottomLeft){
            if (orient == RightTopCorner){
                /* Do nothing cause that's what we want to counter-effect the bottom left */
            }
            else if (orient == RightBottomCorner){
                createMove(id, rotateLeft);
            }
            else if (orient == LeftTopCorner){
                createMove(id, rotateRight);
            }
            else if (orient == LeftBottomCorner){
                createMove(id, rotateLeft);
                createMove(id, rotateLeft);
            }
            gotBottomLeft = 0;
            if (col > 2){
                while(col != 2){
                    createMove(id, slideLeft);
                    col--;
                }
            } else if (col < 2){
                createMove(id, slideRight);
                col++;
            }
            leftEven = 1;
        } else {
            if (orient == RightTopCorner){
                createMove(id, rotateRight);
                createMove(id, rotateRight);
            }
            else if (orient == RightBottomCorner){
                createMove(id, rotateRight);
            }
            else if (orient == LeftTopCorner){
                createMove(id, rotateLeft);
            }
            else if (orient == LeftBottomCorner){
                /* Do nothing cause that's what we want*/
            }
            gotBottomLeft = 1;
            while (col != 0){
                col--;
                createMove(id, direction);
            }
            leftEven = 0;
            leftSideHeight+=2;
            }
    }
    else {
        gotLeft--;
        if (col == 0){
            createMove(id, slideRight);
            col = 1;
        }
        if (col == 5 && !(!gotBottomRight && orient == RightBottomCorner)){
            createMove(id, slideLeft);
            col = 4;
        }
        if (gotBottomRight){
            if (orient == RightTopCorner){
                createMove(id, rotateLeft);
            }
            else if (orient == RightBottomCorner){
                createMove(id, rotateLeft);
                createMove(id, rotateLeft);
            }
            else if (orient == LeftTopCorner){
                /* Do nothing cause that's what we want to counter-effect the bottom left */
            }
            else if (orient == LeftBottomCorner){
                createMove(id, rotateRight);
            }
            gotBottomRight = 0;
            if (col > 3){
                while(col != 3){
                    createMove(id, slideLeft);
                    col--;
                }
            } else if (col < 3){
                while(col != 3){
                    createMove(id, slideRight);
                    col++; 
                }
            }
            rightEven = 1;
        } else {
            if (orient == RightTopCorner){
                createMove(id, rotateRight);
            }
            else if (orient == RightBottomCorner){
                /* Do nothing cause that's what we want*/
            }
            else if (orient == LeftTopCorner){
                createMove(id, rotateRight);
                createMove(id, rotateRight);
            }
            else if (orient == LeftBottomCorner){
                createMove(id, rotateLeft);
            }
            gotBottomRight = 1;
            while(col != 5){
                col++;
                createMove(id, direction);
            }
            rightEven = 0;
            rightSideHeight+=2;
        }
    }
}

void handleStraight(int id, int orient, int col, int direction, int variable){
    col = makeBarHorizontal(id, orient, col);
    if (direction == slideLeft){
        gotLeft++;
        leftSideHeight++;
        while (col != 1){
            col--;
            createMove(id, direction);
        }
    }
    else{
        rightSideHeight++;
        gotLeft--;
        while(col != 4){
            col++;
            createMove(id, direction);
        }
    }
}
// -------------------------------------------- //

// ------------ Task Code --------------------- //
void placementTask(){ /* Determines sequence of slide and rotate commands */
    PIECE* temp;
    int id, col, orient, type;
    while(1){
        temp = (PIECE*)YKQPend(pieceQPtr); /* wait for next available piece */
        availablePieces++;
        // Grab the details of the piece
        id = temp->id;
        type = temp->type;
        orient = temp->orientation;
        col = temp->column;
        // Algorithm for placing the piece
        if (type == CornerPiece){ /* Got a Corner piece */
            if (((leftSideHeight < rightSideHeight) || !leftEven) && rightEven)
                handleCorner(col, orient, id, slideLeft);
            else
                handleCorner(col, orient, id, slideRight);
        }
        else {
            if (((leftSideHeight > rightSideHeight) || !leftEven) && rightEven)
                handleStraight(id, orient, col, slideRight, rightSideHeight);
            else
                handleStraight(id, orient, col, slideLeft, leftSideHeight);
        }
    }
}

void communicationTask(){ /* Handles communication with Simptris */
    MOVE* temp;
    while(1){
        temp = (MOVE*)YKQPend(moveQPtr); /* wait for next available move */
        availableMoves++;
        // Send the command to Simptris
        if (temp->action == slideLeft){
            SlidePiece(temp->idOfPiece, 0);
        } else if (temp->action == slideRight){
            SlidePiece(temp->idOfPiece, 1);
        } else if (temp->action == rotateLeft){
            RotatePiece(temp->idOfPiece, 0);
        } else {
            RotatePiece(temp->idOfPiece, 1);
        } 
        YKSemPend(nextCommandPtr);
    }
}

void statisticsTask(){ /* tracks statistics */
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

    // Run Simptris
    StartSimptris();

    // Create the tasks here
    YKNewTask(placementTask, (void*) &placementTaskStk[TASK_STACK_SIZE], 20);
    YKNewTask(communicationTask, (void*) &communicationTaskStk[TASK_STACK_SIZE], 10);
 

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
// ----------------------------------------------- // 

// -------------- Main Code ---------------------- //
void main(void)
{
    YKInitialize();

    /* create all semaphores, queues, tasks, etc. */
    YKNewTask(statisticsTask, (void *) &statisticsTaskStk[TASK_STACK_SIZE], 30);
    nextCommandPtr = YKSemCreate(0);
    pieceQPtr = YKQCreate(pieceQ, pieceQSize);
    moveQPtr = YKQCreate(moveQ, moveQSize);
    availablePieces = pieceQSize;
    availableMoves = moveQSize;
    SeedSimptris(SEED);
    
    // Init variables
    leftSideHeight = 0;
    rightSideHeight = 0;
    gotBottomLeft = 0;
    gotBottomRight = 0;
    gotLeft = 0;
    leftEven = 1;
    rightEven = 1;
    YKRun();
}
// ------------------------------------------------ //