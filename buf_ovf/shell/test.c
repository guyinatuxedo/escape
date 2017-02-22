#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>

void h()
{
  char* buffer[64];

  gets(buffer);
  printf("%p\n", &buffer);
}

int main()
{
	h();
}

