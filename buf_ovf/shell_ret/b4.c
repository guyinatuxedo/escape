#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void nothing()
{
	char* buf0[50];
	printf("%p\n", &buf0);
	gets(buf0);
/*	if (1==2)
	{
		_exit(1);
	}
*/
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
	_exit(1);
}

void ignore_this()
{
	system("echo hi");
	
}

