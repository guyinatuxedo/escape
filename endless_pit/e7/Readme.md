For this challenge you will need to actually patch the binary.

Now let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

int main()
{
	int var0 = 0;
	puts("So you stopped falling, however you will never make it back up.");
	if (var0 == 37)
	{
		puts("I forgot there was an elevator. We installed it for lazy researchers like yourself. Level Cleared!");
	}
	
	else
	{
		puts("Really you should just jump right back in the whole. It will probably be a lot more fun.");
	}

}
```

So looking at the binary, we can see that we will have to pass the if then statement in order to clear the level. However we have an issue where we have no direct or inderict input to the binary. The binary itself has all of it's values that it uses hardcoded, and it doesn't prompt for inout from the user or another program and doesn't grab any enviornment variables. So we won't be able to directly pwn this binary. However we can patch it so the check does pass. We can literally go into the compiled code, and edit it so the if then statment will always work. To do this I used an awesome tool known as Binary Ninja, however that is proprietary. There are open source alternatives that will work, however that is what I will be using.

First when we open the binary up in Binary Ninja, we can see the assembly code for the main function.

![alt text](http://i.imgur.com/q1YwUJ3.png)

As you can see, with the assembly it is checking if the variable located at rbp-0x4 is equivalent to 37 (which is decimal for the hex 0x25). We can edit that so it checks to see if it is equivalent to 0, which it is set to by default. We can edit the assembly by right clicking on the line, then hovering over "path" then selecting "Edit Current Line". When you are done editing it, you can just press enter to signal you are done making changes. After that you just need to save the binary in order for the changes to be written. Here is my assembly code after I modified it.

![alt text](http://i.imgur.com/iX3G6Cc.png)

So after patching, I essentially did the same thing that would be to recompile the binary from the C code but changing this line

```
	if (var0 == 37)
```

to this

```
	if (var0 == 0)
```

Now we could of gone about this other ways, such as setting var0 equal to 37 or writing NOPs (a NOP is an instruction that just tells the binary tomove to the next instruction) over the if then statement. Now let's see if the patched binary works.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e7 (master)$ ./e7_patched 
So you stopped falling, however you will never make it back up.
I forgot there was an elevator. We installed it for lazy researchers like yourself. Level Cleared!
```

Juat like that, we patched and pwned the binary! Now this is the reason why most pwn challenges will be hosted on a server which you don't have access to (the binary they give youwill most often have the flag blacked out). It forces you to actually exploit the program, instead of simply patching it which you can do if the binary your given has the flag. To solve this challenge, just make sure attackers don't have write access to files (host apps on secured servers, versus handing them a copy with critical information).