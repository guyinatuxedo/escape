#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	int i;

	for (i = 1; i < argc; i++)
	{
		printf("You told me %s.\n", argv[i]);
	}	
}

