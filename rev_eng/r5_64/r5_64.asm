Dump of assembler code for function main:
   0x0000000000400666 <+0>:	push   rbp
   0x0000000000400667 <+1>:	mov    rbp,rsp
   0x000000000040066a <+4>:	sub    rsp,0x50
   0x000000000040066e <+8>:	mov    rax,QWORD PTR fs:0x28
   0x0000000000400677 <+17>:	mov    QWORD PTR [rbp-0x8],rax
   0x000000000040067b <+21>:	xor    eax,eax
   0x000000000040067d <+23>:	mov    edi,0x28
   0x0000000000400682 <+28>:	call   0x400550 <malloc@plt>
   0x0000000000400687 <+33>:	mov    QWORD PTR [rbp-0x48],rax
   0x000000000040068b <+37>:	mov    rax,QWORD PTR [rbp-0x48]
   0x000000000040068f <+41>:	movabs rcx,0x2c6b6f6f6c20684f
   0x0000000000400699 <+51>:	mov    QWORD PTR [rax],rcx
   0x000000000040069c <+54>:	movabs rsi,0x6f20796177206120
   0x00000000004006a6 <+64>:	mov    QWORD PTR [rax+0x8],rsi
   0x00000000004006aa <+68>:	mov    DWORD PTR [rax+0x10],0x217475
   0x00000000004006b1 <+75>:	mov    rdx,QWORD PTR [rip+0x200998]        # 0x601050 <stdin@@GLIBC_2.2.5>
   0x00000000004006b8 <+82>:	lea    rax,[rbp-0x40]
   0x00000000004006bc <+86>:	mov    esi,0x32
   0x00000000004006c1 <+91>:	mov    rdi,rax
   0x00000000004006c4 <+94>:	call   0x400540 <fgets@plt>
   0x00000000004006c9 <+99>:	movzx  edx,BYTE PTR [rbp-0x40]
   0x00000000004006cd <+103>:	mov    rax,QWORD PTR [rbp-0x48]
   0x00000000004006d1 <+107>:	movzx  eax,BYTE PTR [rax]
   0x00000000004006d4 <+110>:	cmp    dl,al
   0x00000000004006d6 <+112>:	jne    0x4006e2 <main+124>
   0x00000000004006d8 <+114>:	mov    edi,0x400788
   0x00000000004006dd <+119>:	call   0x400510 <puts@plt>
   0x00000000004006e2 <+124>:	mov    eax,0x0
   0x00000000004006e7 <+129>:	mov    rcx,QWORD PTR [rbp-0x8]
   0x00000000004006eb <+133>:	xor    rcx,QWORD PTR fs:0x28
   0x00000000004006f4 <+142>:	je     0x4006fb <main+149>
   0x00000000004006f6 <+144>:	call   0x400520 <__stack_chk_fail@plt>
   0x00000000004006fb <+149>:	leave  
   0x00000000004006fc <+150>:	ret    
End of assembler dump.

