Let's take a look ath the assembly code...

```
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x10
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400535 <+15>:  mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:  mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400543 <+29>:  jmp    0x400560 <main+58>
   0x0000000000400545 <+31>:  shl    DWORD PTR [rbp-0x4],1
   0x0000000000400548 <+34>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040054b <+37>:  mov    esi,eax
   0x000000000040054d <+39>:  mov    edi,0x4005f4
   0x0000000000400552 <+44>:  mov    eax,0x0
   0x0000000000400557 <+49>:  call   0x400400 <printf@plt>
   0x000000000040055c <+54>:  add    DWORD PTR [rbp-0x8],0x1
   0x0000000000400560 <+58>:  cmp    DWORD PTR [rbp-0x8],0x9
   0x0000000000400564 <+62>:  jle    0x400545 <main+31>
   0x0000000000400566 <+64>:  mov    eax,0x0
   0x000000000040056b <+69>:  leave  
   0x000000000040056c <+70>:  ret    
End of assembler dump.
```

So we can see, right off the bat at  main+8, it moves the hex value 0x0 (decimal for 0) into the memory location rbp-0x8 so this is likely a variable. In addition to that there is a similar variable being made at main+15 with it moving the 0x1 (hex for the decimal 1) into a space at rbp-0x4.  It then jumps to main+58, where it compares the value of rbp-0x8] against 0x9 (hex fore the decimal 9). If it is evaluated as less then or equal to 9, it will jump to main+31. After it jumps to main+31, we can see that it runs the shl on the variable stored at rbp-0x4 (so it is probably an int), which sifts it over my one which essentially just multiplies the int by 2^x where x is the amount it is being shifted by. After that we can see that it prints out something from 0x4005f4, and it appears that rbp-0x4 is moved onto the stack as well so it is probably printed out to. After that, the value that is actually being evaluated rbp-0x8 is incremented by one. Let's see this in action.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x10
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400535 <+15>:  mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:  mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400543 <+29>:  jmp    0x400560 <main+58>
   0x0000000000400545 <+31>:  shl    DWORD PTR [rbp-0x4],1
   0x0000000000400548 <+34>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040054b <+37>:  mov    esi,eax
   0x000000000040054d <+39>:  mov    edi,0x4005f4
   0x0000000000400552 <+44>:  mov    eax,0x0
   0x0000000000400557 <+49>:  call   0x400400 <printf@plt>
   0x000000000040055c <+54>:  add    DWORD PTR [rbp-0x8],0x1
   0x0000000000400560 <+58>:  cmp    DWORD PTR [rbp-0x8],0x9
   0x0000000000400564 <+62>:  jle    0x400545 <main+31>
   0x0000000000400566 <+64>:  mov    eax,0x0
   0x000000000040056b <+69>:  leave  
   0x000000000040056c <+70>:  ret    
End of assembler dump.
gdb-peda$ b *main+49
Breakpoint 1 at 0x400557
gdb-peda$ b *main+58
Breakpoint 2 at 0x400560
gdb-peda$ r
```

One wall of text later...

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000000
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   0
```

Onto the next breakpoint

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000002
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   2
gdb-peda$ x/s 0x4005f4
0x4005f4:   "The value of var0 is %d.\n"
```

So we can see the string being printed out is "The value of var0 is %d.\n". The decimal it is printing out (because of the %d) is probably the value stored at rbp-0x4 (so in this case it would be two). Now let's run the the rest of the program and see if the values of rbp-0x4 and rbp-0x8 change as expected.

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000001
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   1
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000004
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   4
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000002
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   2
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000008
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   8
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   3
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   3
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000010
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   16
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000004
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   4
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000020
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   32
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000005
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   5
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000040
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   64
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000006
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   6
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000080
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   128
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000007
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   7
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000100
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   256
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000008
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   8
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000200
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   512
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x00000009
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   9
gdb-peda$ c
```

```
Breakpoint 1, 0x0000000000400557 in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde5c:   0x00000400
gdb-peda$ x/d $rbp-0x4
0x7fffffffde5c:   1024
gdb-peda$ c
```

```
Breakpoint 2, 0x0000000000400560 in main ()
gdb-peda$ x/w $rbp-0x8
0x7fffffffde58:   0x0000000a
gdb-peda$ x/d $rbp-0x8
0x7fffffffde58:   10
gdb-peda$ c
Continuing.
[Inferior 1 (process 24921) exited normally]
Warning: not running or target is remote
```

Then the program ends. So the values changed as expected. The value at rbp-0x4 was multiplied by two every time the loop was run, in addition to that it was the value being printed. Also the value at rbp-0x8 was incremented by 1 every time the loop ran. When the int at rbp-0x8 reached 10, the program exited because the cmp function did not evaluate as less than or equal to. So from our findings, the program is one that establishes two variables, one that starts at 1 and the other at 0. Then a loop runds where for each iteartion of the loop, the variable that is started off at 1 is multiplied by two and printed out along with some string. The other variable is incremented by one for each iteration. And when the variable being incremented by one reaches 10, the loop ends and the program exits. Let's look at the source code to confirm this.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r3_64$ cat r3_64.c
#include <stdlib.h>
#include <stdio.h>
int main()
{
   int i = 0;
   int var0 = 1;
   for (i = 0; i < 10; i++)
   {
      var0 = var0*2;
      printf("The value of var0 is %d.\n", var0);
   }
}
```

Just like that, we reversed the binary.

