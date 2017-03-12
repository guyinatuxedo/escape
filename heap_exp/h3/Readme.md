This level is based off of a protstar challenge.

Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct spacecraft
{
   char destination[50];
   int coordinates;
};

struct spacecraft *voyager, *curiosity;

int main(int argc, char **argv)
{
   char input[100];
   while (1)
   {
      printf("Welcome to our spaceship simulation training program. What would you like to do?\n");
      fgets(input, sizeof(input), stdin);

      if (strncmp(input, "refuel", 6) == 0)
      {
         printf("Now refueling...\n");
         voyager = malloc(sizeof(struct spacecraft));
      }

      if (strncmp(input, "repair", 6) == 0)
      {
         printf("Now initiating repairs...\n");
         curiosity = malloc(sizeof(struct spacecraft));
      }
      
      if (strncmp(input, "analyze", 7) == 0)
      {
         printf("This planet's atmosphere is %p, and it's soil composition is %p.\n", voyager, curiosity);
      }

      if (strncmp(input, "recalibrate", 11) == 0)
      {
         fgets(voyager->destination, sizeof(voyager->destination), stdin);
      }

      if (strncmp(input, "launch", 6) == 0)
      {
         if (voyager->coordinates)
         {
            printf("We have lift off. Level Cleared\n");
         }
         else
         {
            printf("And everything goes up in flames.\n");
            exit(0);
         }
      }

      if (strncmp(input, "lessen", 6) == 0)
      {
         printf("Removing waste from the spacecraft.\n");
         free(voyager);
      }

      if (strncmp(input, "comms", 5) == 0)
      {
         printf("Establishing communications to mission control.\n");
         fgets(curiosity->destination, sizeof(curiosity->destination) + 4, stdin);
      }

      if (strncmp(input, "pressurize", 10 ) == 0)
      {
         printf("Pressurizing entry pod...\n");
         free(curiosity);
      }
      memset(input, 0, 100);

   }
}
```

So we can see here, that this program is like a menu with options. This is because the while loop will just recursively run forever,a nd continually ask for our input. We can see that the if then statments will only run if we give it inout that the first amount of characters designated by it's third argument matches the string, becuase that will be the only case strncmp returns a 0 thus having the if then statement evaluate as true. We can also see that the struct this time doesn't have a char pointer, but instead has a 50 character buffer and an int (this will be important later). So we can see that we have the following menu options, let's go through them

```
refuel
repair
analyze
recalibrate
launch
lessen
comms
pressurize
``` 

So looking at refuel and repair, they both do pretty similar tasks. Both of these options assign a space in the heap equal to the size of the spacecraft struct and returns a pointer for thos areas. The only difference is refuel does it for voyagerm and repair does it for curiosity. 

```
      if (strncmp(input, "refuel", 6) == 0)
      {
         printf("Now refueling...\n");
         voyager = malloc(sizeof(struct spacecraft));
      }

      if (strncmp(input, "repair", 6) == 0)
      {
         printf("Now initiating repairs...\n");
         curiosity = malloc(sizeof(struct spacecraft));
      }
```

Looking at analyze, this will print the pointers stored in curiosity and voyager. So we get to see where the allocated spaces of memory are stored for each instancer of the spaceship struct.

```
      if (strncmp(input, "analyze", 7) == 0)
      {
         printf("This planet's atmosphere is %p, and it's soil composition is %p.\n", voyager, curiosity);
      }
```

Looking at recalibrate, this just appears to take input in via a fgets call into the char voyager->destination. The fgets call will only allow as much space as the voyager->destination can hold, so we can't do an overflow here.

```
      if (strncmp(input, "recalibrate", 11) == 0)
      {
         fgets(voyager->destination, sizeof(voyager->destination), stdin);
      }
```

Looking at launch, we can see the pwn condition for this challenge is to set voyager->coordinates to something other than 0. If we do that and run this command, it prints out "Level Cleared" and we pwn this challenge. If we run this without setting voyager->coordinates equal to 0, the program just takes a firery exit.

```
      if (strncmp(input, "launch", 6) == 0)
      {
         if (voyager->coordinates)
         {
            printf("We have lift off. Level Cleared\n");
         }
         else
         {
            printf("And everything goes up in flames.\n");
            exit(0);
         }
      }
```

Looking at lessen this just appears to free the space taken up by voyager. This will mean that whatever space was allocated to voyager is now dealloctated. 

```
      if (strncmp(input, "lessen", 6) == 0)
      {
         printf("Removing waste from the spacecraft.\n");
         free(voyager);
      }
```

Looking at comms, this is like the recalibrate calll. It takes input in for the curiosity->destination char. However we can execute a heap overflow vulnerabillity here, because we can see the amount of data the fgets call will allow is 4 greater than the size of curiosity->destination. However since it is only 4 greater than curiosity->desitinatio, the only thing it should directly affect is the int curiosity->coordinates which won't solve this challenge for us.

```
      if (strncmp(input, "comms", 5) == 0)
      {
         printf("Establishing communications to mission control.\n");
         fgets(curiosity->destination, sizeof(curiosity->destination) + 4, stdin);
      }
```

So the final command pressurive, just appears to disallocate the space allocated to curioisty just like the lessen comman.

```
      if (strncmp(input, "pressurize", 10 ) == 0)
      {
         printf("Pressurizing entry pod...\n");
         free(curiosity);
      }
```

Just as a sidenote, we have seend that alot of these functions rely on pointers that we need to issue commands in order to generate. If we rund the commands that require a pointer without first generating them, it will cause the program to crash.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h3$ ./h3
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is (nil), and it's soil composition is (nil).
Welcome to our spaceship simulation training program. What would you like to do?
launch
Segmentation fault (core dumped)
``` 

So we know what all of the commands do. We have found a single heap overflow vulnerabillity, however that won't be enough. Looking at the lessen and pressurize commands, we see that the both free allocated memory so it can be reused, however what happens to the pointer stored at curiosity and voyager after they are freed?

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h3$ ./h3
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is (nil), and it's soil composition is (nil).
Welcome to our spaceship simulation training program. What would you like to do?
refuel
Now refueling...
Welcome to our spaceship simulation training program. What would you like to do?
repair
Now initiating repairs...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is 0x804b858.
Welcome to our spaceship simulation training program. What would you like to do?
lessen
Removing waste from the spacecraft.
Welcome to our spaceship simulation training program. What would you like to do?
pressurize
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is 0x804b858.
Welcome to our spaceship simulation training program. What would you like to do?
```

So we allocated memory to voyager and curiosity, saw that they had pointers assigned to them, then disallocated the memory they held. Howver the pointers remain. This is what is know as a stale pointer, which is a pointer that is pointuing to memory isn't allocated to it. Let's see if we can have both pointers point to the same address, since the memory freed by one should be reused by the other.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h3$ ./h3
Welcome to our spaceship simulation training program. What would you like to do?
refuel
Now refueling...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is (nil).
Welcome to our spaceship simulation training program. What would you like to do?
lessen
Removing waste from the spacecraft.
Welcome to our spaceship simulation training program. What would you like to do?
repair
Now initiating repairs...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is 0x804b818.
Welcome to our spaceship simulation training program. What would you like to do?
launch
And everything goes up in flames.
```

So we managed to get a stale pointer pointing to a place in the heap that is allocated to another spot. In addition to this we see that the launch command accepts this stale pointer. So what we can do is we can get voyager to be a stale pointer, pointing to the same meory allocated to curiosity. Then we use the heap overflow to change the value of curiosity->coordinates. Since voyager is pointing to the same space curiosity is, voyager->coordinates will be what curiosity->coordinates is. Let's try it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h3$ ./h3
Welcome to our spaceship simulation training program. What would you like to do?
refuel
Now refueling...
Welcome to our spaceship simulation training program. What would you like to do?
lessen
Removing waste from the spacecraft.
Welcome to our spaceship simulation training program. What would you like to do?
repair
Now initiating repairs...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is 0x804b818.
Welcome to our spaceship simulation training program. What would you like to do?
comms
Establishing communications to mission control.
Hello Mission Control? This is Tom speaking. We are having an issue with all of the dolphins up here.
Welcome to our spaceship simulation training program. What would you like to do?
Welcome to our spaceship simulation training program. What would you like to do?
launch
We have lift off. Level Cleared
Welcome to our spaceship simulation training program. What would you like to do?
```  

Just like that, we pwned the binary. Now to patch it.

```
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


struct spacecraft
{
   char destination[50];
   int coordinates;
};

struct spacecraft *voyager, *curiosity;

int main(int argc, char **argv)
{
   char input[100];
   while (1)
   {
      printf("Welcome to our spaceship simulation training program. What would you like to do?\n");
      fgets(input, sizeof(input), stdin);

      if (strncmp(input, "refuel", 6) == 0)
      {
         printf("Now refueling...\n");
         voyager = malloc(sizeof(struct spacecraft));
      }

      if (strncmp(input, "repair", 6) == 0)
      {
         printf("Now initiating repairs...\n");
         curiosity = malloc(sizeof(struct spacecraft));
      }
      
      if (strncmp(input, "analyze", 7) == 0)
      {
         printf("This planet's atmosphere is %p, and it's soil composition is %p.\n", voyager, curiosity);
      }

      if (strncmp(input, "recalibrate", 11) == 0)
      {
         fgets(voyager->destination, sizeof(voyager->destination), stdin);
      }

      if (strncmp(input, "launch", 6) == 0)
      {
         if (voyager->coordinates)
         {
            printf("We have lift off. Level Cleared\n");
         }
         else
         {
            printf("And everything goes up in flames.\n");
            exit(0);
         }
      }

      if (strncmp(input, "lessen", 6) == 0)
      {
         printf("Removing waste from the spacecraft.\n");
         free(voyager);
         voyager = NULL;
      }

      if (strncmp(input, "comms", 5) == 0)
      {
         printf("Establishing communications to mission control.\n");
         fgets(curiosity->destination, sizeof(curiosity->destination) + 4, stdin);
      }

      if (strncmp(input, "pressurize", 10 ) == 0)
      {
         printf("Pressurizing entry pod...\n");
         free(curiosity);
         curiosity = NULL;
      }
      memset(input, 0, 100);

   }
}
```

As you can see, immediatley after we free either pointer we set it equal to NULL. That way it no longer points to an area in the heap that doesn't belong to it. Let's verify this patch works.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h3$ ./h3_secure
Welcome to our spaceship simulation training program. What would you like to do?
refuel
Now refueling...
Welcome to our spaceship simulation training program. What would you like to do?
lessen
Removing waste from the spacecraft.
Welcome to our spaceship simulation training program. What would you like to do?
repair
Now initiating repairs...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is (nil), and it's soil composition is 0x804b818.
Welcome to our spaceship simulation training program. What would you like to do?
pressurize
Pressurizing entry pod...
Welcome to our spaceship simulation training program. What would you like to do?
refuel
Now refueling...
Welcome to our spaceship simulation training program. What would you like to do?
analyze
This planet's atmosphere is 0x804b818, and it's soil composition is (nil).
Welcome to our spaceship simulation training program. What would you like to do?
```

Just like that, we patched the binary!
