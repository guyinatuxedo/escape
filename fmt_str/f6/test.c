#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void *target;
target = calloc(0, 50);

//nt target = 0;

int main(int argc, char *argv[200])
{
	printf("%p\n", target);
/*	if (argc != 2)
	{
		printf("You need two arguments to run this binary, you have %d.\n", argc);
		exit(0);
	}*/
	char hi[100];
	strcpy(hi, argv[1]);
	strncpy(hi, "\0" + hi, sizeof(hi) + 1);
	printf(argv[1]);
//	printf("Wasn't it all worth it? %x\n", target);	
	if (target == 0xe5ca3)
	{
		puts("Your celebration might have been a long way up, but here it is. Level Cleared!");
	}
}
