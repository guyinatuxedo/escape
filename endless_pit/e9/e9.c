#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	int cost = 100;
	int priv_level = 0;
	puts("Not only did you make it back to ground level, but you found the door to our secret research equipment. Too bad you don't have the privilege level to enter it. However you can raise the privilege level if you want.");
	char input[1000];
	while (1==1)
	{
		memset(input, 0, sizeof(input));
		fgets(input, sizeof(input) - 1, stdin);
		if (atoi(input) > 0)
		{
			cost = cost + atoi(input);
		}
		printf("Current privilege level needed to access this is %d.\n", cost);
		if (cost <= priv_level)
		{
			puts("I'm pretty sure that wasn't supposed to happen. Level Cleared!");
		}
	}	
}
