For this challenge, you need to use the binary to read the ladder file. You will probably also need to run the binary as root.

This challenge is based off of Level 10 from Nebula on exploit-excercises.

Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char** argv)
{
	if (argc != 2)
	{
		printf("You need two arguments for this.\n");
		exit(0);
	}
	setreuid(1000, 0);
	if (access(argv[1], R_OK) == 0 )
	{
		setreuid(0, 0);
		char found[200];
		FILE* target = fopen(argv[1], "r");
		while (fgets(found, sizeof(found), target))
		{
			printf("%s\n", found);
		}
	}
	else
	{
		puts("Oh that's right, you can't grab the ladder. We should experiment on how to improve that.");
	}
}
```

So looking at this binary, we see that it essentially tries to read from a file that is named what you passed it in the first argument. We see that it runs a few checks, such as making sure there are only two arguments (the binary's name and the file name), and that you can actually read the file. Let's just try to use it to read the ladder file.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$ ./e6 ladder
Oh that's right, you can't grab the ladder. We should experiment on how to improve that.
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$ sudo ./e6 ladder
Oh that's right, you can't grab the ladder. We should experiment on how to improve that.

```

So it didn't work. Upon looking at the code again, we see that the check it uses to verify that you can read the file uses the access() function. Thing is the access file verifies that your real id can open the file, not your effective id. Your real id is the id of the user that you are running as. Your effective id is a temporary id that you assume to perform a job. For instance when you run a command as sudo, your effective id becomes root. Since your effective id is root, you should be able to perform all of the functions that root can. However when your real id, which is the id of the user account you are running as, doesn't change at all. This allows you to temporarily assume a new id (usually root through the use of sudo), then after you are done with it return to your normal user. Let's check what permissions the ladder file has.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$ ls -asl ladder
4 -rwx------ 1 root guyinatuxedo 110 Apr 10 15:18 ladder
```

We also see that is sets the real id to 1000, and the effective id to 0 (which is root).

```
	setreuid(1000, 0);
```

So even if we run it as root, it will fail. So with that revelation, we shouldn't be able to use the binary to read the file. However there exists a bug in the code. The access() function uses the real id, however the fopen() call uses the effective id. So if we can bypass the access() call, the fopen() call should read it as long as our effective id is root (in addition to that it switches the ). We can do this using a Time of Check, Time of Use exploit. We will have two loops running. One that switches between creating a symbolic link between a file that our real id can open, and the file that our real id can't open. With the second loop, we will just infinitely run the binary while passing the symbolic link as the file it opens. That way after enough iterations (should only be a couple of seconds) the binary will verify that it can open the symbolic link since it will be pointing to a file that we created, however before it starts reading from the symbolic link we will change it to point to a different file. So essentially in the time that it takes the binary to go from checking the symbolic link with access() to reading from it, we will change where it points. 

First let's create the file that we own and have permissions to.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$  cd /Hackery/escape/endless_pit/e6 
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$ echo "missed" > /tmp/handle
```

Now let's start the loop where we just swap between creating the symbolic link between the file we are trying to reach, and the file we just made.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$ while true; do ln -fs /tmp/handle handle; ln -fs ladder handle; done
```

Now while that is running, in either a different terminal or ttyl session you can start the second loop

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e6 (master)$  while true; do sudo ./e6 handle; done
```

Then you should see a giant wall of text that contains a combination of the three different strings, because since we aren't specifically timing the creation of new symbolic links based upon when it is checked and read, we should end up with the three possible scenarios.

String 1:
```
Oh that's right, you can't grab the ladder. We should experiment on how to improve that.
```

String 2:
```
missed
```

String 3:
```
LEVEL CLEARED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
```

and just like that, we pwned the binary. Now to patch it...


```
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char** argv)
{
	if (argc != 2)
	{
		printf("You need two arguments for this.\n");
		exit(0);
	}
	setreuid(1000, 1000);
	if (access(argv[1], R_OK) == 0 )
	{
		char found[200];
		FILE* target = fopen(argv[1], "r");
		while (fgets(found, sizeof(found), target))
		{
			printf("%s\n", found);
		}
	}
	else
	{
		puts("Oh that's right, you can't grab the ladder. We should experiment on how to improve that.");
	}
}

```

As you can see, we stopped the privilege escallation after the access() check. This way when the binary reads from the file, it will be using the same permissions that it had when it checked if it could open it. In addition to that, we set the effective id equal to the real id so the binary can't use the effective id to open files that the real id can't. When we run the loops again using the patched binary, we see that the Time of Check, Time of Use explooit no longer works. Just like that we patched the binary!