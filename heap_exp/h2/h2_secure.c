#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct vaccum	
{
	char* quasar;
	int asteroid; 
};

int main(int argc, char **argv)
{
	struct vaccum *blue, *red, *yellow;

	blue = malloc(sizeof(struct vaccum));
	blue->quasar = malloc(10);
	blue->asteroid = 15;

	
	red = malloc(sizeof(struct vaccum));
	red->quasar = malloc(10);
	red->asteroid = 43;
	
	yellow = malloc(sizeof(struct vaccum));
	yellow->quasar = malloc(10);
	yellow->asteroid = 10;	

	strcpy(red->quasar, "4.367");
	strcpy(yellow->quasar, "far far away");
	fgets(blue->quasar, sizeof(blue->quasar), stdin);
	
	printf("Alpha Centari is %s light years away.\n", red->quasar);
	printf("The center of the milky way galaxy is %s.\n", yellow->quasar);
	printf("The asteroid is %d parsecs away.\n", yellow->asteroid);

	if (yellow->asteroid == 0xdeadbeef)
	{
		printf("It's funny how much a researcher can tell from light. Level Cleared!\n");
	}

	printf("Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.\n");
}

