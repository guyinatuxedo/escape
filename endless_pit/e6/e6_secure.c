#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char** argv)
{
	if (argc != 2)
	{
		printf("You need two arguments for this.\n");
		exit(0);
	}
	setreuid(1000, 1000);
	if (access(argv[1], R_OK) == 0 )
	{
		char found[200];
		FILE* target = fopen(argv[1], "r");
		while (fgets(found, sizeof(found), target))
		{
			printf("%s\n", found);
		}
	}
	else
	{
		puts("Oh that's right, you can't grab the ladder. We should experiment on how to improve that.");
	}
}
