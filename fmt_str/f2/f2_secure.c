#include <stdio.h>
#include <stdlib.h>

int var0 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);

	if (var0 == 486)
		{
			printf("What type of a guy would take advantage of a printf? I'll tell you. Level Cleared\n");
		}
	printf("The value of var0 is %d\n", var0);
	}

int main()
{
	fun0();
}
