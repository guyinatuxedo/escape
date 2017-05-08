#include <stdlib.h>
#include <stdio.h>

void fire_exit()
{
	printf("Oh look, a fire exit. That's why we are still under budget. Level Cleared \n");
}

void fun0()
{
	puts("Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.\n");
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);
	fflush(stdout);
}

int main()
{
	fun0();
}



