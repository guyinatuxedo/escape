#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{

	char handle[500];
	scanf("%10s", &handle);

	if ((strcmp(handle, "exit")) == 0)
	{
		puts("Not so fast, you have a looong way down.");
		exit(0);
	}

	FILE *hope;
	hope = fopen(handle, "r");
	
	if (hope == NULL)
	{
		perror("error");
		puts("You really don't have any, do you?");
		exit(0);
	}
	
	else
	{
		fgets(handle, sizeof(handle), hope);
		printf("%s\n", handle);
	}
}
