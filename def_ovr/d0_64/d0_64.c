#include <stdlib.h>
#include <stdio.h>

void discovery()
{
	puts("My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!");
}

void revelation()
{
	char light[489];
	fgets(light, sizeof(light) - 1, stdin);
	printf(light);
}


int main()
{
	revelation();
	char buf0[10];
	gets(buf0);
}
