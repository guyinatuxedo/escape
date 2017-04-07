#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>


int main()
{
	printf("You know, you really need to be more important to do things.\n");
	printf("%d\n", getuid());

	if (getuid() == 0)
	{
		printf("Wow, maybe you are that important. Level Cleared!\n");
	}

	else
	{
		printf("You should really talk to someone more important.\n");
	}
}
