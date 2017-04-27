#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int main()
{
	FILE *ran_file;
	unsigned int int0;
	int i;	
	for (i=0; i<50; i++) {
		printf("%d days without an incident.\n", i);
		ran_file = fopen("/dev/urandom", "r");
		fread(&int0, sizeof(int0), 1, ran_file);
		fclose(ran_file);
		int0 = int0 % 100;
		char buf0[10];
		fgets(buf0, sizeof(buf0), stdin);
		if (int0 != atoi(buf0))
		{
			printf("Well that didn't take long.\n");
			printf("You should have used %d.\n", int0);
			exit(0);
		}
	}
	printf("How very unpredictable. Level Cleared\n");
}
