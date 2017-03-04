#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void nothing()
{
	char* buf0[50];
	read(STDIN_FILENO, buf0, 450);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	nothing();
}



