#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char buf0[100];

int main()
{
	char buf1[200];

	printf("Do you really want to escape, the celebration is nearing.\n");
	fgets(buf1, sizeof(buf1), stdin);

	strcpy(buf0, "ls -asl");
	printf("%s\n", buf1);

	printf("Here look at all of the wonderful things you have to research.\n");
	system(buf0);
}
