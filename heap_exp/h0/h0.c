#include <stdlib.h>
#include <stdio.h>

struct struct0 
{
	char buf0[100];
	int var0;
};

int main()
{
	struct struct0 *p0;	

	p0 = malloc(sizeof(struct struct0));
	printf("Insert text here...\n");
	p0->var0 = 0;
	gets(p0->buf0);
	
	if (p0->var0)
	{
		printf("Well aren't you the well rounded researcher. Level Cleared\n");
	}
}
