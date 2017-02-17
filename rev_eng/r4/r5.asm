Dump of assembler code for function main:
   0x0804840b <+0>:	lea    ecx,[esp+0x4]
   0x0804840f <+4>:	and    esp,0xfffffff0
   0x08048412 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:	push   ebp
   0x08048416 <+11>:	mov    ebp,esp
   0x08048418 <+13>:	push   ebx
   0x08048419 <+14>:	push   ecx
   0x0804841a <+15>:	sub    esp,0x10
   0x0804841d <+18>:	mov    ebx,ecx
   0x0804841f <+20>:	mov    DWORD PTR [ebp-0xc],0x1
   0x08048426 <+27>:	jmp    0x804844e <main+67>
   0x08048428 <+29>:	mov    eax,DWORD PTR [ebp-0xc]
   0x0804842b <+32>:	lea    edx,[eax*4+0x0]
   0x08048432 <+39>:	mov    eax,DWORD PTR [ebx+0x4]
   0x08048435 <+42>:	add    eax,edx
   0x08048437 <+44>:	mov    eax,DWORD PTR [eax]
   0x08048439 <+46>:	sub    esp,0x8
   0x0804843c <+49>:	push   eax
   0x0804843d <+50>:	push   0x80484f0
   0x08048442 <+55>:	call   0x80482e0 <printf@plt>
   0x08048447 <+60>:	add    esp,0x10
   0x0804844a <+63>:	add    DWORD PTR [ebp-0xc],0x1
   0x0804844e <+67>:	mov    eax,DWORD PTR [ebp-0xc]
   0x08048451 <+70>:	cmp    eax,DWORD PTR [ebx]
   0x08048453 <+72>:	jl     0x8048428 <main+29>
   0x08048455 <+74>:	mov    eax,0x0
   0x0804845a <+79>:	lea    esp,[ebp-0x8]
   0x0804845d <+82>:	pop    ecx
   0x0804845e <+83>:	pop    ebx
   0x0804845f <+84>:	pop    ebp
   0x08048460 <+85>:	lea    esp,[ecx-0x4]
   0x08048463 <+88>:	ret    
End of assembler dump.
