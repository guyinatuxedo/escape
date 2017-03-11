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
		puts("You need two arguments in addition to the elf's name to research this.\n");
		exit(0);
	}
	if (argc = 3)
	{
		if (strlen(argv[1]) > 9)
		{
			printf("Inputs must be less than 10 characters.\n");
			exit(0);
		}
		
		if (strlen(argv[2]) > 9)
		{
			printf("Inputs must be less than 10 characters.\n");
			exit(0);
		}
		
	}
	struct space *sun, *moon;

	sun = malloc(sizeof(struct space));
	sun->star = malloc(sizeof(*argv[1]));

	moon = malloc(sizeof(struct space));
	moon->star = malloc(sizeof(*argv[2]));

	strcpy(sun->star, argv[1]);
	strcpy(moon->star, argv[2]);

	printf("Do you know what well rounded researchers like? They like space.\n");
}

