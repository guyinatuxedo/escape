Dump of assembler code for function main:
   0x080484eb <+0>:	lea    ecx,[esp+0x4]
   0x080484ef <+4>:	and    esp,0xfffffff0
   0x080484f2 <+7>:	push   DWORD PTR [ecx-0x4]
   0x080484f5 <+10>:	push   ebp
   0x080484f6 <+11>:	mov    ebp,esp
   0x080484f8 <+13>:	push   ecx
   0x080484f9 <+14>:	sub    esp,0x44
   0x080484fc <+17>:	mov    eax,gs:0x14
   0x08048502 <+23>:	mov    DWORD PTR [ebp-0xc],eax
   0x08048505 <+26>:	xor    eax,eax
   0x08048507 <+28>:	sub    esp,0xc
   0x0804850a <+31>:	push   0x28
   0x0804850c <+33>:	call   0x80483b0 <malloc@plt>
   0x08048511 <+38>:	add    esp,0x10
   0x08048514 <+41>:	mov    DWORD PTR [ebp-0x44],eax
   0x08048517 <+44>:	mov    eax,DWORD PTR [ebp-0x44]
   0x0804851a <+47>:	mov    DWORD PTR [eax],0x6c20684f
   0x08048520 <+53>:	mov    DWORD PTR [eax+0x4],0x2c6b6f6f
   0x08048527 <+60>:	mov    DWORD PTR [eax+0x8],0x77206120
   0x0804852e <+67>:	mov    DWORD PTR [eax+0xc],0x6f207961
   0x08048535 <+74>:	mov    DWORD PTR [eax+0x10],0x217475
   0x0804853c <+81>:	mov    eax,ds:0x804a040
   0x08048541 <+86>:	sub    esp,0x4
   0x08048544 <+89>:	push   eax
   0x08048545 <+90>:	push   0x32
   0x08048547 <+92>:	lea    eax,[ebp-0x3e]
   0x0804854a <+95>:	push   eax
   0x0804854b <+96>:	call   0x8048390 <fgets@plt>
   0x08048550 <+101>:	add    esp,0x10
   0x08048553 <+104>:	movzx  edx,BYTE PTR [ebp-0x3e]
   0x08048557 <+108>:	mov    eax,DWORD PTR [ebp-0x44]
   0x0804855a <+111>:	movzx  eax,BYTE PTR [eax]
   0x0804855d <+114>:	cmp    dl,al
   0x0804855f <+116>:	jne    0x8048571 <main+134>
   0x08048561 <+118>:	sub    esp,0xc
   0x08048564 <+121>:	push   0x8048610
   0x08048569 <+126>:	call   0x80483c0 <puts@plt>
   0x0804856e <+131>:	add    esp,0x10
   0x08048571 <+134>:	mov    eax,0x0
   0x08048576 <+139>:	mov    ecx,DWORD PTR [ebp-0xc]
   0x08048579 <+142>:	xor    ecx,DWORD PTR gs:0x14
   0x08048580 <+149>:	je     0x8048587 <main+156>
   0x08048582 <+151>:	call   0x80483a0 <__stack_chk_fail@plt>
   0x08048587 <+156>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x0804858a <+159>:	leave  
   0x0804858b <+160>:	lea    esp,[ecx-0x4]
   0x0804858e <+163>:	ret    
End of assembler dump.
