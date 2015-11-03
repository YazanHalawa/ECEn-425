#include <stdint>
#include <stdio>

using namespace std;

int main(){
	int var = 4;
	switch(var){
		case 0: 
			printf("this is 0\n");
			break;
		case 1:
			printf("this is 1\n");
			break;
		case 2: 
			printf("this is 2\n");
			break;
    	case 3: 
    		printf("this is 3\n"); 
    		break;
    	case 4: 
    		printf("this is 4\n"); 
    		break;
    	case 5: 
    		printf("this is 5\n"); 
    		break;
    	case 6: 
    		printf("this is 6\n"); 
    		break;
    	case 7: 
    		printf("this is 7\n"); 
    		break;
    	default: 
    		printf("this is default\n"); 
    		break;
	}	
	return 0;
}