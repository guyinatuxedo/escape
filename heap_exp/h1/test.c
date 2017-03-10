#include <stdlib.h>

#include <string.h>
#include <stdio.h>


struct internet {
  //      int priority;
        char *name;
};

void winner()
{
        printf("Penguins are cute");
}

int main(int argc, char **argv)
{
        struct internet *i1, *i2;

        i1 = malloc(sizeof(struct internet));
	
 //       i1->priority = 1;
        i1->name = malloc(8);

        i2 = malloc(sizeof(struct internet));
   //     i2->priority = 2;
        i2->name = malloc(8);

        strcpy(i1->name, argv[1]);
        strcpy(i2->name, argv[2]);

        printf("and that's a wrap folks!\n");
}
