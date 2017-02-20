First let's see what type of file it is.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r1_64$ file r1_64
r1_64: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=fd9e519f1cafebafc4e9abc8d6bc56e1de625af7, not stripped
```

Now that we know it is a 64 bit Executable Linux file, let's take a look at the assembly code...

```
Dump of assembler code for function main:
   0x0000000000400526 <+0>:   push   rbp
   0x0000000000400527 <+1>:   mov    rbp,rsp
   0x000000000040052a <+4>:   sub    rsp,0x10
   0x000000000040052e <+8>:   mov    DWORD PTR [rbp-0x4],0x1
   0x0000000000400535 <+15>:  cmp    DWORD PTR [rbp-0x4],0x0
   0x0000000000400539 <+19>:  je     0x400545 <main+31>
   0x000000000040053b <+21>:  mov    edi,0x4005d4
   0x0000000000400540 <+26>:  call   0x400400 <puts@plt>
   0x0000000000400545 <+31>:  mov    eax,0x0
   0x000000000040054a <+36>:  leave  
   0x000000000040054b <+37>:  ret    
End of assembler dump.

```

So looking at this, a couple of things pop out. First there is a cmp. and a je instruction. It is comparing the value of whatever the address stored at "rbp-0x4" ia pointing to ro 0, and if it is equal to zero it then it is jumping to main+46, which appears to be at the end of the program. If it is not equal to it, then it will use a puts call and the program exits. In addition to that, right before the cmp instruction, it appears to load the hex value 0x1 (which is hex for the decimal value 1) into the same register location that is being evaluated rbp-0x4.

Now looking over the assembly code, we can tell that the value being evaluated is an int. The reason for this being is 0x1 in ascii isn't a character typically used. In addition to that, it is being evaluated to see if it is equal to 0 which is what happens when an integer is your condition in C. So the program probably established an in located at rbp-0x4, sets it equal to 1, checks to see if it is not equal to 0, and then prints out something. Let's see what it is equal to, using the same process as r0.


```
gdb-peda$ b *main+31
Breakpoint 1 at 0x400545
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r1_64/r1_64 

```  

One wall of text later...

```
Breakpoint 1, 0x0000000000400545 in main ()
gdb-peda$ x 0x4005d4
   0x4005d4:   push   rsi
gdb-peda$ x/s 0x4005d4
0x4005d4:   "Var0 != 0"

```

From the looks of it, it looks like it prints out "Var0 != 0", which is in line with our previous analysis. Let's try running the elf.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r1_64$ ./r1_64 
Var0 != 0
```

Ok so it did what we expected it to, Let;s look at the C code.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r1$ cat r1.c
#include <stdlib.h>
#include <stdio.h>

int main()
{
   int var0 = 1;
   if (var0)
   {
      printf("Var0 != 0\n");
   }
}
```

And as we can see from the code, just like that we reversed the binary.
