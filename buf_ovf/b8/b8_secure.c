#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void the_horror()
{
	unsigned int ret_adr;
	char buf0[40];
	fgets(buf0, sizeof(buf0), stdin);
	ret_adr = __builtin_return_address(0);

	if ((ret_adr & 0xf0000000) == 0xf0000000)
	{
		printf("Don't you have anything better to do? Clearly not.\n");
		exit(0);
	}
	printf("That's it, if you don't get back to your work at %p, we will have to deploy the mechs.\n", ret_adr);
}

int main()
{
	printf("Corrective solutions aren't working. We might have to upgrade.\n");
	the_horror();
}



