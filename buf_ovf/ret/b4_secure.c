#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	printf("%p\n", &buf0);
	fgets(*buf0, sizeof(*buf0), stdin);
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
}
