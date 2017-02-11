#include <stdio.h>
#include <stdlib.h>

int unimportant_var0 = 0;
void not_important()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);

	if (unimportant_var0)
		{
			printf("Printf can do that? Oh right I enabled that. It claimed so many lives. Level Cleared\n");
		}
	}

int main()
{
	not_important();
}
