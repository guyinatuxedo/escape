#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct spacecraft
{
	char destination[50];
	int coordinates;
};

struct spacecraft *voyager, *curiosity;

int main(int argc, char **argv)
{
	char input[100];
	while (1)
	{
		printf("Welcome to our spaceship simulation training program. What would you like to do?\n");
		fgets(input, sizeof(input), stdin);

		if (strncmp(input, "refuel", 6) == 0)
		{
			printf("Now refueling...\n");
			voyager = malloc(sizeof(struct spacecraft));
		}

		if (strncmp(input, "repair", 6) == 0)
		{
			printf("Now initiating repairs...\n");
			curiosity = malloc(sizeof(struct spacecraft));
		}
		
		if (strncmp(input, "analyze", 7) == 0)
		{
			printf("This planet's atmosphere is %p, and it's soil composition is %p.\n", voyager, curiosity);
		}

		if (strncmp(input, "recalibrate", 11) == 0)
		{
			fgets(voyager->destination, sizeof(voyager->destination), stdin);
		}

		if (strncmp(input, "launch", 6) == 0)
		{
			if (voyager->coordinates)
			{
				printf("We have lift off. Level Cleared\n");
			}
			else
			{
				printf("And everything goes up in flames.\n");
				exit(0);
			}
		}

		if (strncmp(input, "lessen", 6) == 0)
		{
			printf("Removing waste from the spacecraft.\n");
			free(voyager);
		}

		if (strncmp(input, "comms", 5) == 0)
		{
			printf("Establishing communications to mission control.\n");
			fgets(curiosity->destination, sizeof(curiosity->destination) + 4, stdin);
		}

		if (strncmp(input, "pressurize", 10 ) == 0)
		{
			printf("Pressurizing entry pod...\n");
			free(curiosity);
		}
		memset(input, 0, 100);

	}
}
