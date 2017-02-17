Dump of assembler code for function main:
   0x0000000000400526 <+0>:	push   rbp
   0x0000000000400527 <+1>:	mov    rbp,rsp
   0x000000000040052a <+4>:	sub    rsp,0x10
   0x000000000040052e <+8>:	mov    DWORD PTR [rbp-0x4],0x0
   0x0000000000400535 <+15>:	jmp    0x40054f <main+41>
   0x0000000000400537 <+17>:	mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040053a <+20>:	mov    esi,eax
   0x000000000040053c <+22>:	mov    edi,0x4005e4
   0x0000000000400541 <+27>:	mov    eax,0x0
   0x0000000000400546 <+32>:	call   0x400400 <printf@plt>
   0x000000000040054b <+37>:	add    DWORD PTR [rbp-0x4],0x1
   0x000000000040054f <+41>:	cmp    DWORD PTR [rbp-0x4],0x4
   0x0000000000400553 <+45>:	jle    0x400537 <main+17>
   0x0000000000400555 <+47>:	mov    eax,0x0
   0x000000000040055a <+52>:	leave  
   0x000000000040055b <+53>:	ret    
End of assembler dump.

