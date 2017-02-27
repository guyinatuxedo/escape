#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>


struct thing0
{
	char *thing1;
	//char *thing2;
};

void Important()
{
	printf("Man I thought this would really work. Level Cleared\n");
}

int main(int argc, char **argv)
{
	struct thing0 *v1, *v2;
	//v1 = malloc(sizeof(struct thing0));
	//v2 = malloc(sizeof(struct thing0));
	v1->thing1 = malloc(8);
	v2->thing1 = malloc(8);



	//char thing3[200];
	//char thing4[200];
	//fgets(thing3, sizeof(thing3), stdin);
	//fgets(thing4, sizeof(thing4), stdin);

	//strcpy(v1->thing1, argv[1]);
	//strcpy(v2->thing1, argv[2]);
	
	printf("All of these things, and you still aren't satisfied.\n");
}
