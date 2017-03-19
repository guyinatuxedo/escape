#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char buf0[50];
	char buf1[50];

	while (1 == 1)
	{
		puts("Since we are falling down a bottoless pit, what do you want to do?");
		fgets(buf0, sizeof(buf0), stdin);
		
		if (strncmp(buf0, "0", 1) == 0)
		{
			fgets(buf0, sizeof(buf0), stdin);
		}

		if (strncmp(buf0, "1", 1) == 0)
		{
			system("/usr/bin/env ls");
		}

		if (strncmp(buf0, "2", 1) == 0)
		{
			printf(buf1);	
		}
	}
}
