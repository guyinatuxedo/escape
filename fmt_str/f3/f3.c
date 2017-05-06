#include <stdio.h>
#include <stdlib.h>

int target0 = 0;
int target1 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf(buf0);

	if (target0 == 0xace5 && target1 == 0xfacade)
		{
		printf("There's a line between taking advantage, and downright exploiting. You have crossed that line. Level Cleared\n");
		}
	printf("The value of target0 is %x\n", target0);
	printf("The value of target1 is %x\n", target1);
	}

int main()
{
	fun0();
}
