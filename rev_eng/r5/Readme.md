Let's take a look at the assembly code...

```
   0x080484eb <+0>:  lea    ecx,[esp+0x4]
   0x080484ef <+4>:  and    esp,0xfffffff0
   0x080484f2 <+7>:  push   DWORD PTR [ecx-0x4]
   0x080484f5 <+10>: push   ebp
   0x080484f6 <+11>: mov    ebp,esp
   0x080484f8 <+13>: push   ecx
   0x080484f9 <+14>: sub    esp,0x44
   0x080484fc <+17>: mov    eax,gs:0x14
   0x08048502 <+23>: mov    DWORD PTR [ebp-0xc],eax
   0x08048505 <+26>: xor    eax,eax
   0x08048507 <+28>: sub    esp,0xc
   0x0804850a <+31>: push   0x28
   0x0804850c <+33>: call   0x80483b0 <malloc@plt>
   0x08048511 <+38>: add    esp,0x10
   0x08048514 <+41>: mov    DWORD PTR [ebp-0x44],eax
   0x08048517 <+44>: mov    eax,DWORD PTR [ebp-0x44]
   0x0804851a <+47>: mov    DWORD PTR [eax],0x6c20684f
   0x08048520 <+53>: mov    DWORD PTR [eax+0x4],0x2c6b6f6f
   0x08048527 <+60>: mov    DWORD PTR [eax+0x8],0x77206120
   0x0804852e <+67>: mov    DWORD PTR [eax+0xc],0x6f207961
   0x08048535 <+74>: mov    DWORD PTR [eax+0x10],0x2e7475
   0x0804853c <+81>: mov    eax,ds:0x804a040
   0x08048541 <+86>: sub    esp,0x4
   0x08048544 <+89>: push   eax
   0x08048545 <+90>: push   0x32
   0x08048547 <+92>: lea    eax,[ebp-0x3e]
   0x0804854a <+95>: push   eax
   0x0804854b <+96>: call   0x8048390 <fgets@plt>
   0x08048550 <+101>:   add    esp,0x10
   0x08048553 <+104>:   movzx  edx,BYTE PTR [ebp-0x3e]
   0x08048557 <+108>:   mov    eax,DWORD PTR [ebp-0x44]
   0x0804855a <+111>:   movzx  eax,BYTE PTR [eax]
   0x0804855d <+114>:   cmp    dl,al
   0x0804855f <+116>:   jne    0x8048571 <main+134>
   0x08048561 <+118>:   sub    esp,0xc
   0x08048564 <+121>:   push   0x8048610
   0x08048569 <+126>:   call   0x80483c0 <puts@plt>
   0x0804856e <+131>:   add    esp,0x10
   0x08048571 <+134>:   mov    eax,0x0
   0x08048576 <+139>:   mov    ecx,DWORD PTR [ebp-0xc]
   0x08048579 <+142>:   xor    ecx,DWORD PTR gs:0x14
   0x08048580 <+149>:   je     0x8048587 <main+156>
   0x08048582 <+151>:   call   0x80483a0 <__stack_chk_fail@plt>
   0x08048587 <+156>:   mov    ecx,DWORD PTR [ebp-0x4]
   0x0804858a <+159>:   leave  
   0x0804858b <+160>:   lea    esp,[ecx-0x4]
   0x0804858e <+163>:   ret    
```

So looking at this, we can see that it doesn't loop like the previous challenges. There is only a single cmp instruction, and whatever it evaluates to the program doesn't go back. If we look at the call instructions, we see that there are four seperate functions called malloc, fgets, puts, and a stack fault check (which for our purposes we can ignore the check). Malloc is a function that allocates space in the heap. Since the hex value 0x28 (in decimal form it's 40) is pushed onto the stack before that, we can assume that the space of the allocated memory is 40. One thing about the malloc function as you can see, the space allocated isn't referenced before malloc is called so we will have to find it later on. Looking on we see a memory referenced located at ebp-0x3e. Since the only other memory on that register that is less than 0x3e is ebp-0xc, the size of the memory located at ebp-0x3e should be equal to 0x3e - 0xc (which equals 50). Because of the size of that, it probably isn't the space that was allocated via the malloc call.

Looking later on, we see that there is an fgets() call that will store user input at ebp-0x3e (since it is pushed onto the stack prior to the fgets call). In addition to that since 0x32 (hex for the decimal 50) is pushed on to the stack prior to ebp-0x3e, it probably means that fgets will only accept 50 characters. 

Looking on, we see that the cmp instruction compares dl with al (which is the 8 bit register version of the edx and eax registers). Beofe that happens, we see that ebp-0x3e is moved into the edx register, and ebp-0x44 is moved into the eax register. This would lead as to believe that the value of ebp-0x3e is being compared to ebp-0x44. Now we know what ebp-0x3e is, but the ebp-0x44 is probably the space that was allocated via the malloc call. 

Now we need to know what the value of ebp-0x44 is. After the malloc call, we see that it is located into the eax register, and then a series of values are loaded into the eax register in 4 byte increments. This looks like a strcpy call, and each individual copy is an individual segment of characters (segments are sperated by spaces) and since strings in C are 4 bytes it leads credibillity to this theory. Now to find out what the values of thos strings are we will have to use gdb.

First set a breakpoint for right after the alledged strcpy function.
```
gdb-peda$ b *main+86
Breakpoint 1 at 0x8048541
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r5/r5 
```

Now let's see the value of the ebp-0x44 register. Keep in mind that since it is a pointer, that value there should be an address that we will need to analyze.
```
Breakpoint 1, 0x08048541 in main ()
gdb-peda$ x/x $ebp-0x44
0xffffd004: 0x0804b008
gdb-peda$ x/s 0x0804b008
0x804b008:  "Oh look, a way out!"
```

Ok so the memeory located at ebp-0x44 should contain the string "Oh look, a way out!". Let's run the program outside of gdb, and feed that string into the fgets command and then since both of the memory spaces that are being evaluated will be equal, it should pass the cmp check and run the puts command.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r5$ ./r5
Oh look, a way out!
Do you really think you can escape?
guyinatuxedo@tux:/Hackery/escape/rev_eng/r5$ cat r5.c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
   char *buf1;
   buf1 = (char*) malloc(40);
   strcpy(buf1, "Oh look, a way out!");
   char buf0[50];
   fgets(buf0, sizeof(buf0), stdin);
   if (*buf0 == *buf1)
   {
      printf("Do you really think you can escape?\n");   
   }

}
```

And just like that, we reversed the binary.
