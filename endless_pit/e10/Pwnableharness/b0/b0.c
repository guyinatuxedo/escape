#include <stdio.h>
#include <stdlib.h>
#include "pwnable_harness.h"

static void handle_connection(int sock)
{
    char buffer[489];
    int g;
    g = 0;
    gets(buffer);
    if(g)
    {
        FILE* flag;
	char rflag[50];
	flag = fopen("flag.txt", "r");
	while (fgets(rflag, sizeof(rflag), flag))
	{
		printf("%s", rflag);
	}
    }

}

int main(int argc, char** argv)
{
	server_options opts = {
		.user = "ctf_b0",
		.chrooted = true,
		.port = 41236,
		.time_limit_seconds = 30
	};
	
	return server_main(argc, argv, opts, &handle_connection);
}
