#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

struct cable
{
	char thread[50];
	int count;
};

void elev0()
{
	int var0 = 5;
	int var1;
	int var2;
	var1 = var0 + 13;
	var0 = var1 * 3;
	var2 = var0 / var1;
 	var2 = var0 + var1 + var2;
	char answer0[20];
	fgets(answer0, sizeof(answer0) - 1, stdin);
	if (var2 == atoi(answer0))
	{
		int var3 = var2;
		var2 = var1 & var0;
		var0 = var2 ^ var1;
		var3 = var1 | var3;
		var3 = var1 + var2;
		var3 = var0 + var3;
		memset(answer0, 0, sizeof(answer0));
		fgets(answer0, sizeof(answer0) - 1, stdin);
		if (var3 == atoi(answer0))
		{		
			puts("So you figured out the second elevator.");
		}
		else
		{
			exit(0);
		}
	}
	
	else
	{
		exit(0);
	}
}

void elev1()
{
	char elevprompt[30];
	char elevpass[40];
	char answer1[20];
	int len;
	fgets(elevprompt, sizeof(elevprompt) - 10, stdin);
	strncpy(elevpass, "00110001", 7);
	strcat(elevpass, elevprompt);
	len = strlen(elevpass);
	fgets(answer1, sizeof(answer1), stdin);
	if (len == atoi(answer1))
	{
		memset(answer1, 0, sizeof(answer1));
		fgets(answer1, sizeof(answer1), stdin);
		if (strncmp(elevpass, answer1, len) == 0)
		{
			puts("Lazy researchers like you will never figure out the final elevator.");
		}		
		
		else
		{
			exit(0);
		}
	}

	else
	{
		exit(0);
	}	
}

void elev2()
{
	char final_answer[20];
	struct cable *ebox;
	ebox = calloc(1, sizeof(struct cable));
	strcpy(ebox->thread, "elevator password");
	fgets(final_answer, sizeof(final_answer) - 1, stdin);
	if (strncmp(final_answer, ebox->thread, 17) != 0)
	{
		puts("So close... to the bottom.");
		exit(0);
	}
}



int main(int argc, char** argv)
{
	if (argc != 3)
	{
		puts("This function needs three arguments.");
		exit(0);
	}
	char argvans[10];
	fgets(argvans, sizeof(argvans), stdin);
	if (strncmp(argv[1], argvans, strlen(argv[1])) != 0)
	{
		exit(0);
	}
	
	memset(argvans, 0, sizeof(argvans));
	fgets(argvans, sizeof(argvans), stdin);
	if (strncmp(argv[2], argvans, strlen(argv[2])) != 0)
	{
		exit(0);
	}
	puts("You might have access to the elevators, but can you figure out how to use them?");
	elev0();
	elev1();
	elev2();
	puts("So you are actually getting out of here using the elevators! Level cleared!");
}
