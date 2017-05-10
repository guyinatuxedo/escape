#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char **argv)
{
	char *target;
	target = malloc(sizeof(char));
	strncpy(target, "Wait this isn't a lie?", 22);
	printf(argv[1]);
        puts("Now that your celebration has come, how do you feel?");
	printf("%p\n", target);
	printf("%s\n", target);

	if (strncmp(target, "Wait this isn't a lie?", 22) != 0)
	{
		puts("I bet you fell cheated, don't you? Level Cleared!\n");
	}
}
