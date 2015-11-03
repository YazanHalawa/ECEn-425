#include "clib.h"

int main(){
    int var;
    switch(var){
        case 200: 
            printString("this is 0\n");
            break;
        case 313:
            printString("this is 1\n");
            break;
        case 467: 
            printString("this is 2\n");
            break;
        case 897: 
            printString("this is 3\n"); 
            break;
        case 999: 
            printString("this is 4\n"); 
            break;
        case 550: 
            printString("this is 5\n"); 
            break;
        case 600: 
            printString("this is 6\n"); 
            break;
        case 768: 
            printString("this is 7\n"); 
            break;
        default: 
            printString("this is default\n"); 
            break;
    }   
    return 0;
}