#include <stdio.h>
#include <stdlib.h>

int main()
{
    srand(time(NULL));
    char input1[20];
    char input2[5];
    int f;
    int c = 0;
    f = rand() % 100 + 1;
    
    printf("We finally patched that pesky buffer overflow vulnerabillity.\n");
    fgets(input1, sizeof(input1), stdin);
    printf("%s\n", input1);
    printf("So now you can do your favorite thing in the world!\n");
    fgets(input2, sizeof(input2), stdin);
    c = atoi(input2);
    if(c == f)
    {
       	printf("If you keep on going, we will have to cancel the celebration. Level Cleared\n");	
    }

   else
   {
	printf("You must really love to research.\n");
   }
}


