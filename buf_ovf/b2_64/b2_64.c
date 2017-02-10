#include <stdio.h>
#include <stdlib.h>

int nothing_interesting()
{

	printf("Level Cleared\n");
}

int main()
{
	char buf1[55];
	char buf0[300];
	volatile int (*var1)();
	var1 = 0;

	gets(buf0);

	if (var1)
	{
		printf("Wait, you aren't supposed to be here\n");
		var1();
	}

	else
	{
		printf("O look you didn't solve this. How very predictable\n");
	}
}
