#include <stdio.h>
#include <stdlib.h>

int main()
{
	printf("This is the same vulnerabillity. Go on, use the same exploit.\n");
	char buf0[50];
	gets(buf0);
}

void func0()
{
	printf("So how did that same exploit work out? Level Cleared\n");
}
