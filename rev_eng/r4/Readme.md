Let's take a look at the assembly code...

```
Dump of assembler code for function main:
   0x0804840b <+0>:	lea    ecx,[esp+0x4]
   0x0804840f <+4>:	and    esp,0xfffffff0
   0x08048412 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:	push   ebp
   0x08048416 <+11>:	mov    ebp,esp
   0x08048418 <+13>:	push   ebx
   0x08048419 <+14>:	push   ecx
   0x0804841a <+15>:	sub    esp,0x10
   0x0804841d <+18>:	mov    ebx,ecx
   0x0804841f <+20>:	mov    DWORD PTR [ebp-0xc],0x1
   0x08048426 <+27>:	jmp    0x804844e <main+67>
   0x08048428 <+29>:	mov    eax,DWORD PTR [ebp-0xc]
   0x0804842b <+32>:	lea    edx,[eax*4+0x0]
   0x08048432 <+39>:	mov    eax,DWORD PTR [ebx+0x4]
   0x08048435 <+42>:	add    eax,edx
   0x08048437 <+44>:	mov    eax,DWORD PTR [eax]
   0x08048439 <+46>:	sub    esp,0x8
   0x0804843c <+49>:	push   eax
   0x0804843d <+50>:	push   0x80484f0
   0x08048442 <+55>:	call   0x80482e0 <printf@plt>
   0x08048447 <+60>:	add    esp,0x10
   0x0804844a <+63>:	add    DWORD PTR [ebp-0xc],0x1
   0x0804844e <+67>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048451 <+70>:	cmp    eax,DWORD PTR [ebx]
   0x08048453 <+72>:	jl     0x8048428 <main+29>
   0x08048455 <+74>:	mov    eax,0x0
   0x0804845a <+79>:	lea    esp,[ebp-0x8]
   0x0804845d <+82>:	pop    ecx
   0x0804845e <+83>:	pop    ebx
   0x0804845f <+84>:	pop    ebp
   0x08048460 <+85>:	lea    esp,[ecx-0x4]
   0x08048463 <+88>:	ret    
End of assembler dump.
```

Looking at this code, we see that it is similar to the previous challenge. It appears to to be like the previous challenge. However this time it establishes an int at ebp-0xc, abd then it appears to compare that against the eax register. If the value of the integer located at ebp-0xc is less than the value of the eax register, then it issues a printf statement and it adds one to the ebp-0xc integer. 

Now the eax register can typically server to pass data to and from a method. Because of this, we can tell that the eax register probably holds data that the user passed to the program (argc and argv). The first thing we see in the loop at main+29 is the int located at ebp-0xc is loaded into the eax register. In C arguments passed to the program are stored in the array argv[]. To call a particular item from argv[] you have to specify an item via an integer. The first item in argv[] is the program's name, however that is stored at argv[0]. Here we are starting off with 1, so we will load argv[1] which will be the first argument other than the binaries name. So it should just print out each item in argv[] untill it runs out of items.

Now for the cmp instruction against eax, it's not comparing the int stored at ebp-0xc against any value of argv[]. We can see that the process the eap register goes through before it is compared isn't nearly as long as the the process it goes throug before it is printed. It is probably comparing the amount of arguments that is passed to the binary, which is argc. So by our analysis this loop should run for as many arguments that we give the username other than the program's name, and print out each of those objects. Let's see if gdb agrees with us.

```
gdb-peda$ b *main+50
Breakpoint 1 at 0x804843d
gdb-peda$ b *main+60
Breakpoint 2 at 0x8048447
gdb-peda$ r 0000 1111 2222 3333
```

```
Breakpoint 1, 0x0804843d in main ()
gdb-peda$ x $eax
0xffffd2ba: 0x30303030
gdb-peda$ c
```

```
Breakpoint 2, 0x08048447 in main ()
gdb-peda$ x/s 0x80484f0
0x80484f0:  "You told me %s.\n"
gdb-peda$ c
```

```
Breakpoint 1, 0x0804843d in main ()
gdb-peda$ x $eax
0xffffd2bf: 0x31313131
gdb-peda$ c
```

At this point, with breakpoint two I just continued from it since there is really nothing left to see there.

```
Breakpoint 1, 0x0804843d in main ()
gdb-peda$ x $eax
0xffffd2c4: 0x32323232
gdb-peda$ c
```

```
Breakpoint 1, 0x0804843d in main ()
gdb-peda$ x $eax
0xffffd2c9: 0x33333333
gdb-peda$ c
```

And then the program exits. So we confirmed that it does indeed print out all of the additional arguments we feed to the program, and saw the loop runs once for each one of those arguments. Now to confirm our earlier analysis.

First we need to remove the breakpoints we set earlier, and set a new breakpoint.
```
gdb-peda$ info b
Num     Type           Disp Enb Address    What
1       breakpoint     keep y   0x0804843d <main+50>
   breakpoint already hit 4 times
2       breakpoint     keep y   0x08048447 <main+60>
   breakpoint already hit 4 times
gdb-peda$ delete
gdb-peda$ info b
No breakpoints or watchpoints.
gdb-peda$ b *main+70
Breakpoint 3 at 0x8048451
gdb-peda$ r 0000 1111 2222 3333
Starting program: /Hackery/escape/rev_eng/r4/r4 0000 1111 2222 3333
```

Now let's see what is in the eax, ebx, and ebp-0xc registers/register locations.

```
Breakpoint 3, 0x08048451 in main ()
gdb-peda$ find 0000
Searching for '0000' in: None ranges
Found 5 results, display max 5 items:
   libc : 0xf7f58a7c ('0' <repeats 16 times>, ' ' <repeats 16 times>)
   libc : 0xf7f58a80 ('0' <repeats 12 times>, ' ' <repeats 16 times>)
   libc : 0xf7f58a84 ("00000000", ' ' <repeats 16 times>)
   libc : 0xf7f58a88 ("0000", ' ' <repeats 16 times>)
[stack] : 0xffffd2ba ("0000")
gdb-peda$ x/d $ebx
0xffffd030: 5
gdb-peda$ x/d $eax
0x1:  Cannot access memory at address 0x1
gdb-peda$ p/d $eax
$2 = 1
gdb-peda$ 
```

Notice how we could examine the ebx register, however we had to actually print the eax register. That is because the ebx register is a pointer that currently holds the address 0xffffd030, and the examine function will assume that and look at what is at the address 0xffffd030. When we issue the print "p" command, it just prints out the value the register holds, which is currently one. Now the ebx register is a pointer to the value 5, which is the amount of arguments we passed to the program (the binary name, plus the four additional arguments). If our analysis remains true, the ebx register should remian 5 and the eax register should increment by one every time the loop runs.  

```
Breakpoint 3, 0x08048451 in main ()
gdb-peda$ x/d $ebx
0xffffd030: 5
gdb-peda$ p $eax
$2 = 0x2
```

```
Breakpoint 3, 0x08048451 in main ()
gdb-peda$ x/d $ebx
0xffffd030: 5
gdb-peda$ p $eax
$3 = 0x3
```

```
Breakpoint 3, 0x08048451 in main ()
gdb-peda$ x/d $ebx
0xffffd030: 5
gdb-peda$ p $eax
$4 = 0x4
```

```
Breakpoint 3, 0x08048451 in main ()
gdb-peda$ p $eax
$5 = 0x5
gdb-peda$ x/d $ebx
0xffffd030: 5
```

And then the program ends. So our analysis held true here. Let's run the program outside of gdb and look at our C code to confirm 100% that we are right.

```
guyinatuxedo@tux:/Hackery/escape/rev_eng/r4$ ./r4 0000 1111 2222 3333 4444 guy
You told me 0000.
You told me 1111.
You told me 2222.
You told me 3333.
You told me 4444.
You told me guy.
guyinatuxedo@tux:/Hackery/escape/rev_eng/r4$ cat r4.c
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
   int i;

   for (i = 1; i < argc; i++)
   {
      printf("You told me %s.\n", argv[i]);
   }  
}
```

And just like that, we reversed the binary.








