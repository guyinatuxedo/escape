Let's take a look at the source code...

```
Dump of assembler code for function main:
   0x0804840b <+0>:  lea    ecx,[esp+0x4]
   0x0804840f <+4>:  and    esp,0xfffffff0
   0x08048412 <+7>:  push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>: push   ebp
   0x08048416 <+11>: mov    ebp,esp
   0x08048418 <+13>: push   ecx
   0x08048419 <+14>: sub    esp,0x14
   0x0804841c <+17>: mov    DWORD PTR [ebp-0x10],0x0
   0x08048423 <+24>: mov    DWORD PTR [ebp-0xc],0x1
   0x0804842a <+31>: mov    DWORD PTR [ebp-0x10],0x0
   0x08048431 <+38>: jmp    0x804844d <main+66>
   0x08048433 <+40>: shl    DWORD PTR [ebp-0xc],1
   0x08048436 <+43>: sub    esp,0x8
   0x08048439 <+46>: push   DWORD PTR [ebp-0xc]
   0x0804843c <+49>: push   0x80484e0
   0x08048441 <+54>: call   0x80482e0 <printf@plt>
   0x08048446 <+59>: add    esp,0x10
   0x08048449 <+62>: add    DWORD PTR [ebp-0x10],0x1
   0x0804844d <+66>: cmp    DWORD PTR [ebp-0x10],0x9
   0x08048451 <+70>: jle    0x8048433 <main+40>
   0x08048453 <+72>: mov    eax,0x0
   0x08048458 <+77>: mov    ecx,DWORD PTR [ebp-0x4]
   0x0804845b <+80>: leave  
   0x0804845c <+81>: lea    esp,[ecx-0x4]
   0x0804845f <+84>: ret    
End of assembler dump.
```

So looking at this code, we see that it has a lot of similarities with the previous challenge. however there are a couple of differences. For instance, ti appears that there are two integers, one stored at ebp-0xc and one at epb-0x10 (notice that there are four bytes between the two locations, and ints in C are 4 bytes). It appears like the int stored at ebp-0x10 is the one that is being evaluated against 9 this time, and ebp-0x10. The variable stored at ebp-0xc is the one that is being printed. However before it is printed it is being shifted by one via the shl instruction. What this instance will essentially multiply ebp-0xc by 2^x, where x is the second argument given. Since x in this case is 1, then ebp-0xc will be multiplied by 2 then printed. So essentially this program should run ten times, each time it will print out a number starting with 2, then print out two times the number in the previous loop. Let's see this in action using gdb.

```
gdb-peda$ b *main+59
Breakpoint 1 at 0x8048446
gdb-peda$ r
```

```
gdb-peda$ x $esp
0xffffd6a0: 0x080484e0
gdb-peda$ x/s 0x080484e0
0x80484e0:  "The value of var0 is %d.\n"
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 2
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 0
```

```
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 1
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 4
```

```
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 2
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 8
```

```
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 3
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 16
```

```
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 4
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 32
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 64
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 5
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 128
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 6
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 256
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 7
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 512
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 8
```

```
gdb-peda$ x/d $ebp-0x10
0xffffd6b8: 9
gdb-peda$ x/d $ebp-0xc
0xffffd6bc: 1024
```

So that appears to be what we expected. Let's compare our analysis against running the program outside of gdb, and the actual C code.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r3$ ./r3
The value of var0 is 2.
The value of var0 is 4.
The value of var0 is 8.
The value of var0 is 16.
The value of var0 is 32.
The value of var0 is 64.
The value of var0 is 128.
The value of var0 is 256.
The value of var0 is 512.
The value of var0 is 1024.
guyinatuxedo@tux:/Hackery/escape/rev_eng/r3$ cat r3.c
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

And just like that, we reversed the binary.





















