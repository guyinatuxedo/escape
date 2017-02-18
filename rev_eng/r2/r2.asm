Dump of assembler code for function main:
   0x0804840b <+0>:	lea    ecx,[esp+0x4]
   0x0804840f <+4>:	and    esp,0xfffffff0
   0x08048412 <+7>:	push   DWORD PTR [ecx-0x4]
   0x08048415 <+10>:	push   ebp
   0x08048416 <+11>:	mov    ebp,esp
   0x08048418 <+13>:	push   ecx
   0x08048419 <+14>:	sub    esp,0x14
   0x0804841c <+17>:	mov    DWORD PTR [ebp-0xc],0x0
   0x08048423 <+24>:	jmp    0x804843c <main+49>
   0x08048425 <+26>:	sub    esp,0x8
   0x08048428 <+29>:	push   DWORD PTR [ebp-0xc]
   0x0804842b <+32>:	push   0x80484d0
   0x08048430 <+37>:	call   0x80482e0 <printf@plt>
   0x08048435 <+42>:	add    esp,0x10
   0x08048438 <+45>:	add    DWORD PTR [ebp-0xc],0x1
   0x0804843c <+49>:	cmp    DWORD PTR [ebp-0xc],0x4
   0x08048440 <+53>:	jle    0x8048425 <main+26>
   0x08048442 <+55>:	mov    eax,0x0
   0x08048447 <+60>:	mov    ecx,DWORD PTR [ebp-0x4]
   0x0804844a <+63>:	leave  
   0x0804844b <+64>:	lea    esp,[ecx-0x4]
   0x0804844e <+67>:	ret    
End of assembler dump.

