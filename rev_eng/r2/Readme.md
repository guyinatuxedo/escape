Let's take a look ath the assembly code...

```
Dump of assembler code for function main:
   0x0804840b <+0>:  lea    ecx,[esp+0x4]
   0x0804840f <+4>:  and    esp,0xfffffff0
   0x08048412 <+7>:  push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>: push   ebp
   0x08048416 <+11>: mov    ebp,esp
   0x08048418 <+13>: push   ecx
   0x08048419 <+14>: sub    esp,0x14
   0x0804841c <+17>: mov    DWORD PTR [ebp-0xc],0x0
   0x08048423 <+24>: jmp    0x804843c <main+49>
   0x08048425 <+26>: sub    esp,0x8
   0x08048428 <+29>: push   DWORD PTR [ebp-0xc]
   0x0804842b <+32>: push   0x80484d0
   0x08048430 <+37>: call   0x80482e0 <printf@plt>
   0x08048435 <+42>: add    esp,0x10
   0x08048438 <+45>: add    DWORD PTR [ebp-0xc],0x1
   0x0804843c <+49>: cmp    DWORD PTR [ebp-0xc],0x4
   0x08048440 <+53>: jle    0x8048425 <main+26>
   0x08048442 <+55>: mov    eax,0x0
   0x08048447 <+60>: mov    ecx,DWORD PTR [ebp-0x4]
   0x0804844a <+63>: leave  
   0x0804844b <+64>: lea    esp,[ecx-0x4]
   0x0804844e <+67>: ret    
End of assembler dump.

```

So we can see, right off the bat at  main+17, it moves the hex value 0x0 (decimal for 0) into the memory location ebp-0xc. Then at main+24, it jumps to main+49 using a jmp insruction. At main+49 it compares the value stored at ebp-0xc against 0x4 (decimal for 4), and if it less than 4 it jumps to main+26 with a jle instruction. After it reaches main+26, it appears to print something out then add 1 to the value stored at ebp-0xc, then run the same cmp instruction. So what we are looking at there is probably a loop (while or for), that will run as long as an integer is less than 4. That integer probably starts off at 0. For each iteration of the loop, the integer has one added to it. Let's find out what it is.

```
gdb-peda$ b *main+42
Breakpoint 1 at 0x8048435
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r2/r2
```

One wall of text later...

```
gdb-peda$ x/20x $esp
0xffffd020: 0x080484d0  0x00000000  0xf7e30a50  0x0804849b
0xffffd030: 0x00000001  0xffffd0f4  0xffffd0fc  0x00000000
0xffffd040: 0xf7fb43dc  0xffffd060  0x00000000  0xf7e1a637
0xffffd050: 0xf7fb4000  0xf7fb4000  0x00000000  0xf7e1a637
0xffffd060: 0x00000001  0xffffd0f4  0xffffd0fc  0x00000000
gdb-peda$ x 0x080484d0
0x80484d0:  0x20656854
gdb-peda$ x/s 0x080484d0
0x80484d0:  "The current value of i is %d\n"
```

So this is something new. It appears to be printing out a decimal value, that is imported from an integer. However when we look at the assembly code, we see that the same integer being evaluated and incremented each iteration of the loop is also psuhed onto the stack right beofre the printf statement.

```
   0x08048428 <+29>: push   DWORD PTR [ebp-0xc]
   0x0804842b <+32>: push   0x80484d0
   0x08048430 <+37>: call   0x80482e0 <printf@plt>
```

Also, picking up from where we left off in gdb, if we examine the value of $ebp-0xc, see see that is incremented by one each time the loop runs.

```
gdb-peda$ x/d $ebp-0xc
0xffffd03c: 0
gdb-peda$ c
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd03c: 1
gdb-peda$ c
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd03c: 2
gdb-peda$ c
```
```
gdb-peda$ x/d $ebp-0xc
0xffffd03c: 3
gdb-peda$ c
```

```
gdb-peda$ x/d $ebp-0xc
0xffffd03c: 4
gdb-peda$ c
```

And the elf finishes. So judgin from the analysis, the binary starts off with an int that is equal to 0. Then the elf enters a loop where it will run if the int is less than 4. Each time the loop runs, it prints out the current value of the int along with a sentance, and increments the int by one. In the end the loop should run five times. Let's actually run the elf outside of gdb.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r2$ ./r2
The current value of i is 0
The current value of i is 1
The current value of i is 2
The current value of i is 3
The current value of i is 4
```

So that matches what we thought would happen. Let's compare our findings against the actual C code...

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r2$ cat r2.c
#include <stdlib.h>
#include <stdio.h>

int main()
{
   int i = 0;
   while (i<5)
   {
      printf("The current value of i is %d\n", i);
      i++;
   }
}
```

And just like that we reversed the binary.



















