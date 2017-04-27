#include <stdio.h>
#include <stdlib.h>

int main()
{
    	char *str = "Chalk";
        unsigned long hash = 5381;
	printf("%s\n", str);
	int c;

        while (c = *str++)
            hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

 	printf("%lu\n", hash);
    
}
