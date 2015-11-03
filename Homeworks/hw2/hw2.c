#include <stdio.h>

int multiplyTwoNums(int first, int second){
	return first*second;
}
int main (){
	int a = 2, b = 3;
	char f = 'a';
	multiplyTwoNums(a,f);
}

// #include <stdio.h>


// int main (){
// 	int array[] = {0,1,2,3,4};
// 	printf("%p\n\r", &array[4] + 0x1);
// 	int *next_address = (int*)(&array[4] + 0x1);
// 	printf("next_address = %d at address %p\n\r", *next_address, &(*next_address));
// 	for (int i=0; i<6; i++) {
// 		printf("Index %d: Value of %d	at address %p\n\r", i, array[i], &array[i]);
// 		array[i] = i*100;
// 		printf("Index %d: Value of %d	at address %p\n\r", i, array[i], &array[i]);
// 	}
// 	printf("next_address = %d at address %p\n\r", *next_address, &(*next_address));
// }


#include <stdio.h>
int main(){
	int myArray[2];
	int myVar = 3;

	for (int i = 0; i < 4; i++){
		myArray[i] = i*100;
	}
	printf("%d", myVar);
	return 0;
}