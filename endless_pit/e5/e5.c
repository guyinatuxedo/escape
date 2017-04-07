#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char buf0[50];
	strncpy(buf0, getenv("USER"), 30);
	printf("You know, you really need to be more important to do things.\n");
	printf("%s\n", buf0);

	if (strncmp(buf0, "root", 4) == 0)
	{
		printf("Wow, maybe you are that important. Level Cleared!\n");
	}

	else
	{
		printf("You should really talk to someone more important.\n");
	}
}
