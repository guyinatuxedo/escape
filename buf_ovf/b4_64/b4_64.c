#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	printf("%p\n", &buf0);
	gets(buf0);
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
}
