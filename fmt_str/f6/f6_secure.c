#include <stdio.h>
#include <stdlib.h>

int target = 0;

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		printf("You need two arguments to run this binary, you have %d.\n", argc);
		exit(0);
	}

	printf("%s\n", argv[1]);
	
	printf("Wasn't it all worth it? %x\n", target);	
	if (target == 0xe5ca3)
	{
		puts("Your celebration might have been a long way up, but here it is. Level Cleared!");
	}
}
