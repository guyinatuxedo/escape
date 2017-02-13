#include <stdio.h>
#include <stdlib.h>

void fun0()
{
	char buf0[100];
	printf("What is 1 divided by 0?\n");
	fgets(buf0, sizeof(buf0), stdin);
}


int main()
{
	printf("To reach the end of this room, you must answer one simple question with base 10 numbers.\n");	
	fun0();
}

void end()
{
	printf("That is one way of reaching the end. Level Cleared\n");
}
