Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	int cost = 100;
	int priv_level = 0;
	puts("Not only did you make it back to ground level, but you found the door to our secret research equipment. Too bad you don't have the privilege level to enter it. However you can raise the privilege level if you want.");
	char input[1000];
	while (1==1)
	{
		memset(input, 0, sizeof(input));
		fgets(input, sizeof(input) - 1, stdin);
		if (atoi(input) > 0)
		{
			cost = cost + atoi(input);
		}
		printf("Current privilege level needed to access this is %d.\n", cost);
		if (cost <= priv_level)
		{
			puts("I'm pretty sure that wasn't supposed to happen. Level Cleared!");
		}
	}	
}
```

Looking at the code, we see that in order to pass the level we will need to either raise the value of the int priv_level or decrease the value of the cost int. We see that the only form of input we have to this program is passing 999 characters to the input buffer via stdin, which will be converted to an integer value and added to the cost int, however it most be greater than zero so we won't be able to simply pass it a negative value. However we can still decrease the value of the cost int by using an integer overflow exploit. First let's see what type of binary this is.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e9 (master)$ file e9
e9: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=eee9ff2ac91e85085fe02b6a524e1f04b07003b9, not stripped
```

So we can see that it is a 32 bit binary. We also see that the cost int is a signed integer. The max value for a 32 bit signed integer is 0x7fffffff (hex for the decimal 2147483647). If we were to overflow that, then the integer will read as a negative value. This is because the max value for signed ints is 0x7fffffff (2147483647), and the min value for signed 32 bit C ints is -0x80000000 (-2147483648). In C when an int at 0x7fffffff has +1 added to it, it wraps back around to the min value -0x80000000. So if we just input the max value 2147483647 to the binary, it should just add it to the 100 value already in place in the cost variable and wrap around to the min value. It should be equal to -0x80000000 + 99 = -2147483549, because we needed a +1 to reach the min value.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e9 (master)$ ./e9
Not only did you make it back to ground level, but you found the door to our secret research equipment. Too bad you don't have the privilege level to enter it. However you can raise the privilege level if you want.
2147483647
Current privilege level needed to access this is -2147483549.
I'm pretty sure that wasn't supposed to happen. Level Cleared!
^C
```

Just like that, we pwned the binary with an integer overflow attack and even accurately predcicted the exact value we would overflow it to! Now time to patch it...

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e9 (master)$ cat e9_secure.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	int cost = 100;
	int priv_level = 0;
	puts("Not only did you make it back to ground level, but you found the door to our secret research equipment. Too bad you don't have the privilege level to enter it. However you can raise the privilege level if you want.");
	char input[1000];
	while (1==1)
	{
		memset(input, 0, sizeof(input));
		fgets(input, sizeof(input) - 1, stdin);
		if (atoi(input) > 0 && atoi(input) < (0x7fffffff - cost))
		{
			cost = cost + atoi(input);
		}
		printf("Current privilege level needed to access this is %d.\n", cost);
		if (cost <= priv_level)
		{
			puts("I'm pretty sure that wasn't supposed to happen. Level Cleared!");
		}
	}	
}
```

As you can see, I added an additional check for added the value to cost where we see if the value being added will be enough to push it to the max integer value. This way we prevent it from adding a numerical value that would potentially overflow the integer. Let's test it!

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e9 (master)$ ./e9_secure 
Not only did you make it back to ground level, but you found the door to our secret research equipment. Too bad you don't have the privilege level to enter it. However you can raise the privilege level if you want.
2147483647
Current privilege level needed to access this is 100.
2147483000
Current privilege level needed to access this is 2147483100.
640
Current privilege level needed to access this is 2147483100.
600
Current privilege level needed to access this is 2147483100.
60
Current privilege level needed to access this is 2147483160.
60
Current privilege level needed to access this is 2147483220.
60
Current privilege level needed to access this is 2147483280.
50
Current privilege level needed to access this is 2147483330.
40
Current privilege level needed to access this is 2147483370.
90
Current privilege level needed to access this is 2147483460.
90
Current privilege level needed to access this is 2147483550.
90
Current privilege level needed to access this is 2147483640.
90
Current privilege level needed to access this is 2147483640.
5
Current privilege level needed to access this is 2147483645.
1
Current privilege level needed to access this is 2147483646.
.1
Current privilege level needed to access this is 2147483646.
1
Current privilege level needed to access this is 2147483646.
1
Current privilege level needed to access this is 2147483646.
11111111111
Current privilege level needed to access this is 2147483646.
^C
```

As you can see, we are no longer able to overflow the integer. Juts like that we patched the binary!