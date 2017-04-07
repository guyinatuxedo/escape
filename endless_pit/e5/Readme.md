# Please do not solve this challenge while authenticated as Root. That's just too easy.

Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main()
{
	char buf0[50];
	strncpy(buf0, getenv("USER"), 30);
	printf("You know, you really need to be more important to do things.\n");
	printf("%s\n", buf0);

	if (strncmp(buf0, "root", 4) == 0)
	{
		printf("Wow, maybe you are that important. Level Cleared!\n");
	}

	else
	{
		printf("You should really talk to someone more important.\n");
	}
}
```

So looking at this code, we can see that it compares the enviormnet variable "USER" against the string "root" and if they are the same then it clears the level. We can see what the current value of the environment vairable "USER" y simply printing it.

```
$	echo $USER
guyinatuxedo
``` 

So we see that the value of the environment variabe is the string "guyinatuxedo". So looking at the code, we assume that it should just print out the "guyinatuxedo", then the level should not clear. Let's test it out.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ ./e5
You know, you really need to be more important to do things.
guyinatuxedo
You should really talk to someone more important.
```

As you can see, that is exactly what happened. So in order to get around the check, we can just simply change that enviornment variable. That will not require root privileges.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ export USER="root"
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ echo $USER
root
```

So now that we have changed the USER enviornment variable, we should be able to run the binary (in the same session) and clear the level.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ ./e5
You know, you really need to be more important to do things.
root
Wow, maybey you are that important. Level Cleared!
```

Just like that, we pwned the binary. Now to make a patch for this.

To protect against that exact exploit, instead of checking an easily modified enviornment variable, we can instead check the user id. In Linux, each user has a user id associated with their account that can be used to identify that particular user; and root should always be the only account with a user id of 0.

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>


int main()
{
	printf("You know, you really need to be more important to do things.\n");
	printf("%d\n", getuid());

	if (getuid() == 0)
	{
		printf("Wow, maybe you are that important. Level Cleared!\n");
	}

	else
	{
		printf("You should really talk to someone more important.\n");
	}
}
```

As you can see, we now check the user id in place of the USER enviormnet variable. Let's see if this will block the same exploit.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ export USER="root"
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ echo $USER
root
guyinatuxedo@tux:/Hackery/escape/endless_pit/e5 (master)$ ./e5_secure 
You know, you really need to be more important to do things.
1000
You should really talk to someone more important.
```

Just like that, we patched the binary!
