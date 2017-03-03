#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void nothing()
{
	char* buf0[50];
	fgets(buf0, sizeof(buf0), stdin);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	nothing();
	_exit(1);
}

void ignore_this()
{
	char shield[500];
	strcpy(shield, "Block");
	system("echo hi");
	
}

