This level is like the previous in which you are not pwning anything, but messing around with stuff so you won't need to have the program print out "level cleared". This time we are going to be looking at op codes from programs. Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int main()
{
        puts("starting");
        setreuid(getuid(), getuid());
        system("/bin/sh");
        puts("ending");
}
```

When we look at this we see a C program that essentially prints a string, starts a shell, then prints another string. However we know that the C code isn't the code that is being run. What is being run are the op codes that the compiler makes based upon the C code. We can see this using objdump.

```
$	objdump -D e11 -M intel | less
```

Then we can scroll down to see the main function.

```
080484ab <main>:
 80484ab:       8d 4c 24 04             lea    ecx,[esp+0x4]
 80484af:       83 e4 f0                and    esp,0xfffffff0
 80484b2:       ff 71 fc                push   DWORD PTR [ecx-0x4]
 80484b5:       55                      push   ebp
 80484b6:       89 e5                   mov    ebp,esp
 80484b8:       53                      push   ebx
 80484b9:       51                      push   ecx
 80484ba:       83 ec 0c                sub    esp,0xc
 80484bd:       68 a0 85 04 08          push   0x80485a0
 80484c2:       e8 99 fe ff ff          call   8048360 <puts@plt>
 80484c7:       83 c4 10                add    esp,0x10
 80484ca:       e8 81 fe ff ff          call   8048350 <getuid@plt>
 80484cf:       89 c3                   mov    ebx,eax
 80484d1:       e8 7a fe ff ff          call   8048350 <getuid@plt>
 80484d6:       83 ec 08                sub    esp,0x8
 80484d9:       53                      push   ebx
 80484da:       50                      push   eax
 80484db:       e8 a0 fe ff ff          call   8048380 <setreuid@plt>
 80484e0:       83 c4 10                add    esp,0x10
 80484e3:       83 ec 0c                sub    esp,0xc
 80484e6:       68 a9 85 04 08          push   0x80485a9
 80484eb:       e8 80 fe ff ff          call   8048370 <system@plt>
 80484f0:       83 c4 10                add    esp,0x10
 80484f3:       83 ec 0c                sub    esp,0xc
 80484f6:       68 b1 85 04 08          push   0x80485b1
 80484fb:       e8 60 fe ff ff          call   8048360 <puts@plt>
 8048500:       83 c4 10                add    esp,0x10
 8048503:       b8 00 00 00 00          mov    eax,0x0
 8048508:       8d 65 f8                lea    esp,[ebp-0x8]
 804850b:       59                      pop    ecx
 804850c:       5b                      pop    ebx
 804850d:       5d                      pop    ebp
 804850e:       8d 61 fc                lea    esp,[ecx-0x4]
 8048511:       c3                      ret    
 8048512:       66 90                   xchg   ax,ax
 8048514:       66 90                   xchg   ax,ax
 8048516:       66 90                   xchg   ax,ax
 8048518:       66 90                   xchg   ax,ax
 804851a:       66 90                   xchg   ax,ax
 804851c:       66 90                   xchg   ax,ax
 804851e:       66 90                   xchg   ax,ax
```

So we can see the assembly code, and the address of each line of assembly code. Of course the assembly code isn't what is being executed, but a human readable representation of what is. The hex strings inbetween the address and the assembly code is the op codes that are actually being executed. For instance to run the system function, the following op code is executed.

```
	\x83\xc4\x10
	\x83\xec\x0c
	\x68\xa9\x85\x04\x08
	\xe7\x80\xfe\xff\xff
```

However since the code that is actually being run isn't easy to read, we can view the assembly code representation of it.

```
	add    esp,0x10
	sub    esp,0xc
	push   0x80485a9
	call   8048370 <system@plt>
```

Now when we inject shellcode into a binary, we are injecting shellcode. For instance take this shellcode made by Hamza Megahed from http://shell-storm.org/shellcode/files/shellcode-827.php

```
	\x31\xc0\x50\x68
	\x2f\x2f\x73\x68
	\x68\x2f\x62\x69
	\x6e\x89\xe3\x50
	\x53\x89\xe1\xb0
	\x0b\xcd\x80
```

That code is what we would actually inject into the program. Now look at the assembly code for those op codes.

```
xor    %eax,%eax
push   %eax
push   $0x68732f2f
push   $0x6e69622f
mov    %esp,%ebx
push   %eax
push   %ebx
mov    %esp,%ecx
mov    $0xb,%al
int    $0x80
```

Notice the differences between that assembly code, and the assembly code we had. For starters it doesn't directly call a function, or pushed a specific memory address onto the stack. This is because that this assembly code is designed to work on any x86 program. Because of that, the program itself will not have the strings or the function calls it needs to simply push it onto the stack and call the function. Instead whenever it pushes or moves anything it is either a register or a hex string which should be a valid register on all x86 Linux programs. This way regardless of what strings or functions the program has in memory, as long as it is a Linux x86 binary the shellcode should run just fine. In addition to that, we see at the end of the shellcode there is a "int" instruction. That instruction will create a software interrupt that will essentially allow the binary to interact with the kernel to run the shellcode. 
