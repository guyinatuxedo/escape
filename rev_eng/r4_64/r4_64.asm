Dump of assembler code for function main:
   0x0000000000400526 <+0>:	push   rbp
   0x0000000000400527 <+1>:	mov    rbp,rsp
   0x000000000040052a <+4>:	sub    rsp,0x20
   0x000000000040052e <+8>:	mov    DWORD PTR [rbp-0x14],edi
   0x0000000000400531 <+11>:	mov    QWORD PTR [rbp-0x20],rsi
   0x0000000000400535 <+15>:	mov    DWORD PTR [rbp-0x4],0x1
   0x000000000040053c <+22>:	jmp    0x40056b <main+69>
   0x000000000040053e <+24>:	mov    eax,DWORD PTR [rbp-0x4]
   0x0000000000400541 <+27>:	cdqe   
   0x0000000000400543 <+29>:	lea    rdx,[rax*8+0x0]
   0x000000000040054b <+37>:	mov    rax,QWORD PTR [rbp-0x20]
   0x000000000040054f <+41>:	add    rax,rdx
   0x0000000000400552 <+44>:	mov    rax,QWORD PTR [rax]
   0x0000000000400555 <+47>:	mov    rsi,rax
   0x0000000000400558 <+50>:	mov    edi,0x400604
   0x000000000040055d <+55>:	mov    eax,0x0
   0x0000000000400562 <+60>:	call   0x400400 <printf@plt>
   0x0000000000400567 <+65>:	add    DWORD PTR [rbp-0x4],0x1
   0x000000000040056b <+69>:	mov    eax,DWORD PTR [rbp-0x4]
   0x000000000040056e <+72>:	cmp    eax,DWORD PTR [rbp-0x14]
   0x0000000000400571 <+75>:	jl     0x40053e <main+24>
   0x0000000000400573 <+77>:	mov    eax,0x0
   0x0000000000400578 <+82>:	leave  
   0x0000000000400579 <+83>:	ret    
End of assembler dump.

