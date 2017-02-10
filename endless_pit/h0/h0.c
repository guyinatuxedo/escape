#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int main()
{
	int i;
	time_t var0;
	var0 = time(NULL);
	srand(var0);

	int var1;
	var1 = 0;
	char buf0[500];
	char buf1[500];

	for (i=0; i<50; i++)
		{
		int var2 = rand() % 100;
		printf("You've been falling for %d days. Strange, that is %d days more than you will spend outside.\n", i, i);
		sprintf(buf1, "%d", var2);
		scanf(" %s", buf0);
		strtok(buf0, "\n");
		if (strcmp(buf1, buf0) != 0)
			{			
			printf("How very predictable.\n");
			printf("Your number was %s\n", buf1);
			exit(0);
			}				
		}
	printf("How very unpredictable. Level Cleared\n");
}
