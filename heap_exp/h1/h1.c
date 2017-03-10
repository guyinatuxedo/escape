#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct space	
{
	char* star; 
};

void endless()
{
	printf("Do you know what well rounded researchers like? It seems you do. Level Cleared\n");
}

int main(int argc, char **argv)
{
	struct space *sun, *moon;

	sun = malloc(sizeof(struct space));
	sun->star = malloc(10);

	moon = malloc(sizeof(struct space));
	moon->star = malloc(10);

	strcpy(sun->star, argv[1]);
	strcpy(moon->star, argv[2]);
	
	_exit(0);
}

