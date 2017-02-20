Let's take a look ath the assembly code...

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x10
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x4],0x0
   0x0000000000400535 <+15>:  jmp    0x40054f <main+41>
   0x0000000000400537 <+17>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040053a <+20>:  mov    esi,eax
   0x000000000040053c <+22>:  mov    edi,0x4005e4
   0x0000000000400541 <+27>:  mov    eax,0x0
   0x0000000000400546 <+32>:  call   0x400400 <printf@plt>
   0x000000000040054b <+37>:  add    DWORD PTR [rbp-0x4],0x1
   0x000000000040054f <+41>:  cmp    DWORD PTR [rbp-0x4],0x4
   0x0000000000400553 <+45>:  jle    0x400537 <main+17>
   0x0000000000400555 <+47>:  mov    eax,0x0
   0x000000000040055a <+52>:  leave  
   0x000000000040055b <+53>:  ret    
End of assembler dump.
gdb-peda$ 
```

So we can see, right off the bat at  main+8, it moves the hex value 0x0 (decimal for 0) into the memory location rbp-0x4. Then at main+15, it jumps to main+41 using a jmp insruction. At main+41 it compares the value stored at rbp-0x4 against 0x4 (decimal for 4), and if it less than 4 it jumps to main+17 with a jle instruction. After it reaches main+17, it appears to print something out then add 1 to the value stored at rbp-0x4, then run the same cmp instruction. So what we are looking at there is probably a loop (while or for), that will run as long as an integer is less than 4. That integer probably starts off at 0. For each iteration of the loop, the integer has one added to it. Let's find out what it is.

```
gdb-peda$ b *main+37
Breakpoint 1 at 0x40054b
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r2_64/r2_64 
```

One wall of text later...

```
Breakpoint 1, 0x000000000040054b in main ()
gdb-peda$ x/s 0x4005e4
0x4005e4:   "The current value of i is %d\n"
```

So this is something new. It appears to be printing out a decimal value, that is imported from an integer. However when we look at the assembly code, we see that the same integer being evaluated and incremented each iteration of the loop is also psuhed onto the stack before the printf statement.

```
   0x0000000000400537 <+17>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040053a <+20>:  mov    esi,eax
   0x000000000040053c <+22>:  mov    edi,0x4005e4
   0x0000000000400541 <+27>:  mov    eax,0x0
   0x0000000000400546 <+32>:  call   0x400400 <printf@plt>
```

Also, picking up from where we left off in gdb, if we examine the value of $rbp-0x4, see see that is incremented by one each time the loop runs.



Left off here............................





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

