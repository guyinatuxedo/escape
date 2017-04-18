This is a reversing challenge. You are meant to figure out how it works without looking at the C code. I would recommend using IDA, gdb. binary ninja, or objectdump to reverse it however you can do it however you wish. 

I will be using gdb-peda to reverse this in the writeup.

First let's take a look at the assembly code for the main function.

```
gdb-peda$ disas main
Dump of assembler code for function main:
   0x0000000000400aee <+0>:	push   rbp
   0x0000000000400aef <+1>:	mov    rbp,rsp
   0x0000000000400af2 <+4>:	sub    rsp,0x30
   0x0000000000400af6 <+8>:	mov    DWORD PTR [rbp-0x24],edi
   0x0000000000400af9 <+11>:	mov    QWORD PTR [rbp-0x30],rsi
   0x0000000000400afd <+15>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400b06 <+24>:	mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400b0a <+28>:	xor    eax,eax
   0x0000000000400b0c <+30>:	cmp    DWORD PTR [rbp-0x24],0x3
   0x0000000000400b10 <+34>:	je     0x400b26 <main+56>
   0x0000000000400b12 <+36>:	mov    edi,0x400d50
   0x0000000000400b17 <+41>:	call   0x400670 <puts@plt>
   0x0000000000400b1c <+46>:	mov    edi,0x0
   0x0000000000400b21 <+51>:	call   0x400700 <exit@plt>
   0x0000000000400b26 <+56>:	mov    rdx,QWORD PTR [rip+0x201553]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400b2d <+63>:	lea    rax,[rbp-0x20]
   0x0000000000400b31 <+67>:	mov    esi,0xa
   0x0000000000400b36 <+72>:	mov    rdi,rax
   0x0000000000400b39 <+75>:	call   0x4006c0 <fgets@plt>
   0x0000000000400b3e <+80>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400b42 <+84>:	add    rax,0x8
   0x0000000000400b46 <+88>:	mov    rax,QWORD PTR [rax]
   0x0000000000400b49 <+91>:	mov    rdi,rax
   0x0000000000400b4c <+94>:	call   0x400680 <strlen@plt>
   0x0000000000400b51 <+99>:	mov    rdx,rax
   0x0000000000400b54 <+102>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400b58 <+106>:	add    rax,0x8
   0x0000000000400b5c <+110>:	mov    rax,QWORD PTR [rax]
   0x0000000000400b5f <+113>:	lea    rcx,[rbp-0x20]
   0x0000000000400b63 <+117>:	mov    rsi,rcx
   0x0000000000400b66 <+120>:	mov    rdi,rax
   0x0000000000400b69 <+123>:	call   0x400660 <strncmp@plt>
   0x0000000000400b6e <+128>:	test   eax,eax
   0x0000000000400b70 <+130>:	je     0x400b7c <main+142>
   0x0000000000400b72 <+132>:	mov    edi,0x0
   0x0000000000400b77 <+137>:	call   0x400700 <exit@plt>
   0x0000000000400b7c <+142>:	lea    rax,[rbp-0x20]
   0x0000000000400b80 <+146>:	mov    edx,0xa
   0x0000000000400b85 <+151>:	mov    esi,0x0
   0x0000000000400b8a <+156>:	mov    rdi,rax
   0x0000000000400b8d <+159>:	call   0x4006a0 <memset@plt>
   0x0000000000400b92 <+164>:	mov    rdx,QWORD PTR [rip+0x2014e7]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400b99 <+171>:	lea    rax,[rbp-0x20]
   0x0000000000400b9d <+175>:	mov    esi,0xa
   0x0000000000400ba2 <+180>:	mov    rdi,rax
   0x0000000000400ba5 <+183>:	call   0x4006c0 <fgets@plt>
   0x0000000000400baa <+188>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400bae <+192>:	add    rax,0x10
   0x0000000000400bb2 <+196>:	mov    rax,QWORD PTR [rax]
   0x0000000000400bb5 <+199>:	mov    rdi,rax
   0x0000000000400bb8 <+202>:	call   0x400680 <strlen@plt>
   0x0000000000400bbd <+207>:	mov    rdx,rax
   0x0000000000400bc0 <+210>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400bc4 <+214>:	add    rax,0x10
   0x0000000000400bc8 <+218>:	mov    rax,QWORD PTR [rax]
   0x0000000000400bcb <+221>:	lea    rcx,[rbp-0x20]
   0x0000000000400bcf <+225>:	mov    rsi,rcx
   0x0000000000400bd2 <+228>:	mov    rdi,rax
   0x0000000000400bd5 <+231>:	call   0x400660 <strncmp@plt>
   0x0000000000400bda <+236>:	test   eax,eax
   0x0000000000400bdc <+238>:	je     0x400be8 <main+250>
   0x0000000000400bde <+240>:	mov    edi,0x0
   0x0000000000400be3 <+245>:	call   0x400700 <exit@plt>
   0x0000000000400be8 <+250>:	mov    edi,0x400d78
   0x0000000000400bed <+255>:	call   0x400670 <puts@plt>
   0x0000000000400bf2 <+260>:	mov    eax,0x0
   0x0000000000400bf7 <+265>:	call   0x400816 <elev0>
   0x0000000000400bfc <+270>:	mov    eax,0x0
   0x0000000000400c01 <+275>:	call   0x400930 <elev1>
   0x0000000000400c06 <+280>:	mov    eax,0x0
   0x0000000000400c0b <+285>:	call   0x400a40 <elev2>
   0x0000000000400c10 <+290>:	mov    edi,0x400dd0
   0x0000000000400c15 <+295>:	call   0x400670 <puts@plt>
   0x0000000000400c1a <+300>:	mov    eax,0x0
   0x0000000000400c1f <+305>:	mov    rcx,QWORD PTR [rbp-0x8]
   0x0000000000400c23 <+309>:	xor    rcx,QWORD PTR fs:0x28
   0x0000000000400c2c <+318>:	je     0x400c33 <main+325>
   0x0000000000400c2e <+320>:	call   0x400690 <__stack_chk_fail@plt>
   0x0000000000400c33 <+325>:	leave  
   0x0000000000400c34 <+326>:	ret    
End of assembler dump.
```

I'm going to reverse this in chunks. The first chunk consists of the first cmp statement.

```
   0x0000000000400af6 <+8>:	mov    DWORD PTR [rbp-0x24],edi
   0x0000000000400af9 <+11>:	mov    QWORD PTR [rbp-0x30],rsi
   0x0000000000400afd <+15>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400b06 <+24>:	mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400b0a <+28>:	xor    eax,eax
   0x0000000000400b0c <+30>:	cmp    DWORD PTR [rbp-0x24],0x3
   0x0000000000400b10 <+34>:	je     0x400b26 <main+56>
   0x0000000000400b12 <+36>:	mov    edi,0x400d50
   0x0000000000400b17 <+41>:	call   0x400670 <puts@plt>
   0x0000000000400b1c <+46>:	mov    edi,0x0
   0x0000000000400b21 <+51>:	call   0x400700 <exit@plt>
```

As we can see here, there is a compare instruction issued against rbp-0x24 against three. If it is equal to three it jumps forward in the assembly code. If it isn't equivalent to three, then it prints something using puts and exits. Now looking at the value of rbp-0x24 we see that it has the edi register's contents loaded into it. This is sometimes seen with function paramters being passed to a function like argc. We can also see that the rsi function is being moved into rbp-0x30 which is probably the argv array. Also if we try running the program, it flat out tells us that the program needs three arguments. So this assembly code appears to load argc and argv, then checks to ensure that argc is equal to three meaning that the program has three arguments. So the C code looks like this.

```
if (argc != 3)
{
	puts("This function needs three arguments.");
	exit(0);
}
```

```
   0x0000000000400b26 <+56>:	mov    rdx,QWORD PTR [rip+0x201553]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400b2d <+63>:	lea    rax,[rbp-0x20]
   0x0000000000400b31 <+67>:	mov    esi,0xa
   0x0000000000400b36 <+72>:	mov    rdi,rax
   0x0000000000400b39 <+75>:	call   0x4006c0 <fgets@plt>
```

This assembly code appears to use the fgets call to load 10 characters into the buffer located at rbp-0x20. The C code should look something like this (this size of the buffer at this point is a guess).

```
	char buf0[10];
	fgets(buf0, 10, stdin)
```

```
   0x0000000000400b3e <+80>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400b42 <+84>:	add    rax,0x8
   0x0000000000400b46 <+88>:	mov    rax,QWORD PTR [rax]
   0x0000000000400b49 <+91>:	mov    rdi,rax
   0x0000000000400b4c <+94>:	call   0x400680 <strlen@plt>
   0x0000000000400b51 <+99>:	mov    rdx,rax
   0x0000000000400b54 <+102>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400b58 <+106>:	add    rax,0x8
   0x0000000000400b5c <+110>:	mov    rax,QWORD PTR [rax]
   0x0000000000400b5f <+113>:	lea    rcx,[rbp-0x20]
   0x0000000000400b63 <+117>:	mov    rsi,rcx
   0x0000000000400b66 <+120>:	mov    rdi,rax
   0x0000000000400b69 <+123>:	call   0x400660 <strncmp@plt>
   0x0000000000400b6e <+128>:	test   eax,eax
   0x0000000000400b70 <+130>:	je     0x400b7c <main+142>
   0x0000000000400b72 <+132>:	mov    edi,0x0
   0x0000000000400b77 <+137>:	call   0x400700 <exit@plt>
```

First off we see strncmp being called, then the output of it being tested. If the output of strncmp does not output a 0, then the program exits using the exit function. We have to figure out what paramters strncmp are, which it reauires three. The first string or char to compare, the second string or char to compare, and the amount of characters starting at the beginning of the strings to compare. If they are poth equal, then the strncmp call will output a 0. Looking right above the strncmp call we see that the space pointed to by rbp-0x20 (the same buffer we wrote to in the previous segment) is loaded into the rcx register via the lea command, so it is probably one of the two strings being compared by the strncmp function. When we look before that, we see that the value pointed to by rbp-0x30 is moved into the rax register. We know that from the first sequence that rbp-0x30 is used to store the parameter argv, and from the fact that rax has 0x8 added to it and later on in the code we see that with the similar thing happens it has 0x10 added to it we can guess that it is argv[1]. If we go above that we see that strlen is called on the supposed argv[1] (we see that it moves rbp-0x30 and then adds 0x8 just like before). Strlen returns in integer based upon the length of the string, so the amount of characters that it is comparing is probably equal to the length of the second paramter passed to the program (frist one after the program's name). Keep in mind that functions are pushed onto the stack in reverse order, which currently it pushed the number of characters to be compared, then the two strings which matches up with how the strncmp function takes arguments. So with all of this in place, the C code probably looks like this.

```
if (strncmp(argv[1], buf0, strlen(argv[1])) != 0)
{
	exit(0);	
}
```

```
   0x0000000000400b7c <+142>:	lea    rax,[rbp-0x20]
   0x0000000000400b80 <+146>:	mov    edx,0xa
   0x0000000000400b85 <+151>:	mov    esi,0x0
   0x0000000000400b8a <+156>:	mov    rdi,rax
   0x0000000000400b8d <+159>:	call   0x4006a0 <memset@plt>
```
This appears to load the address pointed to by rbp-0x20 (same as buf0 used in the previous two blocks) onto the stack, along with moving the hex values 0xa and 0x0 onto the stack. After that it calls memset. Memset takes three paramters, a char to be writeen over, a number to write over it, and how many characters to write that number.From the looks of it, the buf0 buffer we've been using is having 10 zeros written over it (if it was the other way around, it would have 0 tens written to it, which wouldn't do anything). So the C code looks like this.

```
memset(buf0, 0, 10);
```

```
   0x0000000000400b92 <+164>:	mov    rdx,QWORD PTR [rip+0x2014e7]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400b99 <+171>:	lea    rax,[rbp-0x20]
   0x0000000000400b9d <+175>:	mov    esi,0xa
   0x0000000000400ba2 <+180>:	mov    rdi,rax
   0x0000000000400ba5 <+183>:	call   0x4006c0 <fgets@plt>
```

This assembly code identical to the second segment appears to use the fgets call to load 10 characters into the buffer located at rbp-0x20. The C code should look something like this (this size of the buffer at this point is still a guess).

```
	char buf0[10];
	fgets(buf0, 10, stdin)
```

```
   0x0000000000400baa <+188>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400bae <+192>:	add    rax,0x10
   0x0000000000400bb2 <+196>:	mov    rax,QWORD PTR [rax]
   0x0000000000400bb5 <+199>:	mov    rdi,rax
   0x0000000000400bb8 <+202>:	call   0x400680 <strlen@plt>
   0x0000000000400bbd <+207>:	mov    rdx,rax
   0x0000000000400bc0 <+210>:	mov    rax,QWORD PTR [rbp-0x30]
   0x0000000000400bc4 <+214>:	add    rax,0x10
   0x0000000000400bc8 <+218>:	mov    rax,QWORD PTR [rax]
   0x0000000000400bcb <+221>:	lea    rcx,[rbp-0x20]
   0x0000000000400bcf <+225>:	mov    rsi,rcx
   0x0000000000400bd2 <+228>:	mov    rdi,rax
   0x0000000000400bd5 <+231>:	call   0x400660 <strncmp@plt>
   0x0000000000400bda <+236>:	test   eax,eax
   0x0000000000400bdc <+238>:	je     0x400be8 <main+250>
   0x0000000000400bde <+240>:	mov    edi,0x0
   0x0000000000400be3 <+245>:	call   0x400700 <exit@plt>
```

So like the last segment, this segment is identicial to a previous segment. Specifically this is identical to segment three. It uses strncmp to check to strings, one which is buf0 and one that is an element of the argv[] array, and checks only the characters that is equal to the length of the argv[] element array. If they are not equal then the program runs the exit function to shut itself down. However unlike segment three it adds 0x10 to rbp-0x30 instead of 0x8, so it is probably argv[2]. So the C code probably looks like this.

```
if (strncmp(argv[2], buf0, strlen(argv[2])) != 0)
{
    exit(0);
}
```

```
  0x0000000000400be8 <+250>:	mov    edi,0x400d78
   0x0000000000400bed <+255>:	call   0x400670 <puts@plt>
   0x0000000000400bf2 <+260>:	mov    eax,0x0
   0x0000000000400bf7 <+265>:	call   0x400816 <elev0>
   0x0000000000400bfc <+270>:	mov    eax,0x0
   0x0000000000400c01 <+275>:	call   0x400930 <elev1>
   0x0000000000400c06 <+280>:	mov    eax,0x0
   0x0000000000400c0b <+285>:	call   0x400a40 <elev2>
   0x0000000000400c10 <+290>:	mov    edi,0x400dd0
   0x0000000000400c15 <+295>:	call   0x400670 <puts@plt>
```

This appears to be the end of the assembly code that we are conncerned with. As you can see, if first prints something with puts, then runs three custom functions called elev0, elev1, and elev2. After that it prints something out with puts (probably the end). So although we have resversed the main function, we will probably need to reverse each of the three custom functions before we can reach the end. So we've figured out that the C code for the main function looks like this.

```
int main(int argc, char** argv)
{
	if (argc != 3)
	{
		puts("This function needs three arguments.");
		exit(0);
	}
	char buf0[10];
	fgets(buf0, 10, stdin);
	if (strncmp(argv[1], buf0, strlen(argv[1])) != 0)
	{
		exit(0);
	}
	
	memset(buf0, 0, 10);
	fgets(buf0, 10, stdin);
	if (strncmp(argv[2], buf0, strlen(argv[2])) != 0)
	{
		exit(0);
	}
	puts();
	elev0();
	elev1();
	elev2();
	puts();
}
```

Let's see if it is true.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e8 (master)$ ./e8 rev eng
rev
eng
You might have access to the elevexators, but can you figure out how to use them?
idk?
```

So it would appear as though we've figured out the main function, however there is more to go. Now we get to reverse elev0.

```
gdb-peda$ disas elev0
Dump of assembler code for function elev0:
   0x0000000000400816 <+0>:	push   rbp
   0x0000000000400817 <+1>:	mov    rbp,rsp
   0x000000000040081a <+4>:	sub    rsp,0x30
   0x000000000040081e <+8>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400827 <+17>:	mov    QWORD PTR [rbp-0x8],rax
   0x000000000040082b <+21>:	xor    eax,eax
   0x000000000040082d <+23>:	mov    DWORD PTR [rbp-0x30],0x5
   0x0000000000400834 <+30>:	mov    eax,DWORD PTR [rbp-0x30]
   0x0000000000400837 <+33>:	add    eax,0xd
   0x000000000040083a <+36>:	mov    DWORD PTR [rbp-0x2c],eax
   0x000000000040083d <+39>:	mov    edx,DWORD PTR [rbp-0x2c]
   0x0000000000400840 <+42>:	mov    eax,edx
   0x0000000000400842 <+44>:	add    eax,eax
   0x0000000000400844 <+46>:	add    eax,edx
   0x0000000000400846 <+48>:	mov    DWORD PTR [rbp-0x30],eax
   0x0000000000400849 <+51>:	mov    eax,DWORD PTR [rbp-0x30]
   0x000000000040084c <+54>:	cdq    
   0x000000000040084d <+55>:	idiv   DWORD PTR [rbp-0x2c]
   0x0000000000400850 <+58>:	mov    DWORD PTR [rbp-0x28],eax
   0x0000000000400853 <+61>:	mov    edx,DWORD PTR [rbp-0x30]
   0x0000000000400856 <+64>:	mov    eax,DWORD PTR [rbp-0x2c]
   0x0000000000400859 <+67>:	add    eax,edx
   0x000000000040085b <+69>:	add    DWORD PTR [rbp-0x28],eax
   0x000000000040085e <+72>:	mov    rdx,QWORD PTR [rip+0x20181b]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400865 <+79>:	lea    rax,[rbp-0x20]
   0x0000000000400869 <+83>:	mov    esi,0x13
   0x000000000040086e <+88>:	mov    rdi,rax
   0x0000000000400871 <+91>:	call   0x4006c0 <fgets@plt>
   0x0000000000400876 <+96>:	lea    rax,[rbp-0x20]
   0x000000000040087a <+100>:	mov    rdi,rax
   0x000000000040087d <+103>:	call   0x4006e0 <atoi@plt>
   0x0000000000400882 <+108>:	cmp    eax,DWORD PTR [rbp-0x28]
   0x0000000000400885 <+111>:	jne    0x40091f <elev0+265>
   0x000000000040088b <+117>:	mov    eax,DWORD PTR [rbp-0x28]
   0x000000000040088e <+120>:	mov    DWORD PTR [rbp-0x24],eax
   0x0000000000400891 <+123>:	mov    eax,DWORD PTR [rbp-0x2c]
   0x0000000000400894 <+126>:	and    eax,DWORD PTR [rbp-0x30]
   0x0000000000400897 <+129>:	mov    DWORD PTR [rbp-0x28],eax
   0x000000000040089a <+132>:	mov    eax,DWORD PTR [rbp-0x28]
   0x000000000040089d <+135>:	xor    eax,DWORD PTR [rbp-0x2c]
   0x00000000004008a0 <+138>:	mov    DWORD PTR [rbp-0x30],eax
   0x00000000004008a3 <+141>:	mov    eax,DWORD PTR [rbp-0x2c]
   0x00000000004008a6 <+144>:	or     DWORD PTR [rbp-0x24],eax
   0x00000000004008a9 <+147>:	mov    edx,DWORD PTR [rbp-0x2c]
   0x00000000004008ac <+150>:	mov    eax,DWORD PTR [rbp-0x28]
   0x00000000004008af <+153>:	add    eax,edx
   0x00000000004008b1 <+155>:	mov    DWORD PTR [rbp-0x24],eax
   0x00000000004008b4 <+158>:	mov    eax,DWORD PTR [rbp-0x30]
   0x00000000004008b7 <+161>:	add    DWORD PTR [rbp-0x24],eax
   0x00000000004008ba <+164>:	lea    rax,[rbp-0x20]
   0x00000000004008be <+168>:	mov    edx,0x14
   0x00000000004008c3 <+173>:	mov    esi,0x0
   0x00000000004008c8 <+178>:	mov    rdi,rax
   0x00000000004008cb <+181>:	call   0x4006a0 <memset@plt>
   0x00000000004008d0 <+186>:	mov    rdx,QWORD PTR [rip+0x2017a9]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x00000000004008d7 <+193>:	lea    rax,[rbp-0x20]
   0x00000000004008db <+197>:	mov    esi,0x13
   0x00000000004008e0 <+202>:	mov    rdi,rax
   0x00000000004008e3 <+205>:	call   0x4006c0 <fgets@plt>   
   0x00000000004008e8 <+210>:	lea    rax,[rbp-0x20]
   0x00000000004008ec <+214>:	mov    rdi,rax
   0x00000000004008ef <+217>:	call   0x4006e0 <atoi@plt>
   0x00000000004008f4 <+222>:	cmp    eax,DWORD PTR [rbp-0x24]
   0x00000000004008f7 <+225>:	jne    0x400915 <elev0+255>   
   0x00000000004008f9 <+227>:	mov    edi,0x400cc8
   0x00000000004008fe <+232>:	call   0x400670 <puts@plt>   
   0x0000000000400903 <+237>:	nop
   0x0000000000400904 <+238>:	mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400908 <+242>:	xor    rax,QWORD PTR fs:0x28
   0x0000000000400911 <+251>:	je     0x40092e <elev0+280>
   0x0000000000400913 <+253>:	jmp    0x400929 <elev0+275>
   0x0000000000400915 <+255>:	mov    edi,0x0
   0x000000000040091a <+260>:	call   0x400700 <exit@plt>
   0x000000000040091f <+265>:	mov    edi,0x0
   0x0000000000400924 <+270>:	call   0x400700 <exit@plt>
   0x0000000000400929 <+275>:	call   0x400690 <__stack_chk_fail@plt>
   0x000000000040092e <+280>:	leave  
   0x000000000040092f <+281>:	ret    
End of assembler dump.
```

```
   0x000000000040082d <+23>:  mov    DWORD PTR [rbp-0x30],0x5
   0x0000000000400834 <+30>:  mov    eax,DWORD PTR [rbp-0x30]
   0x0000000000400837 <+33>:  add    eax,0xd
   0x000000000040083a <+36>:  mov    DWORD PTR [rbp-0x2c],eax
```

With this assembly code, we see the value 0x5 being moved into rbp-0x30. Then the value pointed to by rpb-0x30 is loaded into the eax register. Proceeding that the eax register has 0xc (hex for 13) added to it. Then the sum of that is loaded into rbp-0x2c. Looking at this since we see neither rbp-0x30 or rbp-0x2c before this segment in the asembly code, they are probably variables beign declared. In addition to that since we are loading hex strings into those variables, and performing mathematical operations on it, they are probably integers. So what is probably going on here is an int was declared at rbp-0x30 that is set equal to 5. Then after that a second int is declared at rbp-0x2c that is set equal to the int at rbp-0x30 plus 13.

```
int int0 = 5;
int int1 = int0 + 13;
```

```
   0x000000000040083d <+39>:  mov    edx,DWORD PTR [rbp-0x2c]
   0x0000000000400840 <+42>:  mov    eax,edx
   0x0000000000400842 <+44>:  add    eax,eax
   0x0000000000400844 <+46>:  add    eax,edx
   0x0000000000400846 <+48>:  mov    DWORD PTR [rbp-0x30],eax
```
 
Looking at here, we see that it first loads the value located at rbp-0x2c (int1) into the edx register. Then it moves the contents of the edx register into the eax register. Then it proceeds to add the contents of the eax register to the edx register twice. It then finishes by moving the contents of the eax register into rbp-0x30 (int0). So it effictively sets int0 equal to int1 added three times, or simply multiplied by three. 

```
int0 = int1 * 3;
```

```
   0x0000000000400849 <+51>:  mov    eax,DWORD PTR [rbp-0x30]
   0x000000000040084c <+54>:  cdq    
   0x000000000040084d <+55>:  idiv   DWORD PTR [rbp-0x2c]
   0x0000000000400850 <+58>:  mov    DWORD PTR [rbp-0x28],eax
```

We can see here in this segment, it moves the value of rbp-0x30 (int0) into the eax register then calls the cdq instruction which sign extends the contents of eax into the edx:eax. Thus is needed because of the next instruction, idiv. Idiv divided edx by eax. Because rbp-0x30 (int0) was extended into edx via the cdq instruction, and then rbp-0x2c (int1 from segment 1) is the argument for the idiv instruction it will divide rbp-0x30 by rbp-0x2c. Then it will sotre the quotient of that in the eax register. As we can see, right after the idiv instruction is a mov instruction to move the contents of the eax register into rbp-0x28 which is a new possible integer for us. So what is going on here is it is establishing a new integer equal to int0 / int1.

```
int int2 = int0 / int1;
```

```
   0x0000000000400853 <+61>:  mov    edx,DWORD PTR [rbp-0x30]
   0x0000000000400856 <+64>:  mov    eax,DWORD PTR [rbp-0x2c]
   0x0000000000400859 <+67>:  add    eax,edx
   0x000000000040085b <+69>:  add    DWORD PTR [rbp-0x28],eax
```

Looking at this code, it seems similar to that of segment 1. We can see that it moves the contents of rbp-0x30 (int0) and rbp-0x2c (int1) into the edx and eax registers. Then it proceeds to add the contents of the edx and eax registers, and stores it in the eax register. Then it adds that sum to the value pointed to by rbp-0x28 (int2 from the previous segment). This segment just sets int2 equal to the sum of int0, int1, and int2.

```
int2 = int0 + int1 + int2;
```

```
   0x000000000040085e <+72>:  mov    rdx,QWORD PTR [rip+0x20181b]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400865 <+79>:  lea    rax,[rbp-0x20]
   0x0000000000400869 <+83>:  mov    esi,0x13
   0x000000000040086e <+88>:  mov    rdi,rax
   0x0000000000400871 <+91>:  call   0x4006c0 <fgets@plt>
   0x0000000000400876 <+96>:  lea    rax,[rbp-0x20]
   0x000000000040087a <+100>: mov    rdi,rax
   0x000000000040087d <+103>: call   0x4006e0 <atoi@plt>
   0x0000000000400882 <+108>: cmp    eax,DWORD PTR [rbp-0x28]
   0x0000000000400885 <+111>: jne    0x40091f <elev0+265>
```

Loking at this code, we see two functions being called fgets and atoi. The fgets function is writing 19 characters to a char space located at rbp-0x20. This is the first time we see the char array at rbp-0x20 in this function and we sidn't see any function parameters being passed to this function so it is probably being established (it is probably 19 characters long since that is how many characters are being scanned into it). After that it loads that address using the lea instruction, then runs the atoi function on it. Proceeding that it compares the output of the atoi function against the value pointed to by rbp-0x28 (int2). If If it is not equal then it will jump to elev0+265. So in order to proceed we will need to use the fgets call to set rbp-0x20 equal to something that when converted to an integer equals rbp-0x28 (int2).

```
char buf0[19];
fgets(buf0, sizeof(buf0), stdin);
if (int2 == atoi(buf0))
{
   //rest of the function
}
```

```
   0x0000000000400911 <+251>: je     0x40092e <elev0+280>
   0x0000000000400913 <+253>: jmp    0x400929 <elev0+275>
   0x0000000000400915 <+255>:  mov    edi,0x0
   0x000000000040091a <+260>: call   0x400700 <exit@plt>
```

This segment contains what would happen if the check in the previous segment fails. As we can see at the start if the segment are two instructions that will jump past this segment to the end of the function. So the instructions at elev0+255 and elev0+260 should only execute if the code jumps to those specific instructions. When we look at those two instructions we see that it moves the decimal 0 into the edi register, then calls the exit function with the contents of the edi register as a paramter. That exit call will kill the program. Judgin from the first two instructions in the segment, and how the previous segment will jump to this segment only if the cmp check fails this is probably in else clause for the previous segment.

```
else
{
   exit(0);
}
```

So putting all of the reversed C code together we get this

```
int int0 = 5;
int int1 = int0 + 13;
int0 = int1 * 3;
int int2 = int0 / int1;
int2 = int0 + int1 + int2;
char buf0[19];
fgets(buf0, sizeof(buf0), stdin);
if (int2 == atoi(buf0))
{
   //rest of the function
}
else
{
   exit(0);
}
```

So now that we understand the logic that the program uses, we can find out what the value of int2 is. After we follow the logic, we determine that the end value of int2 is 75, so if we input 75 we should pass this check. Now onto the second part of elev2.

```
   0x000000000040088b <+117>: mov    eax,DWORD PTR [rbp-0x28]
   0x000000000040088e <+120>: mov    DWORD PTR [rbp-0x24],eax
   0x0000000000400891 <+123>: mov    eax,DWORD PTR [rbp-0x2c]
   0x0000000000400894 <+126>: and    eax,DWORD PTR [rbp-0x30]
   0x0000000000400897 <+129>: mov    DWORD PTR [rbp-0x28],eax
```

So this segment starts off with transferring the data pointed to by rbp-0x28 (int2) into rbp-0x24. This is the first time we see rbp-0x24 so it is a new int being declared. Next we see the assembly move the contents of rbp-0x2c (int1) into eax, then ands it against it agains rbp-0x30. Anding is a binary operator that will work with the binary equivalent of the integers, it compares the positions of the binary strings and outputs a 1 if both of them are qual to 1 and a 0 if they aren't. It stores the output in the eax register, which it then proceeds to move into rbp-0x28 (int2). So essentially it creates a new int at rbp-0x24 (int3) equal to the value pointed to by rbp-0x28 (int2), then it ands the values pointed to by rbp-0x2c (int1) and rbp-0x30 (int0) and stores it in rbp-0x28 (int2). 

```
int int3 = int2;
int2 = int1 & int0;
```

```
   0x000000000040089a <+132>: mov    eax,DWORD PTR [rbp-0x28]
   0x000000000040089d <+135>: xor    eax,DWORD PTR [rbp-0x2c]
   0x00000000004008a0 <+138>: mov    DWORD PTR [rbp-0x30],eax
```

This segment moves the value pointed to by rbp-0x28 (int2) into eax, then xors that against rbp-0x2c (int1) and stores it in the eax register. The xor function is another binary operator like and, however this only outputs a 1 if it is given a 1 and a 0, and a 0 for everything else. Then it moves the output of the xor function stored in the eax register into rbp-0x30 (int0). So essentially this segment just sets the value pointed to by rbp-0x30 (int0) equal to the output of xoring the values pointed to by rbp-0x28 (int2) and rbp-0x2c (int1).

```
int0 = int2 ^ int1;
```

```
   0x00000000004008a3 <+141>: mov    eax,DWORD PTR [rbp-0x2c]
   0x00000000004008a6 <+144>: or     DWORD PTR [rbp-0x24],eax
```

Continuing with our them of binary operators, this segment moves the value pointed to by rbp-0x2c (int1) into the eax register. Then it uses the binary operator or on the contents of the eax register and the value pointed to by rbp-0x24 (int3) and stores it in rbp-0x24 (int3). So essentially this just sets the value pointed to by rbp-0x24 equal to the values pointed to by rbp-0x2c and rbp-0x24 when ored together.

```
int3 = int1 | int3;
```

```
   0x00000000004008a9 <+147>: mov    edx,DWORD PTR [rbp-0x2c]
   0x00000000004008ac <+150>: mov    eax,DWORD PTR [rbp-0x28]
   0x00000000004008af <+153>: add    eax,edx
   0x00000000004008b1 <+155>: mov    DWORD PTR [rbp-0x24],eax
```

This segment simply loads the values pointed to by rbp-0x2c (int1) and rbp-0x28 (int2) into the edx and eax register. It then proceeds to add those registers together and stores the input in the eax register. It then moves the contents of the eax register into rbp-0x24 (int3). So essentially this just sets the value pointed to by rbp-0x24 (int3) equal to the values pointed to by rbp-0x2c (int1) and rbp-0x28 (int2) added together.

```
int3 = int1 + int2;
```

```
   0x00000000004008b4 <+158>: mov    eax,DWORD PTR [rbp-0x30]
   0x00000000004008b7 <+161>: add    DWORD PTR [rbp-0x24],eax
```

This segment takes the contents pointed to by rbp-0x30 (int0) and loads it into the eax register. It then proceeds to add the contents of the eax register to the value pointed to by rbp-0x24 (int3) and then stores it in rbp-0x24 (int3).

```
int3 = int0 + int3;
```

```
   0x00000000004008ba <+164>: lea    rax,[rbp-0x20]
   0x00000000004008be <+168>: mov    edx,0x14
   0x00000000004008c3 <+173>: mov    esi,0x0
   0x00000000004008c8 <+178>: mov    rdi,rax
   0x00000000004008cb <+181>: call   0x4006a0 <memset@plt>
```

Here we see the char array pointed to by rbp-0x20 being loaded onto the stack. Then the hex srings 0x14 and 0 are moved onto the stack. Then it calls the memset function. The memset function will write a digit a sepcified amount of times. In this instance the digit is probably 0, and the amount is 20. If it was the other way it wouldn't be able to do anything. Now before we assumed that the char array pointed to by rbp-0x20 was 19 characters long, however now it is probably atleast 20. This is because if it was 19 characters long this memset would literally do a buffer overflow to the program. So this segment just essentially writes 20 zeros to the char array located at rbp-0x20, which we assume now to be 20 characters long.

```
memset(buf0, 0, 20);
```

```
   0x00000000004008d0 <+186>: mov    rdx,QWORD PTR [rip+0x2017a9]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x00000000004008d7 <+193>: lea    rax,[rbp-0x20]
   0x00000000004008db <+197>: mov    esi,0x13
   0x00000000004008e0 <+202>: mov    rdi,rax
   0x00000000004008e3 <+205>: call   0x4006c0 <fgets@plt>
```

This is pretty much identical to the previous fgets segments. It loads the char array pointed to by rbp-0x20 (buf0) onto the stack, moves the hex string 0x13 (hex for 19) then calls fgets to read in 19 characters into the char array stored at rbp-0x20 (buf0). So it just scans 19 characters into the char array at rbp-0x20 using fgets.

```
fgets(buf0, 19, stdin);
```

```
   0x00000000004008e8 <+210>: lea    rax,[rbp-0x20]
   0x00000000004008ec <+214>: mov    rdi,rax
   0x00000000004008ef <+217>: call   0x4006e0 <atoi@plt>
   0x00000000004008f4 <+222>: cmp    eax,DWORD PTR [rbp-0x24]
   0x00000000004008f7 <+225>: jne    0x400915 <elev0+255>   
   0x00000000004008f9 <+227>: mov    edi,0x400cc8
   0x00000000004008fe <+232>: call   0x400670 <puts@plt>
```

In here we see a cmp instruction. The cnp instruction appears to be comaring the output of an atoi call on the char array at rbp-0x20 (buf0) against the value pointed to by rbp-0x24 (int3). If they are equal, then it will print out a string. If not then it will just jump to elev0+255 (that segment was already covered, so I'm not going to reverse it again).

```
if (int3 == atoi(buf0))
{
   puts(some string);
}
else
{
   exit(0);
}
```

Putting it all together, we get the original C source code (a couple of things will be off such as int names, however it will do the same things)

```
int int0 = 5;
int int1 = int0 + 13;
int0 = int1 * 3;
int int2 = int0 / int1;
int2 = int0 + int1 + int2;
char buf0[20];
fgets(buf0, 19, stdin);
if (int2 == atoi(buf0))
{
   int int3 = int2;
   int2 = int1 & int0;
   int0 = int2 ^ int1;
   int3 = int1 | int3;
   int3 = int1 + int2;
   int3 = int0 + int3;
   memset(buf0, 0, 20);
   fgets(buf0, 19, stdin);
   if (int3 == atoi(buf0))
   {
         puts(some string);
   }
   else
   {
      exit(0);
   }
}
else
{
   exit(0);
}
```

So we already know the value we have to pass to the first fgets call to pass the check is 75, and using the same logic and leftover values from the first check we can figure out that in order to pass the second check we will need to pass the value 36. Let's test everything that we have found out so far.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e8 (master)$ ./e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.
is there another?
did I get through?
```

So it appears as though we successfully reversed elev.. Now onto the second to last function, elev1.

```
gdb-peda$ disas elev1
Dump of assembler code for function elev1:
   0x0000000000400930 <+0>:   push   rbp
   0x0000000000400931 <+1>:   mov    rbp,rsp
   0x0000000000400934 <+4>:   add    rsp,0xffffffffffffff80
   0x0000000000400938 <+8>:   mov    rax,QWORD PTR fs:0x28
   0x0000000000400941 <+17>:  mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400945 <+21>:  xor    eax,eax 
   0x0000000000400947 <+23>:  mov    rdx,QWORD PTR [rip+0x201732]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x000000000040094e <+30>:  lea    rax,[rbp-0x50]
   0x0000000000400952 <+34>:  mov    esi,0x14
   0x0000000000400957 <+39>:  mov    rdi,rax
   0x000000000040095a <+42>:  call   0x4006c0 <fgets@plt>
   0x000000000040095f <+47>:  lea    rax,[rbp-0x30]
   0x0000000000400963 <+51>:  mov    DWORD PTR [rax],0x31313030
   0x0000000000400969 <+57>:  mov    WORD PTR [rax+0x4],0x3030
   0x000000000040096f <+63>:  mov    BYTE PTR [rax+0x6],0x30 
   0x0000000000400973 <+67>:  lea    rdx,[rbp-0x50]
   0x0000000000400977 <+71>:  lea    rax,[rbp-0x30]
   0x000000000040097b <+75>:  mov    rsi,rdx
   0x000000000040097e <+78>:  mov    rdi,rax
   0x0000000000400981 <+81>:  call   0x4006f0 <strcat@plt> 
   0x0000000000400986 <+86>:  lea    rax,[rbp-0x30]
   0x000000000040098a <+90>:  mov    rdi,rax
   0x000000000040098d <+93>:  call   0x400680 <strlen@plt>
   0x0000000000400992 <+98>:  mov    DWORD PTR [rbp-0x74],eax
   0x0000000000400995 <+101>: mov    rdx,QWORD PTR [rip+0x2016e4]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x000000000040099c <+108>: lea    rax,[rbp-0x70]
   0x00000000004009a0 <+112>: mov    esi,0x14
   0x00000000004009a5 <+117>: mov    rdi,rax
   0x00000000004009a8 <+120>: call   0x4006c0 <fgets@plt>
   0x00000000004009ad <+125>: lea    rax,[rbp-0x70]
   0x00000000004009b1 <+129>: mov    rdi,rax
   0x00000000004009b4 <+132>: call   0x4006e0 <atoi@plt>
   0x00000000004009b9 <+137>: cmp    eax,DWORD PTR [rbp-0x74]
   0x00000000004009bc <+140>: jne    0x400a2f <elev1+255>
   0x00000000004009be <+142>: lea    rax,[rbp-0x70]
   0x00000000004009c2 <+146>: mov    edx,0x14
   0x00000000004009c7 <+151>: mov    esi,0x0
   0x00000000004009cc <+156>: mov    rdi,rax
   0x00000000004009cf <+159>: call   0x4006a0 <memset@plt>
   0x00000000004009d4 <+164>: mov    rdx,QWORD PTR [rip+0x2016a5]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x00000000004009db <+171>: lea    rax,[rbp-0x70]
   0x00000000004009df <+175>: mov    esi,0x14
   0x00000000004009e4 <+180>: mov    rdi,rax
   0x00000000004009e7 <+183>: call   0x4006c0 <fgets@plt>
   0x00000000004009ec <+188>: mov    eax,DWORD PTR [rbp-0x74]
   0x00000000004009ef <+191>: movsxd rdx,eax
   0x00000000004009f2 <+194>: lea    rcx,[rbp-0x70]
   0x00000000004009f6 <+198>: lea    rax,[rbp-0x30]
   0x00000000004009fa <+202>: mov    rsi,rcx
   0x00000000004009fd <+205>: mov    rdi,rax
   0x0000000000400a00 <+208>: call   0x400660 <strncmp@plt>
   0x0000000000400a05 <+213>: test   eax,eax
   0x0000000000400a07 <+215>: jne    0x400a25 <elev1+245>
   0x0000000000400a09 <+217>: mov    edi,0x400cf0
   0x0000000000400a0e <+222>: call   0x400670 <puts@plt>
   0x0000000000400a13 <+227>: nop
   0x0000000000400a14 <+228>: mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400a18 <+232>: xor    rax,QWORD PTR fs:0x28
   0x0000000000400a21 <+241>: je     0x400a3e <elev1+270>
   0x0000000000400a23 <+243>: jmp    0x400a39 <elev1+265>
   0x0000000000400a25 <+245>: mov    edi,0x0
   0x0000000000400a2a <+250>: call   0x400700 <exit@plt>
   0x0000000000400a2f <+255>: mov    edi,0x0
   0x0000000000400a34 <+260>: call   0x400700 <exit@plt>   
   0x0000000000400a39 <+265>: call   0x400690 <__stack_chk_fail@plt>
   0x0000000000400a3e <+270>: leave  
   0x0000000000400a3f <+271>: ret    
End of assembler dump.
```

```
   0x0000000000400947 <+23>:  mov    rdx,QWORD PTR [rip+0x201732]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x000000000040094e <+30>:  lea    rax,[rbp-0x50]
   0x0000000000400952 <+34>:  mov    esi,0x14
   0x0000000000400957 <+39>:  mov    rdi,rax
   0x000000000040095a <+42>:  call   0x4006c0 <fgets@plt>
```

This segment is a typical fgets call. We see that it moves the stdin onto the stack, loads the char array pointed to by rbp-0x50 (first time we see this, we're going to assume the char array is 20 characters long), and the hex string 0x14 (hex for the decimal 20) onto the stack. Then it proceeds to call the fgets function. So essentially this segment will call the fgets command to scan 20 characters into the char array at rbp-0x50 using standard in.

```
char buf0[30];
fgets(buf0, 20, stdin);
```

```
   0x000000000040095f <+47>:  lea    rax,[rbp-0x30]
   0x0000000000400963 <+51>:  mov    DWORD PTR [rax],0x31313030
   0x0000000000400969 <+57>:  mov    WORD PTR [rax+0x4],0x3030
   0x000000000040096f <+63>:  mov    BYTE PTR [rax+0x6],0x30
```

Looking here, we see a new char array. This char array is loaded into the rax register. Then we see a series of hex strings moved into various parts of the rax register. First it loads the hex string 0x31313030 (which is hex for the Ascii representation of 1100). Then it moves the hex string 0x3030 into rax+0x4 (the reason why it moves it into rax+0x4 instead of rax is because the previous hex string took up all of the space between rax and rax+0x4). Then it loads the hex string 0x30 into rax+0x6 (again all of the space between rax and rax+0x6 is taken up by the previous strings). Since rax holds a pointer to rbp-0x30 these strings are being written to the value pointed to by rbp-0x30. However the order the characters are being written to the rax register is not the order that the program will read the data. let's analyze the data right after elev1 using gdv.

```
gdb-peda$ b *elev1+67
Breakpoint 1 at 0x400973
gdb-peda$ r rev eng
Starting program: /Hackery/escape/endless_pit/e8/e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400973 in elev1 ()
gdb-peda$ x/20w $rbp-0x50
0x7fffffffdd90:   0x0000000a  0x00000000  0xffffdde0  0x00007fff
0x7fffffffdda0:   0x00400720  0x00000000  0x00400903  0x00000000
0x7fffffffddb0:   0x31313030  0x00303030  0x00000012  0x00000024
0x7fffffffddc0:   0x000a3633  0x00000000  0x00000000  0x00000000
0x7fffffffddd0:   0x00000000  0x00000000  0x3ecab900  0xe7b9f23a
```

So we can see our data stored in memory.

```
0x7fffffffddb0:   0x31313030  0x00303030  0x00000012  0x00000024
``` 

We can see that the strings 0x313130 0x3030 and 0x30 are present. However remember that is program reads data in least endian (or least significant bit first) which means that to us the data is stored backwards in each individual 4 byte segment, however to us the segments are stored in order. This means that when the binary reads that data, it will read the string as 0x30303131303030 (it does recognize the 00 in the second segment because it is equal to zero). So this segment essentially writes "0011000" to the char array pointed to by rbp-0x30.

```
char buf1[30];
strncpy(buf1, "0011000", 7);
```

```
   0x0000000000400973 <+67>:  lea    rdx,[rbp-0x50]
   0x0000000000400977 <+71>:  lea    rax,[rbp-0x30]
   0x000000000040097b <+75>:  mov    rsi,rdx
   0x000000000040097e <+78>:  mov    rdi,rax
   0x0000000000400981 <+81>:  call   0x4006f0 <strcat@plt>
```

This segment just loads the char arrays pointed to by rbp-0x50 (buf0) and rbp-0x30 (buf1) onto the stack then calls the strcat function. The strcat function will append the second string (in this case buf1) onto the first string (in this case buf0).

```
strcat(buf1, buf0);
``` 

```
   0x0000000000400986 <+86>:  lea    rax,[rbp-0x30]
   0x000000000040098a <+90>:  mov    rdi,rax
   0x000000000040098d <+93>:  call   0x400680 <strlen@plt>
   0x0000000000400992 <+98>:  mov    DWORD PTR [rbp-0x74],eax
```

In this segment we see the char array pointed to by rbp-0x30 (buf1) loaded into the rax register, then the strlen function being called which stores it's output in the eax register. The strlen function will output an integer value equal to the amount of characters the string it was passed has. It then stores the contents of the eax register into what we can pressume to be a new integer located at rbp-0x74. So essentially this segment creates a new int, then sets it equal to the length of buf1 using the strlen function.

```
int int0 = strlen(buf1);
```

```
   0x0000000000400995 <+101>: mov    rdx,QWORD PTR [rip+0x2016e4]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x000000000040099c <+108>: lea    rax,[rbp-0x70]
   0x00000000004009a0 <+112>: mov    esi,0x14
   0x00000000004009a5 <+117>: mov    rdi,rax
   0x00000000004009a8 <+120>: call   0x4006c0 <fgets@plt>
```

This segment is the typical fgets command, that is using stdin to scan 20 characters into the location pointed to by rbp-0x70 (which is a new buffer for us, and we can assume it's length is probably at least 20).

```
char buf2[20];
fgets(buf2, 20, stdin);
```

```
   0x00000000004009ad <+125>: lea    rax,[rbp-0x70]
   0x00000000004009b1 <+129>: mov    rdi,rax
   0x00000000004009b4 <+132>: call   0x4006e0 <atoi@plt>
   0x00000000004009b9 <+137>: cmp    eax,DWORD PTR [rbp-0x74]
   0x00000000004009bc <+140>: jne    0x400a2f <elev1+255>
```

We've seen this segment before. This is the typical load the buf2 (rbp-0x70) onto the stack, run atoi on it, then compare it against int0 (rbp-0x74). If the check suceeds then the program succeeds. If the check fails, then the code jumps to a point in the program where it just exits much like the previous function.

```
if (int0 == atoi(buf2))
{
   //rest of the code here
}
else
{
   exit(0);
}
```

```
   0x00000000004009be <+142>: lea    rax,[rbp-0x70]
   0x00000000004009c2 <+146>: mov    edx,0x14
   0x00000000004009c7 <+151>: mov    esi,0x0
   0x00000000004009cc <+156>: mov    rdi,rax
   0x00000000004009cf <+159>: call   0x4006a0 <memset@plt>
```

Looking at this segment, this is another memset segment to write 20 0s to the char array pointed to by rbp-0x70 (buf2).

```
memset(buf2, 0, 20);
```

```
   0x00000000004009d4 <+164>: mov    rdx,QWORD PTR [rip+0x2016a5]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x00000000004009db <+171>: lea    rax,[rbp-0x70]
   0x00000000004009df <+175>: mov    esi,0x14
   0x00000000004009e4 <+180>: mov    rdi,rax
   0x00000000004009e7 <+183>: call   0x4006c0 <fgets@plt>
```

This is another fgets call to use stdin to write 20 characters buf2 (rbp-0x70).

```
fgets(buf2, 20, stdin);
```

```
   0x00000000004009ec <+188>: mov    eax,DWORD PTR [rbp-0x74]
   0x00000000004009ef <+191>: movsxd rdx,eax
   0x00000000004009f2 <+194>: lea    rcx,[rbp-0x70]
   0x00000000004009f6 <+198>: lea    rax,[rbp-0x30]
   0x00000000004009fa <+202>: mov    rsi,rcx
   0x00000000004009fd <+205>: mov    rdi,rax
   0x0000000000400a00 <+208>: call   0x400660 <strncmp@plt>
   0x0000000000400a05 <+213>: test   eax,eax
   0x0000000000400a07 <+215>: jne    0x400a25 <elev1+245>
   0x0000000000400a09 <+217>: mov    edi,0x400cf0
   0x0000000000400a0e <+222>: call   0x400670 <puts@plt>
```

Here we see that the strncmp function is called, which if the two strings it compares are equivalent it will output a zero to the eax register. We see that immediately after the strncmp call, the test instruction is used with the eax register as both arguments. This will output a 1 if the eax register is equal to zero, which will make the following jne instruction not jumo to elev1+245 and make the program exit. Then the program just prints something out using puts. Now looking at the strncmp function, we see that it has three arguments moved onto the stack before it is called. The first is int0 (rbp-0x74) and then buf2 and buf1. We know that strncmp requires three paramters, two strings or chars and an integer. It will compare the first x amount of characters of the two strings where x is equal to the integer that was passed at it's third argument. 

```
if (strncmp(buf2, buf1, int0) == 0)
{
   puts(some string);
}
else
{
   exit(0);
}
```

So when we put all of our reversed C code together we get this...

```
char buf0[30];
fgets(buf0, 20, stdin);
char buf1[30];
strncpy(buf1, "0011000", 7);
strcat(buf1, buf0);
int int0 = strlen(buf1);
char buf2[20];
fgets(buf2, 20, stdin);
if (int0 == atoi(buf2))
{
   memset(buf2, 0, 20);
   fgets(buf2, 20, stdin);
   if (strncmp(buf2, buf1, int0) == 0)
   {
         puts(some string);
   }
   else
   {
         exit(0);
   }
}
else
{
   exit(0);
}
```

So looking at this C code, that in order to pass the first check here we will need to know the length of buf1. The char array buf1 is only written to twice, once with the strncpy function copying the ascii string "0011000", and appending the char array buf0 which we get to write to with an fgets call. So if we don't write anything to the buf0 fgets call the lenght should be 8 (because even if we don't give the fgets command any text, it will write a newline character which is counted as a character by strlen), and we should be able to pass by feeding buf2 the string "7". As for the second check, it appears that we just have to give it the string that is currecntly in buf1. Again if we don't write anything to buf0 using the fgets call, it should just be "0011000". The newline character will be included with the fgets call. Let's test out our findings.

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e8 (master)$ ./e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.

8
0011000
Lazy researchers like you will never figure out the final elevator.
almost there
So close... to the bottom.
```

Now onto the last function

```
gdb-peda$ disas elev2
Dump of assembler code for function elev2:
   0x0000000000400a40 <+0>:   push   rbp
   0x0000000000400a41 <+1>:   mov    rbp,rsp
   0x0000000000400a44 <+4>:   sub    rsp,0x30
   0x0000000000400a48 <+8>:   mov    rax,QWORD PTR fs:0x28
   0x0000000000400a51 <+17>:  mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400a55 <+21>:  xor    eax,eax
   0x0000000000400a57 <+23>:  mov    esi,0x38
   0x0000000000400a5c <+28>:  mov    edi,0x1
   0x0000000000400a61 <+33>:  call   0x4006d0 <calloc@plt>
   0x0000000000400a66 <+38>:  mov    QWORD PTR [rbp-0x28],rax
   0x0000000000400a6a <+42>:  mov    rax,QWORD PTR [rbp-0x28]
   0x0000000000400a6e <+46>:  movabs rcx,0x726f746176656c65
   0x0000000000400a78 <+56>:  mov    QWORD PTR [rax],rcx
   0x0000000000400a7b <+59>:  movabs rsi,0x726f777373617020
   0x0000000000400a85 <+69>:  mov    QWORD PTR [rax+0x8],rsi
   0x0000000000400a89 <+73>:  mov    WORD PTR [rax+0x10],0x64   
   0x0000000000400a8f <+79>:  mov    rdx,QWORD PTR [rip+0x2015ea]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400a96 <+86>:  lea    rax,[rbp-0x20]
   0x0000000000400a9a <+90>:  mov    esi,0x13
   0x0000000000400a9f <+95>:  mov    rdi,rax
   0x0000000000400aa2 <+98>:  call   0x4006c0 <fgets@plt>   
   0x0000000000400aa7 <+103>: mov    rcx,QWORD PTR [rbp-0x28]
   0x0000000000400aab <+107>: lea    rax,[rbp-0x20]
   0x0000000000400aaf <+111>: mov    edx,0x11
   0x0000000000400ab4 <+116>: mov    rsi,rcx
   0x0000000000400ab7 <+119>: mov    rdi,rax
   0x0000000000400aba <+122>: call   0x400660 <strncmp@plt>
   0x0000000000400abf <+127>: test   eax,eax
   0x0000000000400ac1 <+129>: je     0x400ad7 <elev2+151>
   0x0000000000400ac3 <+131>: mov    edi,0x400d34
   0x0000000000400ac8 <+136>: call   0x400670 <puts@plt>
   0x0000000000400acd <+141>: mov    edi,0x0
   0x0000000000400ad2 <+146>: call   0x400700 <exit@plt>   
   0x0000000000400ad7 <+151>: nop
   0x0000000000400ad8 <+152>: mov    rax,QWORD PTR [rbp-0x8]
   0x0000000000400adc <+156>: xor    rax,QWORD PTR fs:0x28
   0x0000000000400ae5 <+165>: je     0x400aec <elev2+172>
   0x0000000000400ae7 <+167>: call   0x400690 <__stack_chk_fail@plt>
   0x0000000000400aec <+172>: leave  
   0x0000000000400aed <+173>: ret    
End of assembler dump.
```

```
   0x0000000000400a51 <+17>:  mov    QWORD PTR [rbp-0x8],rax
   0x0000000000400a55 <+21>:  xor    eax,eax
   0x0000000000400a57 <+23>:  mov    esi,0x38
   0x0000000000400a5c <+28>:  mov    edi,0x1
   0x0000000000400a61 <+33>:  call   0x4006d0 <calloc@plt>
```

This segment uses the calloc function, which returns a pointer to memory it allocated in the heap that is initialized to a given int. We can see that it first moves rbp-0x8 onto the stack, and since it is the first time we see it and it is the only register value referenced in this segment it is probably where the pointer is stored. We see that it then later moves the hex strings 0x38 and 0x1 into the esi and edi registers. These are the paramters for the calloc function with 56 as the space that it is allocating in the heap, and 1 as the int that it is setting the new memory to. There is almost definately some data structures in that heap, such as integers, char arrays, floats, etc. We can wait and see what happens to that space to know.

```
struct structroot *h0;
h0 = calloc(1, 56);
```   

```
   0x0000000000400a66 <+38>:  mov    QWORD PTR [rbp-0x28],rax
   0x0000000000400a6a <+42>:  mov    rax,QWORD PTR [rbp-0x28]
   0x0000000000400a6e <+46>:  movabs rcx,0x726f746176656c65
   0x0000000000400a78 <+56>:  mov    QWORD PTR [rax],rcx
   0x0000000000400a7b <+59>:  movabs rsi,0x726f777373617020
   0x0000000000400a85 <+69>:  mov    QWORD PTR [rax+0x8],rsi
   0x0000000000400a89 <+73>:  mov    WORD PTR [rax+0x10],0x64
```

Here we see a strcpy being used. Keep in mind that in the version of gcc used to compile this, strcpy doesn't call upon a specific low level function. Here we can see that the value pointed to by rbp-0x28 is being moved into the rax register, then a series of moves tabke place using the mov and movabs (movabs is just like mov, however it enforces encoding 64 bit offsets). However we will still need to find out what the string copied to the location rbp-0x28 is. For this we can just analyze the heap memory pointed to by rbp-0x28 to see the string.

```
gdb-peda$ b *elev2+79
Breakpoint 1 at 0x400a8f
gdb-peda$ r rev eng
Starting program: /Hackery/escape/endless_pit/e8/e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.

8
0011000
Lazy researchers like you will never figure out the final elevator.
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400a8f in elev2 ()
gdb-peda$ x/x $rbp-0x28
0x7fffffffddb8:   0x0000000000603830
gdb-peda$ x/s 0x603830
0x603830:   "elevator password"
gdb-peda$ find elevator
Searching for 'elevator' in: None ranges
Found 7 results, display max 7 items:
    e8 : 0x400a70 (<elev2+48>:   gs ins BYTE PTR es:[rdi],dx)
    e8 : 0x400ce6 ("elevator.")
    e8 : 0x400d2a ("elevator.")
    e8 : 0x400d95 ("elevators, but can you figure out how to use them?")
    e8 : 0x400dfa ("elevators! Level cleared!")
[heap] : 0x60345a ("elevator.\no use them?\n")
[heap] : 0x603830 ("elevator password")
```

As you can see, the string copied to the memory allocated in the heap is "elevator password" and it is stored in the heap.

```
strcpy(h0->char, "elevator password");
```

```
   0x0000000000400a8f <+79>:  mov    rdx,QWORD PTR [rip+0x2015ea]        # 0x602080 <stdin@@GLIBC_2.2.5>
   0x0000000000400a96 <+86>:  lea    rax,[rbp-0x20]
   0x0000000000400a9a <+90>:  mov    esi,0x13
   0x0000000000400a9f <+95>:  mov    rdi,rax
   0x0000000000400aa2 <+98>:  call   0x4006c0 <fgets@plt>
```

This appears to be another fgets call, scanning 19 characters into a char at rbp-0x28 through standard in. However is it the heap? We can answer that question with gdb.

```
gdb-peda$ b *elev2+103
Breakpoint 1 at 0x400aa7
gdb-peda$ pattern create 20
'AAA%AAsAABAA$AAnAACA'
gdb-peda$ r rev eng
Starting program: /Hackery/escape/endless_pit/e8/e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.

8
0011000
Lazy researchers like you will never figure out the final elevator.
AAA%AAsAABAA$AAnAACA
```

One wall of text later...

```
Breakpoint 1, 0x0000000000400aa7 in elev2 ()
gdb-peda$ x/s $rbp-0x20
0x7fffffffddc0:   "AAA%AAsAABAA$AAnAA"
gdb-peda$ find gdb-peda$ b *elev2+103
gdb-peda$ find AAA%AAsAABAA
Searching for 'AAA%AAsAABAA' in: None ranges
Found 2 results, display max 2 items:
 [heap] : 0x603010 ("AAA%AAsAABAA$AAnAACA\n")
[stack] : 0x7fffffffddc0 ("AAA%AAsAABAA$AAnAA")
```

I know that when we issued the find command, it looks like it came up in both the stack and the heap. However if you look at the last five characters of each string, you can see that they are different and the string located on the stack is the string we gave it. So we know the string stored in rbp-0x20 is on the stack, and also it is the first time we are seeing this referenced so the char array is also being established.

```
char buf0[19];
fgets(buf0, sizeof(buf0), stdin);
```

```
   0x0000000000400aa7 <+103>: mov    rcx,QWORD PTR [rbp-0x28]
   0x0000000000400aab <+107>: lea    rax,[rbp-0x20]
   0x0000000000400aaf <+111>: mov    edx,0x11
   0x0000000000400ab4 <+116>: mov    rsi,rcx
   0x0000000000400ab7 <+119>: mov    rdi,rax
   0x0000000000400aba <+122>: call   0x400660 <strncmp@plt>
   0x0000000000400abf <+127>: test   eax,eax
   0x0000000000400ac1 <+129>: je     0x400ad7 <elev2+151>
   0x0000000000400ac3 <+131>: mov    edi,0x400d34
   0x0000000000400ac8 <+136>: call   0x400670 <puts@plt>
   0x0000000000400acd <+141>: mov    edi,0x0
   0x0000000000400ad2 <+146>: call   0x400700 <exit@plt>
```

Here we can see a strncmp call being made, immediately proceeded by a test and je instruction. If the strncmp function determines that the two strings it got were the same, then it will skip the puts and the exit function and end the function. If it doesn't, well then it will print something out then exit the function. when we look at the two strings being compared, we see rbp-0x28 (h0->char) and rvo-0x20 (buf0) being moved into the rcx and rax registers, so they are the char arrays being compared. In addition to that, we see that the hex string 0x11 (hex for the decimal 17) being moved into the edx register, so it is looking at the first 17 characters only (which corresponds with the exact lenght of "elevator password" so we won't have to worry about that newline character). We know the h0-char has a specific string written to it that we can't change, however buf0 we control. So we can just use the fgets call to write "elevator password" to rbp-0x20 and then the strncmp function should evaluate the strings as true. 

```
if (strncmp(buf0, h0->char, 17) != 0)
{
   puts(some string);
   exit(0);
}
``` 

Putting together all of the C code, we get this...

```
struct structroot *h0;
h0 = calloc(1, 56);
strcpy(h0->char, "elevator password");
char buf0[19];
fgets(buf0, sizeof(buf0), stdin);
if (strncmp(buf0, h0->char, 17) != 0)
{
   puts(some string);
   exit(0);
}
```

So we know that the solution for the final segment should be to just write "elevator password" using the fgets call. Let's test it out...

```
guyinatuxedo@tux:/Hackery/escape/endless_pit/e8 (master)$ ./e8 rev eng
rev
eng
You might have access to the elevators, but can you figure out how to use them?
75
36
So you figured out the second elevator.

8
0011000
Lazy researchers like you will never figure out the final elevator.
elevator password
So you are actually getting out of here using the elevators! Level cleared!
```

Just like that, we reversed the binary!