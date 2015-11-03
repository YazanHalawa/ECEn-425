#include <stdio.h>
#include <stdint.h>
int main(){
	/*
	int32_t x=0x80000000;
	int32_t y= x >> 8;
	if (y == 8388608)
		printf("true");
		*/
	int x=0;
	int y=1;
	int z=2;

	printf("%d\n", x + y * z);
	printf("%d\n", x == 0 && y != 4);
	printf("%d\n", y < x < z);
	printf("%d\n", y+-z);
	printf("%d\n", !z||y);
	printf("%d\n", y ? x : z);
	printf("%d\n", x - y < z);
	printf("%d\n", x = 0 || z <= y);
	printf("%d\n", z & 3 == 2);
	return 0;
}