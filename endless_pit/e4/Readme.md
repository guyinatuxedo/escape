The 32 and 64 bit versions of this challenge are the same.

This challenge is a bit different. We are supposed to have the program read the contents of the exit file. With that let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char handle[500];
	scanf("%10s", &handle);

	if ((strcmp(handle, "exit")) == 0)
	{
		puts("Not so fast, you have a looong way down.");
		exit(0);
	}

	FILE *hope;
	hope = fopen(handle, "r");

	if (hope == NULL)
	{
		perror("error");
		puts("You really don't have any, do you?");
		exit(0);
	}

	else
	{
		fgets(handle, sizeof(handle), hope);
		printf("%s\n", handle);
	}
}
```

So we can see that this is a basic program that will scan in input, then try to open a file in the same directory. if it succeeds then it will print the first 500 characters of it, and if it can't open the file it prints out the error and exits. We also see that there is a check if we directly input the file name, the bimary will just exit. However since the only checks are if the file is a specific name, and if it can open that file, we will be able to get aroung those checks using symbolic links.

Symbolic links are basically files that act as pointers to other files. However they can be treated as the actual file itself. Let's create on for the exit file.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ ln -s exit HA
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ cat HA
Funny, the exit is right there. However you can't reach it. Because you are plummeting to the bottom of the endless pit. Level Cleared!
```

As you can see, we were able to make a symbolic link to the exit file and treat it like the actual file. Let's see if the binary will read the exit file if we use the symbolic link.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ ./e4 
HA
Funny, the exit is right there. However you can't reach it. Because you are plummeting to the bottom of the endless pit. Level Cleared!

```

Just like that, we pwned the binary using a symbolic link attack. Let's patch it...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{

	char handle[500];
	scanf("%10s", &handle);

	if ((strcmp(handle, "exit")) == 0)
	{
		puts("Not so fast, you have a looong way down.");
		exit(0);
	}

	FILE *hope;
	hope = fopen(handle, "r");
	
	if (hope == NULL)
	{
		perror("error");
		puts("You really don't have any, do you?");
		exit(0);
	}

	struct stat check;
	int success = lstat(handle, &check);
	if (S_ISREG(check.st_mode))
	{
		fgets(handle, sizeof(handle), hope);
		printf("%s\n", handle);
	}

	if (S_ISLNK(check.st_mode))
	{
		puts("No symbolic link attacks.");
		exit(0);
	}	
}
```

As you can see, we added an additional check. This additional check will use the state utillity to check if the file pointed to by handle is a normal file or symbolic link, and store that information in a struct stat (which is just a struct desgined to store information about files). So if this works, if we try to have the binary open up a file that isn't a symbolic link, it should just exit.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ echo "Test" > test
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ ./e4_secure 
test
Test
guyinatuxedo@tux:/Hackery/escape/endless_pit/e4 (master)$ ./e4_secure 
HA
No symbolic link attacks.
```

Just like that, we patched the symbolic link attack!
