#include <stdlib.h>
#include <stdio.h>

void revelation()
{
	char light[489];
	fgets(light, sizeof(light) - 1, stdin);
	printf("%s\n", light);
}

void pivot() 
{
	char reroute[10];
	fgets(reroute, sizeof(reroute) - 1, stdin);
}

int main()
{
	revelation();
	pivot();
}

void discovery()
{
         puts("My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!");
}
