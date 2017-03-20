#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct struct0
{
	char *buf0;
	char buf1[500];
	int var0;
};

int main()
{
	struct struct0 *p0;
	p0 = malloc(sizeof(struct struct0));
	p0->buf0 = getenv("escape");
	if (p0->buf0 != NULL)
	{
		strcpy(p0->buf1, p0->buf0);
	}
	if (p0->var0)
	{
		puts("While you are down here, you might as well get used to your enviornment. Level Cleared!");
	}
}
