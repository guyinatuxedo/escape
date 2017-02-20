#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char *buf1;
	buf1 = (char*) malloc(40);
	strcpy(buf1, "Oh look, a way out!");
	char buf0[50];
	fgets(buf0, sizeof(buf0), stdin);
	if (*buf0 == *buf1)
	{
		printf("Do you really think you can escape?\n");	
	}

}

