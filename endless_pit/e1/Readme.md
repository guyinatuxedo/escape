Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

int main()
{
	char buf0[10];
	float var0;
		
	fgets(buf0, sizeof(buf0), stdin);
	var0 = atof(buf0);
	printf("%f\n", var0);

	if (var0 < 37.35928559)
	{
		printf("Too low just like you're chances of reaching the bottom.\n");
		exit(0);
	}

	if (var0 > 37.35928559)
    {
        printf("To high just like your hopes of reaching the bottom.\n");
        exit(0);
    }

	else 
	{

		printf("Oh wait, there might be a bottom to this. Level cleared\n");
	}

}
```

So looking at this code, we see that we will need to set the float var0 less than and greater than the value 37.35928559. Logically speaking this should be easy because we should be able to set var0 equal to that value. Let's try that...

```
$	./e1
37.35928559
37.359283
Too low just like you're chances of reaching the bottom.
```

We can see here that the binary prints out the value it has for var0.

```
	printf("%f\n", var0);
``` 

When we look at the output of the printf call when we just ran it, we see that even though we gave the fgets function 37.35928559, the value of var0 is only 37.359283. This is because it is a floating point value, which can only hold a certain amount of decimal places. The value we are comparing it to exceeds those decimal places. So it is impossible to set it equal to that value. However there is still a way a floating point value can be neither greater than nor less than a value it is not equal to. Floating point values can be set equal to "nan" or not a number. If a float that is equal to not a number is being compared either less than or greater than a numerical value it will fail the check. So we should just be able to set var0 equal to nan, and then it should fail both checks.

```
$	./e1
nan
nan
Oh wait, there might be a bottom to this. Level cleared
```

Just like that, we pwned the binary. Now to patch it...

```
#include <stdlib.h>
#include <stdio.h>

int main()
{
	char buf0[10];
	float var0;
		
	fgets(buf0, sizeof(buf0), stdin);
	var0 = atof(buf0);
	printf("%f\n", var0);
	
	if (var0 < 37.35928559)
	{
		printf("Too low just like you're chances of reaching the bottom.\n");
		exit(0);
	}

	if (var0 > 37.35928559)
    {
        printf("To high just like your hopes of reaching the bottom.\n");
        exit(0);
    }
	
		if (var0 != var0)
	{
		printf("Someone's getting creative\n");
		exit(0);
	}
	

	else 
	{

		printf("Oh wait, there might be a bottom to this. Level cleared\n");
	}

}
```

As you can see, all I did was I added a check to see if var0 is equal to itself. It should only fail this check if it is equal to nan. That way if somebody does set var0 equal to nan, the program should just quit anyways. Let's test it...


```
$	./e1_secure 
nan
nan
Someone's getting creative
$	./e1_secure 
37.35928559
37.359283
Too low just like you're chances of reaching the bottom.
```

Just like that, we patched the binary!