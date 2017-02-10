#include <stdlib.h>
#include <stdio.h>

int main()
{
	char buf0[10];
	float var0;
		
	fgets(buf0, sizeof(buf0), stdin);
	var0 = atof(buf0);
	printf("%d\n", var0);
	if (var0 < 37.35928559)
	{
		printf("Too low just like you're chances of reaching the bottom.\n");
		exit(0);
	}

	        if (var0 > 37.35928559)
        {
                printf("To high just like your hopes of reaching the bottom.\n");
                exit(0);
        }

	else 
	{

		printf("Oh wait, there might be a bottom to this. Level cleared\n");
	}

}
