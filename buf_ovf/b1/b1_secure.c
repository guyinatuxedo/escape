#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    fgets(buffer, sizeof(buffer), stdin);
    if(g == 0x44864486)
    {
        printf("Just a little bit harder. But not as hard as all of the research you have to do. Level Cleared!\n");
    }

}
