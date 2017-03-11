#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct space	
{
	char* star; 
};

void endless()
{
	int i = 5;
	printf("Do you know how much research I could fit in space? I'll give you a hint, more than %d. Level Cleared\n", i);
}

int main(int argc, char **argv)
{
	if (argc != 3)
	{
		printf("You need two arguments in addition to the elf's name to research this.  %d\n", argc);
		exit(0);
	}
	struct space *sun, *moon;

	sun = malloc(sizeof(struct space));
	sun->star = malloc(10);

	moon = malloc(sizeof(struct space));
	moon->star = malloc(10);

	strcpy(sun->star, argv[1]);
	strcpy(moon->star, argv[2]);

	printf("Do you know what well rounded researchers like? They like space.\n");
}

