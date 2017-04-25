#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main()
{
	puts("starting");
	setreuid(getuid(), getuid());
	system("/bin/sh");
	puts("ending");
}


