Dump of assembler code for function main:
   0x0000000000400526 <+0>:	push   rbp
   0x0000000000400527 <+1>:	mov    rbp,rsp
   0x000000000040052a <+4>:	sub    rsp,0x10
   0x000000000040052e <+8>:	mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400535 <+15>:	mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:	mov    DWORD PTR [rbp-0x8],0x0
   0x0000000000400543 <+29>:	jmp    0x400560 <main+58>
   0x0000000000400545 <+31>:	shl    DWORD PTR [rbp-0x4],1
   0x0000000000400548 <+34>:	mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040054b <+37>:	mov    esi,eax
   0x000000000040054d <+39>:	mov    edi,0x4005f4
   0x0000000000400552 <+44>:	mov    eax,0x0
   0x0000000000400557 <+49>:	call   0x400400 <printf@plt>
   0x000000000040055c <+54>:	add    DWORD PTR [rbp-0x8],0x1
   0x0000000000400560 <+58>:	cmp    DWORD PTR [rbp-0x8],0x9
   0x0000000000400564 <+62>:	jle    0x400545 <main+31>
   0x0000000000400566 <+64>:	mov    eax,0x0
   0x000000000040056b <+69>:	leave  
   0x000000000040056c <+70>:	ret    
End of assembler dump.

