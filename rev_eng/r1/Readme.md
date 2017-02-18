Let's take a look at the assembly code...

```
Dump of assembler code for function main:
   0x0804840b <+0>:  lea    ecx,[esp+0x4]
   0x0804840f <+4>:  and    esp,0xfffffff0
   0x08048412 <+7>:  push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>: push   ebp
   0x08048416 <+11>: mov    ebp,esp
   0x08048418 <+13>: push   ecx
   0x08048419 <+14>: sub    esp,0x14
   0x0804841c <+17>: mov    DWORD PTR [ebp-0xc],0x1
   0x08048423 <+24>: cmp    DWORD PTR [ebp-0xc],0x0
   0x08048427 <+28>: je     0x8048439 <main+46>
   0x08048429 <+30>: sub    esp,0xc
   0x0804842c <+33>: push   0x80484d0
   0x08048431 <+38>: call   0x80482e0 <puts@plt>
   0x08048436 <+43>: add    esp,0x10
   0x08048439 <+46>: mov    eax,0x0
   0x0804843e <+51>: mov    ecx,DWORD PTR [ebp-0x4]
   0x08048441 <+54>: leave  
   0x08048442 <+55>: lea    esp,[ecx-0x4]
   0x08048445 <+58>: ret    
End of assembler dump.
```

So looking at this, a couple of things pop out. First there is a cmp. and a je instruction. It is comparing the value of whatever is stored at "ebp-0xc" to 0, and if it is to it then it is jumping to main+46, which appears to be at the end of the program. If it is not equal to it, then it will use a puts call and the program exits. In addition to that, right before the cmp instruction, it appears to load the hex value 0x1 (which is hex for the decimal value 1) into the same register location that is being evaluated ebp-0xc.

Now looking over the assembly code, we can tell that the value being evaluated is an int. The reason for this being is 0x1 in ascii isn't a character typically used. In addition to that, it is being evaluated to see if it is equal to 0 which is what happens when an integer is your condition in C. So the program probably established an in located at ebp-0xc, sets it equal to 1, checks to see if it is not equal to 0, and then prints out something. Let's see what it is equal to, using the same process as r0.


```
gdb-peda$ b *main+43
Breakpoint 1 at 0x8048436
gdb-peda$ r
Starting program: /Hackery/escape/rev_eng/r1/r1
```  

One wall of text later...

```
Breakpoint 1, 0x08048436 in main ()
gdb-peda$ x/20x $esp
0xffffd020: 0x080484d0  0x00000007  0xf7e30a50  0x0804849b
0xffffd030: 0x00000001  0xffffd0f4  0xffffd0fc  0x00000001
0xffffd040: 0xf7fb43dc  0xffffd060  0x00000000  0xf7e1a637
0xffffd050: 0xf7fb4000  0xf7fb4000  0x00000000  0xf7e1a637
0xffffd060: 0x00000001  0xffffd0f4  0xffffd0fc  0x00000000
gdb-peda$ x/s 0x080484d0
0x80484d0:  "Var0 != 0"
```

From the looks of it, it looks like it prints out "Var0 != 0", which is in line with our previous analysis. Let's try running the elf.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r1$ ./r1
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





























