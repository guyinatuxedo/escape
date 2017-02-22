Let's take a look at the assembly code...

```
   0x0000000000400666 <+0>:   push   rbp
   0x0000000000400667 <+1>:   mov    rbp,rsp
   0x000000000040066a <+4>:   sub    rsp,0x50
   0x000000000040066e <+8>:   mov    rax,QWORD PTR fs:0x28
   0x0000000000400677 <+17>:  mov    QWORD PTR [rbp-0x8],rax
   0x000000000040067b <+21>:  xor    eax,eax
   0x000000000040067d <+23>:  mov    edi,0x28
   0x0000000000400682 <+28>:  call   0x400550 <malloc@plt>
   0x0000000000400687 <+33>:  mov    QWORD PTR [rbp-0x48],rax
   0x000000000040068b <+37>:  mov    rax,QWORD PTR [rbp-0x48]
   0x000000000040068f <+41>:  movabs rcx,0x2c6b6f6f6c20684f
   0x0000000000400699 <+51>:  mov    QWORD PTR [rax],rcx
   0x000000000040069c <+54>:  movabs rsi,0x6f20796177206120
   0x00000000004006a6 <+64>:  mov    QWORD PTR [rax+0x8],rsi
   0x00000000004006aa <+68>:  mov    DWORD PTR [rax+0x10],0x217475
   0x00000000004006b1 <+75>:  mov    rdx,QWORD PTR [rip+0x200998]        # 0x601050 <stdin@@GLIBC_2.2.5>
   0x00000000004006b8 <+82>:  lea    rax,[rbp-0x40]
   0x00000000004006bc <+86>:  mov    esi,0x32
   0x00000000004006c1 <+91>:  mov    rdi,rax
   0x00000000004006c4 <+94>:  call   0x400540 <fgets@plt>
   0x00000000004006c9 <+99>:  movzx  edx,BYTE PTR [rbp-0x40]
   0x00000000004006cd <+103>: mov    rax,QWORD PTR [rbp-0x48]
   0x00000000004006d1 <+107>: movzx  eax,BYTE PTR [rax]
   0x00000000004006d4 <+110>: cmp    dl,al
   0x00000000004006d6 <+112>: jne    0x4006e2 <main+124>
   0x00000000004006d8 <+114>: mov    edi,0x400788
   0x00000000004006dd <+119>: call   0x400510 <puts@plt>
   0x00000000004006e2 <+124>: mov    eax,0x0
   0x00000000004006e7 <+129>: mov    rcx,QWORD PTR [rbp-0x8]
   0x00000000004006eb <+133>: xor    rcx,QWORD PTR fs:0x28
   0x00000000004006f4 <+142>: je     0x4006fb <main+149>
   0x00000000004006f6 <+144>: call   0x400520 <__stack_chk_fail@plt>
   0x00000000004006fb <+149>: leave  
   0x00000000004006fc <+150>: ret    
```

So looking at this, we can see that it doesn't loop like the previous challenges. There is only a single cmp instruction, and whatever it evaluates to the program doesn't go back. If we look at the call instructions, we see that there are four seperate functions called malloc, fgets, puts, and a stack fault check (which for our purposes we can ignore the check). Malloc is a function that allocates space in the heap. Since the hex value 0x28 (in decimal form it's 40) is pushed onto the stack before that, we can assume that the space of the allocated memory is 40. One thing about the malloc function as you can see, the space allocated isn't referenced before malloc is called so we will have to find it later on. Looking on we see a memory referenced located at 

Looking later on, we see that there is an fgets() call that will store user input at rbp-0x40 (since it is pushed onto the stack prior to the fgets call). In addition to that since 0x32 (hex for the decimal 50) is pushed on to the stack prior to RBP-0x40, it probably means that fgets will only accept 50 characters (and due to common coding practices, this probably means the rbp-0x40's length is 50). Because of this, rbp-0x40 probably isn't the space allocated by the malloc 

Looking on, we see that the cmp instruction compares dl with al (which is the 8 bit register version of the edx and eax registers). Beofe that happens, we see that rbp-0x40 is moved into the edx register, and rbp-0x48 is moved into the rax (then the rax register is moved into the eax register). This would lead as to believe that the value of rbp-0x48 is being compared to rbp-0x40 (by value, I mean the value of the address that is stored in those two registers are pointing to since they are pointers). Now we know what rbp-0x40 is, but the rbp-0x48 is probably the space that was allocated via the malloc call. 

Now we need to know what the value of rbp-0x48 is. After the malloc call, we see that it is located into the eax register, and then a series of values are loaded into the eax register in 8 byte increments. This looks like a strcpy call, whcih will take the string it is copying over, divide it into different sections and copy it over. Since strings in 64 bit C are 8 bytes it leads credibillity to this theory. Now to find out what the values of those strings are we will have to use gdb.

First set a breakpoint for right after the alledged strcpy function.
```
gdb-peda$ b *main+82
Breakpoint 1 at 0x4006b8
gdb-peda$ r

```

Now let's see the value of the rbp-0x48 register. Keep in mind that since it is a pointer, that value there should be an address that we will need to analyze.
```
Breakpoint 1, 0x00000000004006b8 in main ()
gdb-peda$ x/x $rbp-0x48
0x7fffffffde18:   0x0000000000602010
gdb-peda$ x/s 0x0000000000602010
0x602010:   "Oh look, a way out!"
```

Ok so the memeory located at rbp-0x48 should contain the string "Oh look, a way out!". Let's run the program outside of gdb, and feed that string into the fgets command and then since both of the memory spaces that are being evaluated will be equal, it should pass the cmp check and run the puts command.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r5_64$ ./r5_64 
Oh look, a way out!
Do you really think you can escape?
guyinatuxedo@tux:/Hackery/escape/rev_eng/r5_64$ cat r5_64.c
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

