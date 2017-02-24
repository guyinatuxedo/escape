#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	gets(buf0);
}

int main()
{
	printf("There, now you have less than nothing. Yet you still try. Some would recogmedn a psychologist. I recogmend natural selection\n");
	nothing();
}
