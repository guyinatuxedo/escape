#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void pls_stop()
{
	unsigned int ret_adr;
	char buf0[50];
	fgets(buf0, sizeof(buf0), stdin);
	ret_adr = __builtin_return_address(0);

	if ((ret_adr & 0xf0000000) == 0xf0000000)
	{
		printf("Due to the lack of research, we had to make budget cuts.\n");
		exit(0);
	}
	printf("When you get done with hacking, your research is at %p. Just incase you feel like doing work.\n", ret_adr);
	strdup(buf0);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	pls_stop();
}



