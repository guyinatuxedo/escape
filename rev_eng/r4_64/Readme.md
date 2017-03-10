Let's take a look at the assembly code...

```
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x20
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x14],edi
   0x0000000000400531 <+11>:  mov    QWORD PTR [rbp-0x20],rsi
   0x0000000000400535 <+15>:  mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:  jmp    0x40056b <main+69>
   0x000000000040053e <+24>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400541 <+27>:  cdqe   
   0x0000000000400543 <+29>:  lea    rdx,[rax*8+0x0]
   0x000000000040054b <+37>:  mov    rax,QWORD PTR [rbp-0x20]
   0x000000000040054f <+41>:  add    rax,rdx
   0x0000000000400552 <+44>:  mov    rax,QWORD PTR [rax]
   0x0000000000400555 <+47>:  mov    rsi,rax
   0x0000000000400558 <+50>:  mov    edi,0x400604
   0x000000000040055d <+55>:  mov    eax,0x0
   0x0000000000400562 <+60>:  call   0x400400 <printf@plt>
   0x0000000000400567 <+65>:  add    DWORD PTR [rbp-0x4],0x1
   0x000000000040056b <+69>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040056e <+72>:  cmp    eax,DWORD PTR [rbp-0x14]
   0x0000000000400571 <+75>:  jl     0x40053e <main+24>
   0x0000000000400573 <+77>:  mov    eax,0x0
   0x0000000000400578 <+82>:  leave  
   0x0000000000400579 <+83>:  ret    
End of assembler dump.
```

Looking at this code, we see that it is similar to the previous challenge. However this time it establishes an int at rbp-0x4, and then it appears to compare that against rbp-0x14 (which starts off at 1). If the value of the integer located at rbp-0x14 is less than the value of the eax register, then it issues a printf statement and it adds one to the integer. 

Now the eax register can typically server to pass data to and from a method. Because of this, we can tell that the eax register probably holds data that the user passed to the program (argc and argv). The first thing we see in the loop at main+29 is the int located at ebp-0xc is loaded into the eax register. In C arguments passed to the program are stored in the array argv[]. To call a particular item from argv[] you have to specify an item via an integer. The first item in argv[] is the program's name, however that is stored at argv[0]. Here we are starting off with 1, so we will load argv[1] which will be the first argument other than the binaries name. So it should just print out each item in argv[] untill it runs out of items.

Now for the cmp instruction against eax, it's not comparing the int stored at rbp-0x4 against any value of argv[]. We can see that the process the eap register goes through before it is compared isn't nearly as long as the the process it goes throug before it is printed. It is probably comparing the amount of arguments that is passed to the binary, which is argc. So by our analysis this loop should run for as many arguments that we give the username other than the program's name, and print out each of those objects. Let's see if gdb agrees with us (one thing, you see the cdqe instruction, that copies the value of the eax register into it's 64 bit counterpart rax).

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x20
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x14],edi
   0x0000000000400531 <+11>:  mov    QWORD PTR [rbp-0x20],rsi
   0x0000000000400535 <+15>:  mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:  jmp    0x40056b <main+69>
   0x000000000040053e <+24>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400541 <+27>:  cdqe   
   0x0000000000400543 <+29>:  lea    rdx,[rax*8+0x0]
   0x000000000040054b <+37>:  mov    rax,QWORD PTR [rbp-0x20]
   0x000000000040054f <+41>:  add    rax,rdx
   0x0000000000400552 <+44>:  mov    rax,QWORD PTR [rax]
   0x0000000000400555 <+47>:  mov    rsi,rax
   0x0000000000400558 <+50>:  mov    edi,0x400604
   0x000000000040055d <+55>:  mov    eax,0x0
   0x0000000000400562 <+60>:  call   0x400400 <printf@plt>
   0x0000000000400567 <+65>:  add    DWORD PTR [rbp-0x4],0x1
   0x000000000040056b <+69>:  mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040056e <+72>:  cmp    eax,DWORD PTR [rbp-0x14]
   0x0000000000400571 <+75>:  jl     0x40053e <main+24>
   0x0000000000400573 <+77>:  mov    eax,0x0
   0x0000000000400578 <+82>:  leave  
   0x0000000000400579 <+83>:  ret    
End of assembler dump.
gdb-peda$ b *main+55
Breakpoint 1 at 0x40055d
gdb-peda$ b *main+66
Breakpoint 2 at 0x400568
gdb-peda$ r
```

One wall of text later...

```
Breakpoint 1, 0x000000000040055d in main ()
gdb-peda$ x $rax
0x7fffffffe2ba:   0x3131310030303030
gdb-peda$ x/s 0x400604
0x400604:   "You told me %s.\n"
gdb-peda$ b *main+69
Breakpoint 2 at 0x40056b
gdb-peda$ c
```

```
Breakpoint 2, 0x000000000040056b in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde3c:   0x00000002
gdb-peda$ x/d $rbp-0x4
0x7fffffffde3c:   2
```

```
gdb-peda$ x $rax
0x7fffffffe2bf:   0x4744580031313131
gdb-peda$ c
```

```
Breakpoint 2, 0x000000000040056b in main ()
gdb-peda$ x/w $rbp-0x4
0x7fffffffde3c:   0x00000003
gdb-peda$ x/d $rbp-0x4
0x7fffffffde3c:   3
gdb-peda$ c
```

Then the program exits. So we saw the string it prints out, also how it changes per iteration. We gave the program three arguments (it's name and "0000" plus "1111"), of which in the first iteration "0000" and "1111" appeared to be in the rax register, wherea in the second iteration only the third argument appeared to be in there. This provides evidence that our earlier thought of it printing out whatever arguments you gave it to be true (Also the fact that the string being printed is formatted to print out a string, which rax is moved onto the stack prior to printf being called). In addition to that, it makes since for the int to start off at 1, since argv[0] is the binary's name. Also notice how the binary ran as many times as arguments that we gave it (with the exception of the binary's name), probably caused by the compare of the rb-0x14 int against eax register. Let's see if that holds true (along with our previous claims).

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r4_64$ ./r4_64 0 1 2 3 4 5
You told me 0.
You told me 1.
You told me 2.
You told me 3.
You told me 4.
You told me 5.
guyinatuxedo@tux:/Hackery/escape/rev_eng/r4_64$ ./r4_64 
guyinatuxedo@tux:/Hackery/escape/rev_eng/r4_64$ ./r4_64 11 22222 3
You told me 11.
You told me 22222.
You told me 3.
```

So that appears to hold true. The reason why it compares eax against rbp-0x14 instead of rbp-0x4, is because early in the program it has the edi register moved into rbp-0x14's location. The edi register is used for string and memory array copying, storage, and scanning. This allows it to be used for this comparison. So from our findings, we can conclude that this program will take frist establish an int that starts at run, then runs a loop for as many arguments it revieves other than it's name. For each argument it get's it will print it out. Once it is out of arguments, the loop should end and the binary should exit. let's look at the source code.

```
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
   int i;

   for (i = 1; i < argc; i++)
   {
      printf("You told me %s.\n", argv[i]);
   }  
}
```

Just like that, we reversed the binary!
