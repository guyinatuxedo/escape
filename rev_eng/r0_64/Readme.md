Let's take a look at the assembly code...

```
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   mov    edi,0x4005c4
   0x000000000040052f <+9>:   call   0x400400 <puts@plt>
   0x0000000000400534 <+14>:  mov    eax,0x0
   0x0000000000400539 <+19>:  pop    rbp
   0x000000000040053a <+20>:  ret 
```

So looking through the assembly code, a couple of things stick out. The first is the function call it makes.

```
   0x000000000040052f <+9>:   call   0x400400 <puts@plt>
```

So looking at that, it is fairly obvious that it calls the function puts() which is a low level function used by printf (or puts could be present in the C code). So with this we know the the program is probably printing something out.

Looking through the rest of the assembly code, nothing else big jumps out. There are no other call instructions, and no cmp, jmp, or jle instructions. So there really shouldn't be anything else to this program other than that it prints something. Let's find out what it prints using gdb.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0_64$ gdb ./r0_64
```

One wall of text later...

Let's set a breakpoint for right after the call to puts, so we can see what it is about to print out
```
gdb-peda$ b *0x0000000000400534
Breakpoint 1 at 0x400534
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r0_64/r0_64 
```

Another wall of text later...

Now since looking at the assembly, right before puts is called the address 0x4005c4 is loaded into the edi register. Since arguments are pushed onto the stack prior to a function call, the string might be in that register. Let's take a look
```
Breakpoint 1, 0x0000000000400534 in main ()
gdb-peda$ x 0x4005c4
0x4005c4:   0x6f57206f6c6c6548
gdb-peda$ x/s 0x4005c4
0x4005c4:   "Hello World!"
```

So it is safe to say that the string it prints out is "Hello World!". Let's run the program to see if it matches this.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0$ ./r0_64
Hello World!
guyinatuxedo@tux:/Hackery/escape/rev_eng/r0_64$ cat r0_64.c
#include <stdlib.h>
#include <stdio.h>

int main()
{
   printf("Hello World!\n");
}

guyinatuxedo@tux:/Hackery/escape/rev_eng/r0_64$ 
```

So just like that, we reversed the binary.
 

